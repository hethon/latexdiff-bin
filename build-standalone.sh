#!/usr/bin/env bash
# Build a standalone latexdiff executable with PAR::Packer
set -euo pipefail
cd "$(dirname "$0")"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) EXEEXT=".exe" ;;
  *)                    EXEEXT="" ;;
esac

OUT_DIR="build"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$OUT_DIR"

# Inline Algorithm::Diff (same logic as the Makefile's dist/latexdiff-so rule).
# The file must be named latexdiff-so: par-prelude.pl reads 'script/latexdiff-so'.
awk '/use Algorithm::Diff qw\(traverse_sequences\);/ { system("cat Algorithm-Diff-Block"); next } { print }' \
  latexdiff | grep -v '^###' > "$WORK_DIR/latexdiff-so"

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
  "$BIN" a.tex b.tex > diff.tex
  grep -q 'DIFadd' diff.tex || { echo "Smoke test failed: no DIFadd in output" >&2; exit 1; }
)
echo "Smoke test passed"

echo "Built $OUT_DIR/latexdiff${EXEEXT}"
