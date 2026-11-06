# latexdiff-bin

Unofficial prebuilt binaries of [latexdiff](https://github.com/ftilmann/latexdiff). No Perl installation needed.

## Install

**Linux / macOS:**
```bash
curl --proto '=https' --tlsv1.2 -LsSf https://raw.githubusercontent.com/hethon/latexdiff-bin/master/installers/installer.sh | sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/hethon/latexdiff-bin/installers/installer.ps1 | iex
```

Or download an archive from the [releases page](https://github.com/hethon/latexdiff-bin/releases).

## Supported Platforms

Linux (x86_64, aarch64), macOS (Intel, Apple Silicon), Windows (x86_64).

## Why

`latexdiff` is a Perl script, so you normally need to install Perl to use it, and usually a traditional TeX distribution like TeX Live or MiKTeX as well. These binaries are for people who use a different setup, such as [Tectonic](https://tectonic-typesetting.github.io/), and want to use `latexdiff` without installing Perl. They are the upstream script bundled with [PAR::Packer](https://metacpan.org/pod/PAR::Packer), so they run on their own.

## Notes

- These builds track stable upstream releases only.
- `latexdiff` uses `kpsewhich` to check which LaTeX packages are installed. If you don't have it (likely if you use Tectonic), you'll see a harmless warning, and some optional features, like mark-up inside verbatim environments, are turned off. The diff itself works normally.
- This repo is a thin packaging layer. The `latexdiff` source is upstream's, unmodified. Bugs in `latexdiff` itself belong [upstream](https://github.com/ftilmann/latexdiff/issues).

Upstream README: https://github.com/hethon/latexdiff-bin/blob/master/README.md
