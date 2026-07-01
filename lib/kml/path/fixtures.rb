# frozen_string_literal: true

module Kml
  module Path
    module Fixtures
      ROOT = File.expand_path("fixtures", __dir__).freeze

      def self.path(relative)
        File.join(ROOT, relative)
      end

      def self.read(relative)
        File.read(path(relative))
      end

      CATALOG = {
        valid: {
          "valid/sample_route.kml" => { name: "Sample Trail", point_count: 3 },
          "valid/sample_route.kmz" => { name: "Sample Trail", point_count: 3 },
          "valid/placemark_name.kml" => { name: "Coastal Walk", point_count: 3 },
          "valid/gx_track.kml" => { name: "GPS Track", point_count: 3 },
          "valid/multi_geometry.kml" => { name: "Split Route", point_count: 2, first_point: [144.9631, -37.8136] },
          "valid/namespace_less.kml" => { name: "Legacy Export", point_count: 3 },
          "valid/document_name_priority.kml" => { name: "Official Name", point_count: 2 },
          "valid/two_points.kml" => { name: "Minimum Path", point_count: 2 },
          "valid/coordinates_no_altitude.kml" => { name: "No Altitude", point_count: 3 },
          "valid/coordinates_single_line.kml" => { name: "Single Line", point_count: 3 },
          "valid/coordinates_extra_whitespace.kml" => { name: "Whitespace", point_count: 3 },
          "valid/nested_folder.kml" => { name: "Nested Folder", point_count: 3 },
          "valid/multiple_placemarks_first_wins.kml" => {
            name: "Multiple Placemarks",
            point_count: 2,
            first_point: [144.9631, -37.8136]
          },
          "valid/unicode_name.kml" => { name: "Øresundsstien 日本語", point_count: 2 },
          "valid/cdata_name.kml" => { name: "Trail & \"Path\" <special>", point_count: 2 },
          "valid/crlf_line_endings.kml" => { name: "Sample Trail", point_count: 3 },
          "valid/gx_track_with_timestamps.kml" => { name: "Timestamped Track", point_count: 3 },
          "valid/gx_multitrack_first_wins.kml" => {
            name: "Multi Track",
            point_count: 2,
            first_point: [144.9631, -37.8136]
          },
          "valid/linestring_attributes.kml" => { name: "Attributed Line", point_count: 3 },
          "valid/qgis_export.kml" => { name: "QGIS Export", point_count: 3 },
          "valid/invalid_coords_filtered.kml" => { name: "Filtered Coords", point_count: 3 },
          "valid/nested_multigeometry_folder.kml" => { name: "Nested MultiGeometry", point_count: 3 },
          "valid/many_points.kml" => { name: "Many Points", point_count: 10 },
          "valid/linestring_before_point.kml" => { name: "Line Before Point", point_count: 2 },
          "valid/kmz_custom_kml_name.kmz" => { name: "Minimum Path", point_count: 2 },
          "valid/kmz_with_macosx_junk.kmz" => { name: "Sample Trail", point_count: 3 }
        }.freeze,
        reject: {
          "reject/empty_document.kml" => "must contain a LineString or gx:Track",
          "reject/point_only.kml" => "must contain a LineString or gx:Track",
          "reject/polygon_only.kml" => "must contain a LineString or gx:Track",
          "reject/empty_linestring.kml" => "must contain a LineString or gx:Track",
          "reject/empty_archive.kmz" => "must contain a KML file"
        }.freeze
      }.freeze
    end
  end
end
