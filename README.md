# kml-path-parser

Extract path geometry from user-uploaded KML and KMZ files.

`kml-path-parser` is a focused library for fitness and mapping apps that need to import route tracks from real-world exports (Google Earth, My Maps, QGIS, and similar tools). It is **not** a general-purpose KML codec: it only extracts `LineString` and `gx:Track` paths.

Extracted from [VirtualTrails](https://virtualtrails.app).

## Installation

```ruby
gem "kml-path-parser", "~> 1.0"
```

## Usage

The parser expects a file-like upload object responding to `read`, `rewind`, `original_filename`, and `content_type` (as Rails `ActionDispatch::Http::UploadedFile` and `Rack::Test::UploadedFile` do).

### `#parse` — non-exceptional failures

```ruby
require "kml"

parser = Kml::Path::Parser.new(file: upload)
result = parser.parse

if result.success?
  puts result.name
  result.coordinates.each do |longitude, latitude, altitude|
    puts [longitude, latitude, altitude]
  end
else
  puts result.error
end
```

### `#parse!` — raises on failure

```ruby
result = parser.parse!
# => Kml::Path::Result

# On invalid input:
# Kml::Path::ParseError: must contain a LineString or gx:Track
```

### Lazy accessors

`#content` returns the extracted KML string (from a `.kml` file or from inside a `.kmz` archive). `#name` resolves the route name without requiring a successful coordinate parse.

## Shipped fixtures

The gem includes real-world KML/KMZ fixtures for testing and documentation:

```ruby
fixture_path = Kml::Path::Fixtures.path("valid/sample_route.kml")
catalog = Kml::Path::Fixtures::CATALOG
```

Fixtures live under `lib/kml/path/fixtures/` (`valid/` and `reject/`).

## Supported formats

| Format | Support |
|--------|---------|
| KML (`.kml`) | Yes |
| KMZ (`.kmz`) | Yes — uses `doc.kml` when present, otherwise the first `.kml` entry (skips `__MACOSX/`) |

## Parsing policies

- **Geometry:** first `LineString` in the document wins; otherwise first `gx:Track` (first track in `gx:MultiTrack`)
- **Name priority:** Document name → Placemark name → any `name` element → upload filename → `"Untitled"`
- **Coordinates:** returned as `[longitude, latitude, altitude]` arrays; altitude may be `nil`
- **Invalid coordinates:** lat/lon pairs outside valid ranges are filtered silently

## Rejected inputs

These return a failed `Result` (or raise `ParseError` via `#parse!`):

- Empty documents
- Point-only geometry
- Polygon-only geometry
- Empty `LineString` elements
- KMZ archives with no KML file
- Corrupt KMZ archives (`could not be parsed: …`)

A single-point `LineString` parses successfully; callers that need a minimum path length should enforce that themselves.

## Development

```bash
bundle install
bundle exec rake test
bundle exec rubocop
```

## Releasing

1. Bump `Kml::Path::VERSION` in `lib/kml/path/version.rb`
2. Update `CHANGELOG.md`
3. Commit, tag (`v1.0.1`), and push the tag
4. GitHub Actions publishes to RubyGems when `RUBYGEMS_API_KEY` is configured

## License

MIT — see [LICENSE](LICENSE).
