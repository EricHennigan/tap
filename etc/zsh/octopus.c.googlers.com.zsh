source /etc/bash_completion.d/g4d
#source /etc/bash_completion.d/flag_completion.sh
set show-all-if-ambiguous on

# appengine
# source $HOME/software/google-cloud-sdk/completion.zsh.inc
# source $HOME/software/google-cloud-sdk/path.zsh.inc

if ! gcertstatus -quiet; then
  echo "Gcert required for loading sandbox_rc. Running gcert..."
  gcert -reuse_sso_cookie --prodssh
fi
source /google/data/ro/teams/health-research/tools/sandbox_rc
source ~/tap/etc/zsh/googlers.com.zsh

# go/ml-bashrc xmanager
if [ -r /google/data/ro/teams/brain-frameworks/config/ml_bashrc ] ; then
  source /google/data/ro/teams/brain-frameworks/config/ml_bashrc
fi

# go/sax-get-started
if [[ -r /google/data/ro/teams/dmgi/configs/google_xm_bashrc ]] ; then
  source /google/data/ro/teams/dmgi/configs/google_xm_bashrc
fi

alias jetski='/google/bin/releases/jetski-devs/jetski-web/run_jetski.par'
