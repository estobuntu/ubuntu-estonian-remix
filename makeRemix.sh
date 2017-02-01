#!/bin/bash -e
# Ubuntu - Estonian Remix CD 
#
# based on Finnish remix http://bazaar.launchpad.net/~timo-jyrinki/ubuntu-fi-remix/main/files
#
# License CC-BY-SA 3.0: http://creativecommons.org/licenses/by-sa/3.0/

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#local apt-cacher-ng url
proxy_url="http://127.0.0.1:3142"

#input ISO file 
export iso_file=ubuntu-16.04.1-desktop-amd64.iso

#output ISO file
export output_file=ubuntu-16.04.1-amd64-estremix.iso

#visible name of the disk in file explorer
export IMAGE_NAME="Ubuntu Estonian Remix 16.04.1 LTS amd64"

if [ ! -f $iso_file ]; then
  echo No input ISO file. 
  exit
fi

dialog --title "Ubuntu - Estonian CD remix creation" --msgbox "\nexpecting following input ISO files: $iso_file\n\noutput will be: $output_file" 22 76


cmd=(dialog --separate-output --checklist "Select remix options:" 22 76 16)
options=(ID "Install Estonian ID Software" on    # any option can be set to default to "on"
         EST "Filosoft speller for LibreOffice and Estonian langpakcs" on
         LO "Newest LibreOffice software" off
         MATE "Set MATE as desktop environment (remove Unity)" off
	 EXTRA "Video players, codecs, for kids etc" off
	 PROXY "Use local apt-cacher-ng proxy" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        ID)
            ID=1
            ;;
        LO)
            LO=1
            ;;
        EST)
            EST=1
            ;;
        MATE)
            MATE=1
            ;;
        EXTRA)
            EXTRA=1
            ;;
        PROXY)
            PROXY=1
            ;;
    esac
done



