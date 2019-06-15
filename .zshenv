
#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi


export TERM=xterm-256color

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin"
export ALTERNATE_EDITOR=v
export VISUAL=v
export EDITOR="$VISUAL"
export PATH="${HOME}/.npm-packages/bin:$PATH"

export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo)

export SPACESHIP_CHAR_SYMBOL="⌘";
export PURE_PROMPT_SYMBOL="⌘"

export PATH="$HOME/.jenv/bin:$PATH"
export JAVA_HOME="$HOME/.jenv/versions/`jenv version-name`"
