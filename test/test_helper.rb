# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "kml"

module KmlPathParserTest
  Upload = Struct.new(:io, :original_filename, :content_type, keyword_init: true) do
    def read
      io.read
    end

    def rewind
      io.rewind if io.respond_to?(:rewind)
    end
  end

  module FixtureHelper
    def kml_fixture(path, original_filename: nil)
      kmz = path.end_with?(".kmz")
      content_type = kmz ? "application/vnd.google-earth.kmz" : "application/vnd.google-earth.kml+xml"

      Upload.new(
        io: File.open(Kml::Path::Fixtures.path(path)),
        original_filename: original_filename || File.basename(path),
        content_type:
      )
    end

    def kml_string(content, filename: "upload.kml")
      Upload.new(
        io: StringIO.new(content),
        original_filename: filename,
        content_type: "application/vnd.google-earth.kml+xml"
      )
    end
  end
end

class Minitest::Test
  include KmlPathParserTest::FixtureHelper
end
