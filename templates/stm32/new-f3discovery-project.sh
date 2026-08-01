#!/usr/bin/env bash
# Scaffolds a new bare-CMSIS STM32F3Discovery (STM32F303VCT6) project.
#
# Vendored from verified upstream sources:
#   - CMSIS core headers:    STMicroelectronics/STM32CubeF3 (Drivers/CMSIS/Include)
#   - CMSIS device headers:  STMicroelectronics/cmsis_device_f3
#   - Startup file + linker: STMicroelectronics/STM32CubeF3
#                            (Projects/STM32F3-Discovery/Templates/SW4STM32)
#
# Usage: new-f3discovery-project.sh <project-name> [parent-dir]
set -euo pipefail

# Resolve SCRIPT_DIR through any symlinks, so this works when invoked via a
# symlink on PATH (e.g. ~/.local/bin/new-f3). Handles chained symlinks and
# relative link targets; avoids `readlink -f`, which is missing on older macOS.
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

VENDOR_DIR="$SCRIPT_DIR/vendor/f3discovery"

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") <project-name> [parent-dir]" >&2
  exit 1
fi

PROJECT_NAME="$1"
PARENT_DIR="${2:-.}"

if [ ! -d "$PARENT_DIR" ]; then
  echo "Error: parent directory '$PARENT_DIR' does not exist." >&2
  echo "       Pass only the parent in the second argument - the project" >&2
  echo "       directory itself is created from <project-name>." >&2
  exit 1
fi

# Absolute path, so the 'Next steps' output below is copy-pasteable.
PROJECT_DIR="$(cd "$PARENT_DIR" && pwd)/$PROJECT_NAME"

if [ -e "$PROJECT_DIR" ]; then
  echo "Error: $PROJECT_DIR already exists" >&2
  exit 1
fi

cp -r "$VENDOR_DIR" "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/Core/Inc"
# Rename the Makefile's TARGET to match the project name.
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/^TARGET = firmware/TARGET = $PROJECT_NAME/" "$PROJECT_DIR/Makefile"
else
  sed -i "s/^TARGET = firmware/TARGET = $PROJECT_NAME/" "$PROJECT_DIR/Makefile"
fi
# Drop in the clangd cross-compilation config.
cp "$SCRIPT_DIR/.clangd" "$PROJECT_DIR/.clangd"
cat > "$PROJECT_DIR/.gitignore" <<'EOF'
build/
compile_commands.json
EOF
echo "Created $PROJECT_DIR"
echo
if command -v compiledb >/dev/null 2>&1; then
  echo "Building once and generating compile_commands.json..."
  (cd "$PROJECT_DIR" && compiledb make)
else
  echo "compiledb not found on PATH - skipping initial build/compile_commands.json generation."
  echo "Install it (brew install compiledb) then run 'compiledb make' inside the project."
fi
echo
echo "Next steps:"
echo "  cd $PROJECT_DIR"
echo "  nvim Core/Src/main.c    # LD3 (PE8) blink skeleton is already wired up"
echo "  make flash              # flash via OpenOCD (plug the board in via its ST-Link USB port)"
echo
echo "Re-run 'compiledb make' whenever you add/remove source files, so clangd stays in sync."
