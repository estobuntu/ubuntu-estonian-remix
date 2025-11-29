.PHONY: clean 64bit
64bit:
	./makeRemix_64bit.sh
clean:
	umount build/mnt/iso || true
	umount build/mnt/fs || true
	umount -l build/edit/sys || true
	umount -l build/edit/proc || true
	umount -l build/edit/dev || true
	umount -l build/edit/dev/pts/* || true
	umount none
	