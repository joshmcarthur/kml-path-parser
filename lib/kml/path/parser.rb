# frozen_string_literal: true

module Kml
  module Path
    class Parser
      KMZ_CONTENT_TYPES = %w[application/vnd.google-earth.kmz application/zip].freeze
      KML_NAMESPACES = {
        "kml" => "http://www.opengis.net/kml/2.2",
        "gx" => "http://www.google.com/kml/ext/2.2"
      }.freeze
      NAME_XPATHS = [
        ["//kml:Document/kml:name", KML_NAMESPACES],
        ["//kml:Placemark/kml:name", KML_NAMESPACES],
        ["//kml:name", KML_NAMESPACES],
        ["//Document/name", nil],
        ["//Placemark/name", nil]
      ].freeze
      MISSING_GEOMETRY = "must contain a LineString or gx:Track"
      MISSING_KML = "must contain a KML file"

      def initialize(file:)
        @file = file
      end

      def parse
        @parse ||= build_parse_result
      end

      def parse!
        result = parse
        raise ParseError, result.error if result.failure?

        result
      end

      def name
        parse.success? ? parse.name : extract_name
      end

      def content
        parse
        @content
      end

      private

      attr_reader :file

      def build_parse_result
        kml_content = extract_kml_content
        return failure(MISSING_KML) if kml_content.nil? || kml_content.empty?

        @content = kml_content
        coordinates = extract_coordinates
        return failure(MISSING_GEOMETRY) if coordinates.nil? || coordinates.empty?

        Result.new(success: true, name: extract_name, coordinates:, error: nil)
      rescue Zip::Error => e
        failure("could not be parsed: #{e.message}")
      end

      def failure(message)
        Result.new(success: false, name: nil, coordinates: nil, error: message)
      end

      def extract_kml_content
        file_content = read_file
        return file_content unless kmz_file?

        extract_kml_from_kmz(file_content)
      end

      def read_file
        @read_file ||= begin
          file.rewind if file.respond_to?(:rewind)
          file.read
        end
      end

      def kmz_file?
        filename = file.original_filename.to_s.downcase
        return true if filename.end_with?(".kmz")

        KMZ_CONTENT_TYPES.include?(file.content_type.to_s)
      end

      def extract_kml_from_kmz(content)
        kml = nil

        Zip::File.open_buffer(content) do |archive|
          entry_name = archive.find_entry("doc.kml")&.name || find_kml_entry_name(archive)
          kml = archive.get_input_stream(entry_name, &:read) if entry_name
        end

        kml
      end

      def find_kml_entry_name(archive)
        archive.entries.map(&:name).reject do |name|
          name.start_with?("__MACOSX/") || !name.downcase.end_with?(".kml")
        end.first
      end

      def extract_name
        NAME_XPATHS.each do |xpath, namespaces|
          document_name = xpath_value(xpath, namespaces)
          return document_name if document_name
        end

        present_string(File.basename(file.original_filename.to_s, ".*")) || "Untitled"
      end

      def extract_coordinates
        coordinates_node = line_string_coordinates_node || gx_track_coordinate_node
        return unless coordinates_node

        coordinates_from_node(coordinates_node)
      end

      def document
        @document ||= Nokogiri::XML(@content)
      end

      def coordinates_from_node(node)
        case node.name
        when "coordinates"
          parse_coordinates_text(node.text)
        when "coord"
          parse_gx_coords(gx_track_coordinate_nodes)
        end
      end

      def xpath_value(xpath, namespaces)
        node = namespaces ? document.at_xpath(xpath, namespaces) : document.at_xpath(xpath)
        present_string(node&.text)
      end

      def line_string_coordinates_node
        document.at_xpath("//kml:LineString/kml:coordinates", KML_NAMESPACES) ||
          document.at_xpath("//LineString/coordinates")
      end

      def gx_track_coordinate_node
        first_gx_track&.at_xpath("gx:coord", KML_NAMESPACES) ||
          first_gx_track&.at_xpath("*[local-name()='coord']")
      end

      def gx_track_coordinate_nodes
        track = first_gx_track
        return document.xpath("//none") unless track

        nodes = track.xpath("gx:coord", KML_NAMESPACES)
        return nodes if nodes.any?

        track.xpath("*[local-name()='coord']")
      end

      def first_gx_track
        document.at_xpath("//gx:Track", KML_NAMESPACES) ||
          document.at_xpath("//*[local-name()='Track']")
      end

      def parse_coordinates_text(text)
        normalized = text.gsub(/\s*,\s*/, ",")
        normalized.strip.split(/\s+/).filter_map do |coordinate|
          parse_coordinate_values(coordinate.split(","))
        end
      end

      def parse_gx_coords(nodes)
        nodes.filter_map { |node| parse_coordinate_values(node.text.strip.split) }
      end

      def parse_coordinate_values(values)
        return if values.length < 2

        longitude = values[0].to_f
        latitude = values[1].to_f
        altitude = values[2]&.to_f
        return unless valid_coordinate?(latitude, longitude)

        [longitude, latitude, altitude]
      end

      def valid_coordinate?(latitude, longitude)
        latitude.between?(-90, 90) && longitude.between?(-180, 180)
      end

      def present_string(value)
        return if value.nil?

        stripped = value.to_s.strip
        stripped.empty? ? nil : stripped
      end
    end
  end
end
