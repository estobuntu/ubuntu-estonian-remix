#!/bin/bash
# Ubuntu - Estonian Remix CD 
#
# based on Finnish remix http://bazaar.launchpad.net/~timo-jyrinki/ubuntu-fi-remix/main/files
#
#
# License CC-BY-SA 3.0: http://creativecommons.org/licenses/by-sa/3.0/

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

export iso_file=ubuntu-16.04.1-desktop-amd64.iso
export output_file=ubuntu-16.04.1-MATE-desktop-amd64-estremix.iso

echo 
echo Ubuntu - Estonian CD remix creation
echo License CC-BY-SA 3.0: http://creativecommons.org/licenses/by-sa/3.0/
echo
echo "expecting following input ISO files: $iso_file "
echo "press enter to proceed" 
read

if [ ! -f $iso_file ]; then
  echo No input ISO file. 
  exit
fi


rm -rf edit/ extract-cd/ mnt/ squashfs/

# You may ignore all extra comment lines.



# Extracting image and chrooting into it
mkdir mnt
mount -o loop ${iso_file} mnt/
mkdir extract-cd
rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd
mkdir squashfs
mount -t squashfs -o loop mnt/casper/filesystem.squashfs squashfs
mkdir edit
cp -a squashfs/* edit/
# NOTE: LiveCDCustomization wiki page uses another method nowadays
# sudo unsquashfs mnt/casper/filesystem.squashfs
# sudo mv squashfs-root edit
# I've not noticed difference in the end result, cp seems faster
mount --bind /dev/ edit/dev
cp _modifyDisk.sh edit/tmp/
cp oofslinget-addon-estobuntu_4.1-0_all.deb edit/tmp/
#cp splash.pcx extract-cd/isolinux/splash.pcx

chroot edit ./tmp/_modifyDisk.sh


umount edit/dev


# setting default language
# 16.04 LTS: seems broken (for legacy boot mode), no known solution. English is still the default.
echo et | tee extract-cd/isolinux/lang


# Re-creation of "manifest" file
chmod +w extract-cd/casper/filesystem.manifest
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
#
# Pack the filesystem
rm extract-cd/casper/filesystem.squashfs
mksquashfs edit extract-cd/casper/filesystem.squashfs
# Create the disk image itself
export IMAGE_NAME="Ubuntu 16.04 LTS"
sed -i -e "s/$IMAGE_NAME/$IMAGE_NAME (Estonian Remix)/" extract-cd/README.diskdefines
sed -i -e "s/$IMAGE_NAME/$IMAGE_NAME (Estonian Remix)/" extract-cd/.disk/info

cd extract-cd
# Localizing the UEFI boot
sed -i '6i    loadfont /boot/grub/fonts/unicode.pf2' boot/grub/grub.cfg
sed -i '7i    set locale_dir=$prefix/locale' boot/grub/grub.cfg
sed -i '8i    set lang=et_EE' boot/grub/grub.cfg
sed -i '9i    insmod gettext' boot/grub/grub.cfg
sed -i 's%splash%splash debian-installer/locale=et_EE keyboard-configuration/layoutcode=et console-setup/layoutcode=et%' boot/grub/grub.cfg
sed -i 's/Try Ubuntu without installing/Proovi ilma paigaldamiseta/' boot/grub/grub.cfg
sed -i 's/Install Ubuntu/Paigalda Ubuntu/' boot/grub/grub.cfg
sed -i 's/OEM install (for manufacturers)/OEM-paigaldus (arvutitootjatele)/' boot/grub/grub.cfg
sed -i 's/Check disc for defects/Kontrolli kettavigu/' boot/grub/grub.cfg

sed -i 's/Try Ubuntu without installing/Proovi ilma paigaldamiseta/' boot/grub/loopback.cfg
sed -i 's/Try Ubuntu without installing/Proovi ilma paigaldamiseta/' isolinux/txt.cfg
sed -i 's/Install Ubuntu/Paigalda Ubuntu/' boot/grub/loopback.cfg
sed -i 's/Install Ubuntu/Paigalda Ubuntu/' isolinux/txt.cfg
sed -i 's%splash%splash debian-installer/locale=et_EE keyboard-configuration/layoutcode=et console-setup/layoutcode=et%' boot/grub/loopback.cfg
sed -i 's%splash%splash debian-installer/locale=et_EE keyboard-configuration/layoutcode=et console-setup/layoutcode=et%' isolinux/txt.cfg

mkdir -p boot/grub/locale/
mkdir -p boot/grub/fonts/
cp -a /boot/grub/locale/et.mo boot/grub/locale/
cp -a /boot/grub/fonts/unicode.pf2 boot/grub/fonts/

sed -i 's/ubuntu-desktop/ubuntu-mate-desktop/' preseed/ubuntu.seed

rm -f md5sum.txt
(find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee ../md5sum.txt)
mv -f ../md5sum.txt ./
# If the following is not done, causes an error in the boot menu disk check option
sed -i -e '/isolinux/d' md5sum.txt
# Different volume name than the IMAGE_NAME above. On the official image it's of the type Ubuntu 12.04 LTS amd64
export IMAGE_NAME="Ubuntu 16.04.1 LTS amd64 et"
# 16.04 LTS
genisoimage -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -o ../${output_file} .
cd ..
isohybrid --uefi ${output_file}
umount squashfs/
umount mnt/

echo
echo Generated ${output_file}
echo
