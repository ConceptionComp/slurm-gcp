#!/bin/bash
set -eo pipefail

CHROME_DRIVER_VERSION=111.0.5563.64

# Install Chrome Binary
wget --no-verbose -O /tmp/chrome.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_DRIVER_VERSION}-1_amd64.deb
apt install -y /tmp/chrome.deb
rm /tmp/chrome.deb
# curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
# echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
# apt-get -y update
# apt-get -y install google-chrome-stable

# Install ChromeDriver

wget -N https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/
unzip ~/chromedriver_linux64.zip -d ~/
rm ~/chromedriver_linux64.zip
mv -f ~/chromedriver /usr/local/bin/chromedriver
chown root:root /usr/local/bin/chromedriver
chmod 0755 /usr/local/bin/chromedriver