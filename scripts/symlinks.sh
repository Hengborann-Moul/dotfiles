#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_FILE="$SCRIPT_DIR/../symlinks.conf"

. "$SCRIPT_DIR/utils.sh"

# Default OS value
OS=""

# Check if configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

create_symlinks() {
    info "Creating symbolic links for $OS..."

    # Read dotfile links from the config file
    while IFS=: read -r source target os_marker || [ -n "$source" ]; do

        # Skip empty or invalid lines in the config file
        if [[ -z "$source" || -z "$target" || "$source" == \#* ]]; then
            continue
        fi

        # Check OS marker (if present)
        if [[ -n "$os_marker" && "$os_marker" != "$OS" ]]; then
            # Skip this entry - OS marker doesn't match
            continue
        fi

        # Evaluate variables
        source=$(eval echo "$source")
        target=$(eval echo "$target")

        # Check if the source file exists
        if [ ! -e "$source" ]; then
            error "Error: Source file '$source' not found. Skipping link creation for '$target'."
            continue
        fi

        # Check if the symbolic link already exists
        if [ -L "$target" ]; then
            warning "Symbolic link already exists: $target"
        elif [ -f "$target" ]; then
            warning "File already exists: $target"
        else
            # Extract the directory portion of the target path
            target_dir=$(dirname "$target")

            # Check if the target directory exists, and if not, create it
            if [ ! -d "$target_dir" ]; then
                mkdir -p "$target_dir"
                info "Created directory: $target_dir"
            fi

            # Create the symbolic link
            ln -s "$source" "$target"
            success "Created symbolic link: $target"
        fi
    done <"$CONFIG_FILE"
}

delete_symlinks() {
    info "Deleting symbolic links for $OS..."

    while IFS=: read -r _ target os_marker || [ -n "$target" ]; do

        # Skip empty and invalid lines
        if [[ -z "$target" ]]; then
            continue
        fi

        # Check OS marker (if present)
        if [[ -n "$os_marker" && "$os_marker" != "$OS" ]]; then
            # Skip this entry - OS marker doesn't match
            continue
        fi

        # Evaluate variables
        target=$(eval echo "$target")

        # Check if the symbolic link or file exists
        if [ -L "$target" ] || { [ "$include_files" == true ] && [ -f "$target" ]; }; then
            # Remove the symbolic link or file
            rm -rf "$target"
            success "Deleted: $target"
        else
            warning "Not found: $target"
        fi
    done <"$CONFIG_FILE"
}

# Parse arguments
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    # Default OS to mac if not specified
    if [[ -z "$OS" ]]; then
        # Detect OS
        case "$(uname -s)" in
            Darwin*)
                OS="mac"
                ;;
            Linux*)
                OS="ubuntu"
                ;;
            *)
                error "Unsupported OS: $(uname -s)"
                exit 1
                ;;
        esac
    fi

    case "$1" in
    "--create")
        if [[ "$2" == "--os" && -n "$3" ]]; then
            OS="$3"
            shift 3
        fi
        create_symlinks
        ;;
    "--delete")
        if [[ "$2" == "--os" && -n "$3" ]]; then
            OS="$3"
            shift 3
        fi
        if [ "$2" == "--include-files" ]; then
            include_files=true
        fi
        delete_symlinks
        ;;
    "--help")
        # Display usage/help message
        echo "Usage: $0 [--create | --delete] [--os <mac|ubuntu>] [--include-files] [--help]"
        echo ""
        echo "Options:"
        echo "  --create           Create symbolic links"
        echo "  --delete           Delete symbolic links"
        echo "  --os <os>          Operating system (mac|ubuntu). Default: auto-detect"
        echo "  --include-files    Delete actual files along with symlinks (use with --delete)"
        echo "  --help             Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 --create                    # Create symlinks (auto-detect OS)"
        echo "  $0 --create --os mac           # Create symlinks for macOS"
        echo "  $0 --delete --os ubuntu        # Delete symlinks for Ubuntu"
        echo "  $0 --delete --include-files    # Delete symlinks and files"
        ;;
    *)
        # Display an error message for unknown arguments
        error "Error: Unknown argument '$1'"
        error "Usage: $0 [--create | --delete [--include-files] [--os <mac|ubuntu>]] | --help]"
        exit 1
        ;;
    esac
fi