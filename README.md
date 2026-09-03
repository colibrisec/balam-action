# balam-action

GitHub Action that uploads a scan report (Trivy, Semgrep, SARIF, ojo, or any format
[Balam](https://github.com/colibrisec/balam) parses) to Balam via `reimport-scan`.
Nothing else — run your scanner first, then point this at the report it produced.

## Usage

```yaml
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # ... run your scanner, produce report.json ...
      - uses: colibrisec/balam-action@v1
        with:
          file: report.json
          scan-type: 'Trivy Scan'
          balam-url: https://balam.example.com
          balam-token: ${{ secrets.BALAM_TOKEN }}
          product-name: my-app
          engagement-name: main
```

Mint `balam-token` as a personal API token in Balam and store it as a repo/org secret.

## Inputs

| Input | Required | Notes |
| --- | --- | --- |
| `file` | yes | Path to the report to upload |
| `scan-type` | yes | Balam `scan_type`, e.g. `Trivy Scan`, `Semgrep JSON Report`, `SARIF`, `OJO Scan` — see Balam's supported parsers |
| `balam-url` | yes | Balam base URL |
| `balam-token` | yes | Balam personal API token — pass via a secret |
| `product-name` / `product-id` | one of | Name auto-creates the product |
| `engagement-name` / `engagement-id` | one of | Name auto-creates the engagement |
| `product-type-name` | no | |
| `test-title` | no | |

## Development

```console
$ bash test/test_upload.sh
```

## License

[GPL-2.0](LICENSE), matching Balam's own license.
