# frozen_string_literal: true

require "test_helper"

class Kml::Path::ParserTest < Minitest::Test
  Kml::Path::Fixtures::CATALOG[:valid].each do |path, expectations|
    define_method("test_parses_#{path.tr('/', '_')}") do
      parser = Kml::Path::Parser.new(file: kml_fixture(path))
      result = parser.parse

      refute_nil parser.content
      refute_empty parser.content
      assert result.success?
      assert_equal expectations[:name], result.name
      assert_equal expectations[:point_count], result.coordinates.length

      if expectations[:first_point]
        longitude, latitude = expectations[:first_point]
        assert_in_delta longitude, result.coordinates.first[0], 0.0001
        assert_in_delta latitude, result.coordinates.first[1], 0.0001
      end
    end
  end

  Kml::Path::Fixtures::CATALOG[:reject].each do |path, message|
    define_method("test_rejects_#{path.tr('/', '_')}") do
      parser = Kml::Path::Parser.new(file: kml_fixture(path))
      result = parser.parse

      refute result.success?
      assert_equal message, result.error
    end
  end

  def test_parse_bang_raises_on_failure
    parser = Kml::Path::Parser.new(file: kml_fixture("reject/point_only.kml"))

    error = assert_raises(Kml::Path::ParseError) { parser.parse! }
    assert_equal "must contain a LineString or gx:Track", error.message
  end

  def test_parse_bang_returns_result_on_success
    parser = Kml::Path::Parser.new(file: kml_fixture("valid/sample_route.kml"))
    result = parser.parse!

    assert result.success?
    assert_equal "Sample Trail", result.name
    assert_equal 3, result.coordinates.length
  end

  def test_uses_filename_when_kml_has_no_name_elements
    parser = Kml::Path::Parser.new(file: kml_fixture("valid/unnamed.kml", original_filename: "exported_trail.kml"))
    result = parser.parse

    assert result.success?
    assert_equal "exported_trail", result.name
    assert_equal 2, result.coordinates.length
  end

  def test_returns_coordinates_for_a_single_point_line_without_error
    parser = Kml::Path::Parser.new(file: kml_fixture("reject/single_point.kml"))
    result = parser.parse

    assert result.success?
    assert_equal 1, result.coordinates.length
  end
end
