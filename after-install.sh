#!/usr/bin/env bash

systemctl disable osd
systemctl enable openhdconfig
systemctl enable openhd_system
systemctl enable openhd_security
systemctl enable openhd_interface
systemctl enable openhd_telemetry@microservice
systemctl enable openhd_telemetry@telemetry

# this is the serial port on the jetson boards, we don't want a tty running on it
systemctl stop nvgetty || true
systemctl disable nvgetty || true


mkdir -p /wbc_tmp
mkdir -p /media/usb

# crude hack to avoid making people put fonts somewhere else
cp -a /usr/local/share/openhd/osdfonts/*.ttf /boot/osdfonts/ > /dev/null 2>&1 || true

# these are intentionally written with spaces around them to avoid false negatives if people
# edit the fstab file and change the rest of the line, the way these are written it will still
# find them as long as a line for each of these mountpoints is present
grep " /tmp " /etc/fstab
if [[ "$?" -ne 0 ]]; then
    echo "tmpfs /tmp tmpfs nosuid,nodev,noatime,size=50M 0 0" >> /etc/fstab
fi

grep " /var/log " /etc/fstab
if [[ "$?" -ne 0 ]]; then
    echo "tmpfs /var/log tmpfs nosuid,nodev,noatime,size=50M 0 0" >> /etc/fstab
fi

grep " /var/tmp " /etc/fstab
if [[ "$?" -ne 0 ]]; then
    echo "tmpfs /var/tmp tmpfs nosuid,nodev,noatime,size=50M 0 0" >> /etc/fstab
fi


# enable the loopback module if it isn't already, so that seek and flir cameras can be used
grep "v4l2loopback" /etc/modules
if [[ "$?" -ne 0 ]]; then
    echo "v4l2loopback" >> /etc/modules
fi


mount -oremount,ro /boot || true
