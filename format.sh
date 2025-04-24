#!/bin/bash
#=====================================================
# FORMAT SCRIPT
# Consistently formats all shell scripts in the repository
# using shfmt (https://github.com/mvdan/sh)
#=====================================================

# Check if shfmt is installed
if ! command -v shfmt &> /dev/null; then
    echo "Error: shfmt is not installed."
    echo "Please install it using one of the following methods:"
    echo "  - Go: go install mvdan.cc/sh/v3/cmd/shfmt@latest"
    echo "  - Homebrew: brew install shfmt"
    echo "  - Ubuntu/Debian: sudo apt install shfmt"
    exit 1
fi

# Format all shell scripts in the repository
echo "Formatting shell scripts..."

# Options for shfmt:
# -i 4: Use 4 spaces for indentation
# -bn: Binary ops like && and | may start a line
# -ci: Switch cases are indented
# -sr: Redirect operators are followed by a space
SHFMT_OPTS="-i 4 -bn -ci -sr"

# Find and format all .sh files
find . -name "*.sh" -type f -exec echo "Formatting {}" \; -exec shfmt -w $SHFMT_OPTS {} \;

echo "Formatting complete!"
