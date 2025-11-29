#!/bin/bash -e
#remove Unity and accompaning packages
set -x
PS4='Line ${LINENO}: '
bash
apt install -y tasksel
apt purge -y unity* compiz* gnome* ubuntuone* accountsservice-*
#remove some privacy concerned packages
apt-get --yes install ${desktop_system}
echo DONE
apt -y autoremove --purge