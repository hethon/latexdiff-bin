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

> [!NOTE]
> The install scripts are generated with [ingen](https://github.com/hethon/ingen). They download the build for your platform from this repo's [releases](../../releases), verify its checksum, and install it to `$HOME/.local/bin`. You can read the scripts in the [`installers`](../installers) folder.

Then use it like this:

```bash
latexdiff old.tex new.tex > diff.tex
```

Compile the diff:

```bash
tectonic diff.tex
```

## Supported Platforms

Linux (x86_64, aarch64), macOS (Intel, Apple Silicon), Windows (x86_64).

## Why

`latexdiff` is a Perl script, so you normally need to install Perl to use it, and usually a traditional TeX distribution like TeX Live or MiKTeX as well. These binaries are for people who use a different setup, such as [Tectonic](https://tectonic-typesetting.github.io/), and want to use `latexdiff` without installing Perl. They are the upstream script bundled with [PAR::Packer](https://metacpan.org/pod/PAR::Packer), so they run on their own.

## Notes

- The generated diff file always loads `listings`, so changes inside verbatim environments are shown. Compiling the diff file requires `listings` to be available (Tectonic fetches it automatically).
- This repo is a thin packaging layer. The `latexdiff` source is upstream's, unmodified. Bugs in `latexdiff` itself belong [upstream](https://github.com/ftilmann/latexdiff/issues).

## Versioning

- These builds track upstream releases starting from version 1.4.0.
- Release tags follow upstream's version. A tag like `v1.4.0-1` is the second packaging revision of upstream `1.4.0`: the `latexdiff` source is the same, and only the build or packaging changed. Use the highest revision for a given version.

Upstream README: https://github.com/hethon/latexdiff-bin/blob/master/README.md
