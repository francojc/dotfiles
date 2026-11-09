# ~/.bash_profile -- managed by stow from ~/.dotfiles (edit it there).
#
# Bash reads this file (not ~/.profile) for login shells, so login-only setup
# lives here. Interactive setup stays in ~/.bashrc.

# Increase the max open files limit (was in the zsh .zprofile).
ulimit -n 10240 2>/dev/null

[[ -f ~/.bashrc ]] && . ~/.bashrc
