#!/usr/bin/env bash
# Build a standalone latexdiff executable with PAR::Packer
set -euo pipefail
cd "$(dirname "$0")"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) EXEEXT=".exe" ;;
  *)                    EXEEXT="" ;;
esac

# Windows (Git Bash): make sure Strawberry Perl comes before Git's bundled Perl.
if [ "$EXEEXT" = ".exe" ] && [ -d /c/Strawberry ]; then
  export PATH="/c/Strawberry/perl/bin:/c/Strawberry/perl/site/bin:/c/Strawberry/c/bin:$PATH"
fi

# Install PAR::Packer for the *active* perl if it isn't available yet.
# (Don't test for `pp` on PATH: macOS ships a /usr/bin/pp tied to the system perl.)
if ! perl -MPAR::Packer -e1 >/dev/null 2>&1; then
  mkdir -p "${PERL_CPANM_HOME:-$HOME/.cpanm}"
  cpanm --notest PAR::Packer
fi

OUT_DIR="build"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$OUT_DIR"

# Inline Algorithm::Diff (same logic as the Makefile's dist/latexdiff-so rule).
# The file must be named latexdiff-so: par-prelude.pl reads 'script/latexdiff-so'.
awk '/use Algorithm::Diff qw\(traverse_sequences\);/ { system("cat Algorithm-Diff-Block"); next } { print }' \
  latexdiff | grep -v '^###' > "$WORK_DIR/latexdiff-so"

# Always enable mark-up in verbatim environments, so latexdiff never calls kpsewhich.
PATTERN='if ( defined( $packages{"listings"} ) or `kpsewhich listings.sty` ne "" ) {'
grep -qF -- "$PATTERN" "$WORK_DIR/latexdiff-so" || { echo "listings patch: pattern not found" >&2; exit 1; }
sed 's/if ( defined( $packages{"listings"} ) or `kpsewhich listings\.sty` ne "" ) {/if ( 1 ) {/' \
  "$WORK_DIR/latexdiff-so" > "$WORK_DIR/latexdiff-so.patched"
mv "$WORK_DIR/latexdiff-so.patched" "$WORK_DIR/latexdiff-so"

# Insert par-prelude.pl after the shebang line, so DATA is reopened inside the packed binary.
{
  head -n 1 "$WORK_DIR/latexdiff-so"
  cat par-prelude.pl
  tail -n +2 "$WORK_DIR/latexdiff-so"
} > "$WORK_DIR/latexdiff-so.prelude"
mv "$WORK_DIR/latexdiff-so.prelude" "$WORK_DIR/latexdiff-so"

# Pack.
pp -o "$OUT_DIR/latexdiff${EXEEXT}" "$WORK_DIR/latexdiff-so"

# Smoke test. The diff run exercises the preamble styles stored in the DATA
# section, so it catches a broken par-prelude.pl, not just a binary that starts.
BIN="$PWD/$OUT_DIR/latexdiff${EXEEXT}"
"$BIN" --version

(
  cd "$WORK_DIR"
  printf '\\documentclass{article}\n\\begin{document}\nHello\n\\end{document}\n' > a.tex
  printf '\\documentclass{article}\n\\begin{document}\nHello world\n\\end{document}\n' > b.tex
  if err=$("$BIN" a.tex b.tex 2>&1 >diff.tex) && [ -n "$err" ]; then
      echo -e "Smoke test failed: unexpected stderr output:\n$err" >&2
      exit 1
  fi
  grep -q 'DIFadd' diff.tex || { echo "Smoke test failed: no DIFadd in output" >&2; exit 1; }
  grep -q 'lstnewenvironment' diff.tex || { echo "Smoke test failed: listings preamble missing" >&2; exit 1; }
)
echo "Smoke test passed"

echo "Built $OUT_DIR/latexdiff${EXEEXT}"
