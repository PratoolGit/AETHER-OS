# AETHER interactive shell defaults.
# Also load these aliases in non-login terminals such as XFCE Terminal.
if [[ $- == *i* ]] && [[ -r /etc/profile.d/aether-aliases.sh ]]; then
  source /etc/profile.d/aether-aliases.sh
fi

export EDITOR=nano