echo "removing old directories"
rm -rf edit/ extract-cd/ mnt/ squashfs/
echo Extracting image 
mkdir mnt
mount -o loop ${iso_file} mnt/
mkdir extract-cd
rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd
mkdir squashfs
echo Extracting liveFS
mount -t squashfs -o loop mnt/casper/filesystem.squashfs squashfs
mkdir edit
cp -a squashfs/* edit/
# NOTE: LiveCDCustomization wiki page uses another method nowadays
# sudo unsquashfs mnt/casper/filesystem.squashfs
# sudo mv squashfs-root edit
# I've not noticed difference in the end result, cp seems faster
mount --bind /dev/ edit/dev
cp oofslinget-addon-estobuntu_4.1-0_all.deb edit/tmp/
#cp splash.pcx extract-cd/isolinux/splash.pcx

echo Chrooting and executing upgrade tasks
cat > edit/tmp/addID.sh << ENDSCRIPT
#add ID-card repository GPG key
apt-key add <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: GPGTools - https://gpgtools.org

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
K2czbpReKw==
=aSyh
-----END PGP PUBLIC KEY BLOCK-----
EOF
cat >> /etc/apt/sources.list.d/estID.list <<EOF
deb https://installer.id.ee/media/ubuntu/ xenial main
EOF
apt update
#install Estonian ID-card packages
apt install -y open-eid
ENDSCRIPT
cat > edit/tmp/prepare.sh << ENDSCRIPT
#!/bin/bash -e
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
export HOME=/root
export LC_ALL=C
#needed for some package installation
service dbus start

#configure connectivity
echo "nameserver 8.8.8.8" > /etc/resolv.conf

#add repositories
cat >> /etc/apt/sources.list.d/estmix.list <<EOF
deb http://ftp.estpak.ee/pub/ubuntu/ xenial universe
deb http://ftp.estpak.ee/pub/ubuntu/ xenial-updates universe
deb http://ftp.estpak.ee/pub/ubuntu/ xenial multiverse
deb http://ftp.estpak.ee/pub/ubuntu/ xenial-updates multiverse
deb http://archive.canonical.com/ubuntu xenial partner
deb http://ftp.estpak.ee/pub/ubuntu/ xenial-security universe
deb http://ftp.estpak.ee/pub/ubuntu/ xenial-security multiverse
EOF

#update package lists
apt update

ENDSCRIPT

cat > edit/tmp/libreoffice.sh << ENDSCRIPT

#newest libreoffice
add-apt-repository -y ppa:libreoffice/ppa && apt-get update && apt-get -y dist-upgrade && apt-get -y install libreoffice libreoffice-help-et libreoffice-l10n-et libreoffice-pdfimport libreoffice-nlpsolver libreoffice-ogltrans libreoffice-report-builder libreoffice-style-galaxy libreoffice-templates && apt-get -y remove libreoffice-style-tango && ldconfig && dpkg --configure -a && apt-get clean
ENDSCRIPT


cat > edit/tmp/estonian_packages.sh << ENDSCRIPT
# Estonian (basic support)
apt install -y language-pack-et language-pack-et-base language-pack-gnome-et language-pack-gnome-et-base libreoffice-l10n-et firefox-locale-et libreoffice-help-et thunderbird-locale-et libreoffice-java-common
dpkg -i tmp/oofslinget-addon-estobuntu_4.1-0_all.deb
ENDSCRIPT

cat > edit/tmp/mate.sh << ENDSCRIPT
#remove Unity and accompaning packages
apt install -y tasksel
apt purge -y unity* compiz* gnome* ubuntuone* accountsservice-*
#remove some privacy concerned packages
apt -y autoremove --purge activity-log-manager-common python-zeitgeist rhythmbox-plugin-zeitgeist zeitgeist zeitgeist-core zeitgeist-datahub
tasksel install ubuntu-mate-desktop
apt -y autoremove

#install MATE
#apt install -y ubuntu-mate-desktop
ENDSCRIPT

cat > edit/tmp/extra.sh << ENDSCRIPT
#extra packages, like mediaplayer packages, browser and gimp
apt -y install libdvdcss2 vlc mplayer mplayer-fonts smplayer smtube smplayer-themes smplayer-l10n cups-pdf gimp gimp-data-extras inkscape chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg-extra pepperflashplugin-nonfree xournal ffmpeg mc pavucontrol radiotray python-xdg
cd /tmp
wget https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb
apt install -y libpango1.0-0 
dpkg -i google-talkplugin_current_amd64.deb

#fun for kids
apt -y install  tuxpaint tuxpaint-config tuxpaint-plugins-default tuxtype childsplay childsplay-alphabet-sounds-en-gb gcompris gcompris-sound-en

ENDSCRIPT

cat > edit/tmp/cleanup.sh << ENDSCRIPT
# Cleanups
echo "" > /etc/resolv.conf
rm -f /etc/apt/apt.conf.d/00proxy
apt-get clean

rm -rf /tmp/*
rm -rf /var/cache/apt-xapian-index/*
rm -rf /var/lib/apt/lists/*
service dbus stop
sleep 2
umount /proc/sys/fs/binfmt_misc || true
umount /sys
umount /dev/pts
umount /proc
#end of chroot
exit
ENDSCRIPT
chmod +x edit/tmp/*.sh

chroot edit ./tmp/prepare.sh

if [[ $PROXY ]]
then
   echo "Acquire::http { Proxy \"${proxy_url}\"; };" >> edit/etc/apt/apt.conf.d/00proxy
   echo "Acquire::https { Proxy \"${proxy_url}\"; };" >> edit/etc/apt/apt.conf.d/00proxy
fi

if [[ $ID ]] 
then
  chroot edit ./tmp/addID.sh
fi

if [[ $LO ]]
then 
  chroot edit ./tmp/libreoffice.sh
fi

if [[ $EST ]]
then
  chroot edit ./tmp/estonian_packages.sh
fi

if [[ $MATE ]]
then
  chroot edit ./tmp/mate.sh
fi

if [[ $EXTRA ]]
then
  chroot edit ./tmp/extra.sh
fi


chroot edit ./tmp/cleanup.sh

umount edit/dev


# setting default language
# 16.04 LTS: seems broken (for legacy boot mode), no known solution. English is still the default.

#cd gfxboot-theme-ubuntu-0.20.1
#cd po
#ln -sf et.po et_EE.po
#cd ..
#make DEFAULT_LANG="et_EE"
#cd ..
#echo et > extract-cd/isolinux/lang
#cp -af gfxboot-theme-ubuntu-0.20.1/boot/* extract-cd/isolinux/
#sed -i "/default_keymap = {/a \'et\': \'et\'," edit/usr/lib/ubiquity/ubiquity/misc.py


# Re-creation of "manifest" file
chmod +w extract-cd/casper/filesystem.manifest
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
#
# Pack the filesystem
rm -f extract-cd/casper/filesystem.squashfs
mksquashfs edit extract-cd/casper/filesystem.squashfs
# Create the disk image itself
export IMAGE_NAME="Ubuntu 16.04 LTS"
sed -i -e "s/$IMAGE_NAME/$IMAGE_NAME (Estonian Remix)/" extract-cd/README.diskdefines
sed -i -e "s/$IMAGE_NAME/$IMAGE_NAME (Estonian Remix)/" extract-cd/.disk/info

cd extract-cd
# Localizing the UEFI boot
sed -i '6i    loadfont /boot/grub/fonts/unicode.pf2' boot/grub/grub.cfg
sed -i '7i    set locale_dir=$prefix/locale' boot/grub/grub.cfg
#sed -i '8i    set lang=et_EE' boot/grub/grub.cfg
sed -i '9i    insmod gettext' boot/grub/grub.cfg
#sed -i 's%splash%splash debian-installer/locale=et_EE keyboard-configuration/layoutcode=et console-setup/layoutcode=et%' boot/grub/grub.cfg
sed -i 's/Try Ubuntu without installing/Proovi ilma paigaldamiseta/' boot/grub/grub.cfg
sed -i 's/Install Ubuntu/Paigalda Ubuntu/' boot/grub/grub.cfg
sed -i 's/OEM install (for manufacturers)/OEM-paigaldus (arvutitootjatele)/' boot/grub/grub.cfg
sed -i 's/Check disc for defects/Kontrolli kettavigu/' boot/grub/grub.cfg

#This is not a good solution, it mixes keyboard setting completely - set language form install splash
#sed -i 's%splash%splash debian-installer/locale=et_EE.UTF-8 keyboard-configuration/layoutcode=et console-setup/layoutcode=et%' boot/grub/loopback.cfg
#sed -i 's%splash%splash debian-installer/locale=et_EE.UTF-8 keyboard-configuration/layoutcode=et console-setup/layoutcode=et%' isolinux/txt.cfg
#sed -i 's/Try Ubuntu without installing/Proovi ilma paigaldamiseta/' boot/grub/loopback.cfg
#sed -i 's/Try Ubuntu without installing/Proovi ilma paigaldamiseta/' isolinux/txt.cfg
#sed -i 's/Install Ubuntu/Paigalda Ubuntu/' boot/grub/loopback.cfg
#sed -i 's/Install Ubuntu/Paigalda Ubuntu/' isolinux/txt.cfg

mkdir -p boot/grub/locale/
mkdir -p boot/grub/fonts/

#cp -a /boot/grub/locale/et.mo boot/grub/locale/
cp -a /boot/grub/fonts/unicode.pf2 boot/grub/fonts/

echo "d-i debian-installer/locale string et_EE.UTF-8" >> preseed/ubuntu.seed
echo "d-i keyboard-configuration/xkb-keymap select et" >> preseed/ubuntu.seed
echo "d-i keyboard-configuration/layout string \"Estonian\"" >> preseed/ubuntu.seed
echo "d-i keymap select et" >> preseed/ubuntu.seed

rm -f md5sum.txt
(find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee ../md5sum.txt)
mv -f ../md5sum.txt ./
# If the following is not done, causes an error in the boot menu disk check option
sed -i -e '/isolinux/d' md5sum.txt
# Different volume name than the IMAGE_NAME above.
# 16.04 LTS
genisoimage -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -o ../${output_file} .
cd ..
isohybrid --uefi ${output_file}
umount squashfs/
umount mnt/

echo
echo Generated ${output_file}
echo
