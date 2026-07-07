#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# validate-all.sh
# Validates all Terraform modules, environments, and examples
# ---------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

ERRORS=0

validate_directory() {
    local dir=$1
    local label=$2

    echo "  -> $dir"
    if ! terraform -chdir="$dir" init -backend=false -input=false > /dev/null 2>&1; then
        echo "     ❌ init failed"
        ERRORS=$((ERRORS + 1))
        return
    fi

    if ! terraform -chdir="$dir" validate > /dev/null 2>&1; then
        echo "     ❌ validate failed"
        terraform -chdir="$dir" validate 2>&1 | sed 's/^/     /'
        ERRORS=$((ERRORS + 1))
    else
        echo "     ✅ valid"
    fi
}

echo "============================================"
echo " Terraform Validation"
echo "============================================"
echo ""

# Format check
echo "==> Checking format..."
if terraform fmt -recursive -check "$ROOT_DIR" > /dev/null 2>&1; then
    echo "  ✅ All files formatted correctly"
else
    echo "  ❌ Format issues found. Run 'terraform fmt -recursive'"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Modules
echo "==> Validating modules..."
for dir in "$ROOT_DIR"/modules/*/; do
    if [ -d "$dir" ]; then
        validate_directory "$dir" "module"
    fi
done
echo ""

# Environments
echo "==> Validating environments..."
for dir in "$ROOT_DIR"/environments/*/; do
    if [ -d "$dir" ]; then
        validate_directory "$dir" "environment"
    fi
done
echo ""

# Examples
echo "==> Validating examples..."
for dir in "$ROOT_DIR"/examples/*/; do
    if [ -d "$dir" ]; then
        validate_directory "$dir" "example"
    fi
done
echo ""

echo "============================================"
if [ $ERRORS -eq 0 ]; then
    echo " ✅ All validations passed"
else
    echo " ❌ $ERRORS validation(s) failed"
fi
echo "============================================"

exit $ERRORS
