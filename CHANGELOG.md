# 1.0.0

Initial release.

- Parse `LineString` and `gx:Track` geometry from KML and KMZ uploads
- `#parse` returns a `Kml::Path::Result`; `#parse!` raises `Kml::Path::ParseError` on failure
- Shipped fixture files and `Kml::Path::Fixtures` helper for consumer tests
