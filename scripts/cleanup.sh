# Cleanups
apt dist-upgrade --yes
#apt install --yes --reinstall --purge gnome-shell-extension-desktop-icons-ng gnome-shell-extension-manager
xdg-desktop-menu forceupdate

echo "" > /etc/resolv.conf
rm -f /etc/apt/apt.conf.d/00proxy
apt clean
apt purge --auto-remove -y

rm -rf /tmp/*
#rm -rf /var/cache/apt-xapian-index/*
rm -rf /var/lib/apt/lists/*
service dbus stop
sleep 2
umount -l /proc/sys/fs/binfmt_misc || true
umount -l /sys
umount -l /dev/pts
umount -l /proc
#end of chroot
exit