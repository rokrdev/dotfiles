#!/usr/bin/env fish
# secrets — manage local environment secrets
# Usage: secrets [show|edit|list]

function secrets
    set -l action "$argv[1]"
    set -l env_file "$HOME/.env.local"

    switch "$action"
        case show
            if test -f "$env_file"
                echo "Current ~/.env.local secrets:"
                cat "$env_file"
            else
                echo "No ~/.env.local file found. Create one to get started."
            end

        case edit
            if test -f "$env_file"
                $EDITOR "$env_file"
                echo "Updated ~/.env.local. Restart fish or run: source ~/.env.local"
            else
                echo "No ~/.env.local file found."
                echo "Create one with: touch ~/.env.local && secrets edit"
            end

        case list
            if test -f "$env_file"
                echo "Environment variables from ~/.env.local:"
                grep -E '^\s*[A-Z_]+=' "$env_file" | sed 's/=.*//' | sort
            else
                echo "No ~/.env.local file found."
            end

        case ''
            echo "Secret management for dotfiles"
            echo ""
            echo "Usage: secrets [command]"
            echo ""
            echo "Commands:"
            echo "  show    Display all secrets from ~/.env.local"
            echo "  edit    Open ~/.env.local in your editor"
            echo "  list    List secret variable names (values hidden)"
            echo ""
            echo "Setup:"
            echo "  1. Create ~/.env.local with your secrets"
            echo "  2. Add to .gitignore (already done in this repo)"
            echo "  3. fish config automatically sources it on startup"
            echo ""
            echo "Example ~/.env.local:"
            echo "  export API_KEY='your-secret-key'"
            echo "  export DB_PASSWORD='your-password'"
            echo "  export GITHUB_TOKEN='your-token'"

        case '*'
            echo "Unknown command: $action"
            secrets
    end
end
