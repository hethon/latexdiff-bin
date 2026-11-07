# Changelog

Changes to these builds. For changes to `latexdiff` itself, see upstream's changelog.

## v1.4.0-1

- Patched `latexdiff` at build time to always assume `listings` is available, so it no longer needs `kpsewhich` and no longer prints errors when it is missing.
- The generated diff file now always loads `listings`.

## v1.4.0

- First release: standalone executables for Linux (x86_64, aarch64), macOS (Intel, Apple Silicon) and Windows (x86_64).
