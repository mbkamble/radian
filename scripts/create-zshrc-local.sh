#!/bin/bash

set -e
set -o pipefail

echo "[create-zshrc-local] Setting up .zshrc.local."
contents=$(cat <<'EOF'
# This file is run at the very end of .zshrc, so you can use it to
# override things or add your own customizations.
EOF
        )
contents="$contents"$'\n'

if [[ $EDITOR ]]; then
    echo "[create-zshrc-local] You currently have \$EDITOR set to $EDITOR."
    echo -n "[create-zshrc-local] Would you like to carry this over to .zshrc.local? (y/n) "
    read answer
    if (echo "$answer" | grep -qi "^y"); then
        contents="$contents"$'\n'"export EDITOR='$EDITOR'"$'\n'
    fi
fi

echo -n "$contents" > ../../dotfiles-local/.zshrc.local
echo "[create-zshrc-local] Wrote the following to dotfiles-local/.zshrc.local:"
cat ../../dotfiles-local/.zshrc.local