# Change the current user's shell
change-shell:
    #!/usr/bin/env bash
    set -euo pipefail

    # Detect available shells in /usr/bin
    declare -a available_shells=()
    declare -a shell_paths=()

    # Check for common shells
    for shell in bash zsh fish dash ksh tcsh; do
        shell_path="/usr/bin/$shell"
        if [ -x "$shell_path" ]; then
            available_shells+=("$shell")
            shell_paths+=("$shell_path")
        fi
    done

    # Check if any shells were found
    if [ ${#available_shells[@]} -eq 0 ]; then
        echo "Error: No common shells found in /usr/bin"
        exit 1
    fi

    # Display menu
    echo "Available shells:"
    for i in "${!available_shells[@]}"; do
        idx=$((i + 1))
        echo "$idx) ${available_shells[$i]} (${shell_paths[$i]})"
    done
    custom_idx=$((${#available_shells[@]} + 1))
    echo "$custom_idx) custom (enter full path)"
    echo ""

    read -p "Select shell (1-$custom_idx): " choice

    # Validate choice
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Invalid choice. Exiting."
        exit 1
    fi

    if [ "$choice" -eq "$custom_idx" ]; then
        read -p "Enter full path to shell executable: " SHELL_PATH
    elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#available_shells[@]}" ]; then
        array_idx=$((choice - 1))
        SHELL_PATH="${shell_paths[$array_idx]}"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi

    # Verify the shell exists
    if [ ! -x "$SHELL_PATH" ]; then
        echo "Error: Shell not found or not executable at $SHELL_PATH"
        echo "You may need to install it first."
        exit 1
    fi

    # Verify shell is in /etc/shells
    if ! grep -q "^${SHELL_PATH}$" /etc/shells 2>/dev/null; then
        echo "Warning: $SHELL_PATH is not listed in /etc/shells"
        read -p "Add it to /etc/shells? (y/n): " add_shell
        if [[ "$add_shell" =~ ^[Yy]$ ]]; then
            echo "$SHELL_PATH" | sudo tee -a /etc/shells > /dev/null
            echo "Added $SHELL_PATH to /etc/shells"
        else
            echo "Shell must be in /etc/shells to proceed. Exiting."
            exit 1
        fi
    fi

    # Change the shell
    echo "Changing shell for user $USER to $SHELL_PATH"
    sudo usermod --shell "$SHELL_PATH" "$USER"

    echo ""
    echo "✓ Shell changed successfully to $SHELL_PATH"
    echo "Please log out and log back in for changes to take effect."
