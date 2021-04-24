
source "$HOME/tap/etc/zsh/erich-ims.zsh"
export PATH="/opt/rave/lib:/opt/rave/client:$PATH"

#================
# Rave helper functions
#----------------

alias rave-power="/opt/rave/client/PwrControl"
alias rave-network="/opt/rave/lib/networkConfig.py"

function rave-ssh {
  ssh root@172.168.0.10
}

function rave-start-servers {
  sudo ls >/dev/null || return
  /opt/rave/kraken_server/app_kraken_server.py -v sdu_audio_fixture -l /home/erich/krakenLogs/sdu_audio_fixture.log&
  /opt/rave/kraken_server/app_kraken_server.py -v phidget -l /home/erich/krakenLogs/phidget.log&
}

function rave-start-client {
  sudo touch kraken_debug.log
  sudo chmod a+w kraken_debug.log
  ./app_kraken_client.py -g qt sdu $2 --title "TESTING" --timeout 120 --lru $1 -v -l /home/erich/krakenLogs/client_sdu.log --power phidget
}
