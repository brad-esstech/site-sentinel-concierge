#!/bin/bash

echo "Checking Ubuntu version..."
lsb_release=$(lsb_release -rs)

if [[ ${lsb_release} != "22.04" ]]; then
  echo "ERROR: This script is designed for Ubuntu 22.04 Jammy Jellyfish. You're running ${lsb_release}."
  exit
fi
echo "version is OK (${lsb_release}). Continuing."

echo "Upgrading all the things..."
sudo apt-get -y update && sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

echo "Installing required libraries..."
sudo apt-get install -y ruby-bundler build-essential ruby-dev libevdev-dev libevdev-tools libudev0 python3-pip python3-rpi.gpio redis-server monit

echo "Setting timezone..."
sudo timedatectl set-timezone Australia/Perth

echo "Installing Ruby libraries..."
cd ~/site-sentinel-concierge
bundle install

echo "Setting up cron job for access list download..."
sudo systemctl enable cron
line="*/1 * * * * /usr/bin/ruby /home/ubuntu/site-sentinel-box-usb-readers/get_access_list.rb"
line="@reboot sleep 10 && /usr/bin/ruby /home/ubuntu/site-sentinel-concierge/concierge.rb"
line="@reboot sleep 10 && /usr/bin/ruby /home/ubuntu/site-sentinel-concierge/get_holidays.rb"
line="#@reboot sleep 10 && /usr/bin/ruby /home/ubuntu/site-sentinel-concierge-2/concierge.rb"
line="#@reboot sleep 10 && /usr/bin/ruby /home/ubuntu/site-sentinel-concierge-2/get_holidays."rb
line="#@reboot sleep 10 && /usr/bin/ruby /home/ubuntu/site-sentinel-concierge-3/concierge.rb"
line="#@reboot sleep 10 && /usr/bin/ruby /home/ubuntu/site-sentinel-concierge-3/get_holidays."rb
line="12 12 * * * /usr/bin/ruby /home/ubuntu/site-sentinel-concierge/get_holidays.rb"
line="12 12 * * * /usr/bin/ruby /home/ubuntu/site-sentinel-concierge/concierge.rb"
line="#12 12 * * * /usr/bin/ruby /home/ubuntu/site-sentinel-concierge-2/get_holidays.rb"
line="#12 12 * * * /usr/bin/ruby /home/ubuntu/site-sentinel-concierge-2/concierge.rb"
line="#12 12 * * * /usr/bin/ruby /home/ubuntu/site-sentinel-concierge-3/get_holidays.rb"
line="#12 12 * * * /usr/bin/ruby /home/ubuntu/site-sentinel-concierge-3/concierge.rb"
line=#@daily root find /home/ubuntu/site-sentinel-concierge/log/* -mtime +6 -type f -delete"
line=#@daily root find /home/ubuntu/site-sentinel-concierge-2/log/* -mtime +6 -type f -delete"
line="#@daily root find /home/ubuntu/site-sentinel-concierge-3/log/* -mtime +6 -type f -delete"
(crontab -u ubuntu -l; echo "$line" ) | crontab -u ubuntu -

echo "Allow Python to access GPIO ports..."
sudo chmod og+rwx /dev/gpio*

# Allow access to input devices (probably not needed now?)
# sudo usermod -a -G input ubuntu

echo "Setting up monit..."
sudo cp ~/site-sentinel-concierge/setup/monitrc /etc/monit/monitrc
sudo chmod 0700 /etc/monit/monitrc
sudo service monit restart

echo "Setting up Papertrail..."
cd ~/
wget -qO - --header="X-Papertrail-Token: 38vRUorKt0nhgjbmiaRJ" https://papertrailapp.com/destinations/37385845/setup.sh | sudo bash
wget https://github.com/papertrail/remote_syslog2/releases/download/v0.20/remote_syslog_linux_armhf.tar.gz
tar xzf ./remote_syslog*.tar.gz
cd remote_syslog
sudo cp ./remote_syslog /usr/local/bin
sleep 1
cd ~/
rm remote_syslog_linux_armhf.tar*
rm -rf remote_syslog
sudo cp ~/site-sentinel-concierge/setup/log_files.yml /etc/log_files.yml
sudo cp ~/site-sentinel-concierge/setup/remote_syslog.service /etc/systemd/system/remote_syslog.service
sudo systemctl enable remote_syslog.service
sudo systemctl start remote_syslog.service
