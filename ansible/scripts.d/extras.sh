#!/bin/bash
set -eo pipefail

# install google cloud SDK to replace snap version

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt-get update && sudo apt-get install google-cloud-cli

cd /opt/apps

wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.11_amd64.deb
apt-get install ./libssl1.0.0_1.0.2n-1ubuntu5.11_amd64.deb

# Install Parse
# gcloud storage cp gs://conception-automation-misc/software/ParseBiosciences-Pipeline.1.0.2p.tar.gz .
# tar -xzvf ParseBiosciences-Pipeline.1.0.2p.tar.gz
# pip3 install /opt/apps/ParseBiosciences-Pipeline.1.0.2p/

#CLEANUP
cd /opt/apps
rm -f *.gz
rm -f *.zip

#install pip2
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
python2 get-pip.py
rm get-pip.py

pip3 install --upgrade requests