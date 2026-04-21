# zsh Options
setopt HIST_IGNORE_ALL_DUPS

# Custom zsh (OS-agnostic - loaded based on symlink target)
[ -f "$HOME/.config/zsh/custom.zsh" ] && source "$HOME/.config/zsh/custom.zsh"

# Aliases
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# Work
[ -f "$HOME/.config/zsh/work.zsh" ] && source "$HOME/.config/zsh/work.zsh"

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# nvm (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Flutter (if installed)
if [ -d "$HOME/develop/flutter/bin" ]; then
    export PATH="$HOME/develop/flutter/bin:$PATH"
fi

# Android SDK (if installed)
if [ -d "$HOME/Android/Sdk" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
    export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"
elif [ -d "$HOME/Library/Android/sdk" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"
fi

# Local bin (for pip installed tools)
export PATH="$HOME/.local/bin:$PATH"
# opencode
export PATH=/Users/tadashi/.opencode/bin:$PATH
