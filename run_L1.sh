#!/usr/bin/env sh

scripts/copy_qemu.sh
scripts/copy_images.sh

N=$(nproc)

TYPE=papr
CPU=POWER10

while [ "$1"x != "x" ] ; do
    case $1 in
    --v1)
	TYPE=hv
	;;
    --v2)
	TYPE=papr
	;;
    --p9)
	CPU=POWER9
	;;
    --p10)
	CPU=POWER10
	;;
    *)
	echo "ERROR: Invalid option: $1" >&2
	usage
	exit 1
	;;
    esac
    shift
done


output/build/host-qemu-custom/build/qemu-system-ppc64 -nographic \
  -machine pseries,cap-nested-${TYPE}=true -cpu ${CPU} \
  -display none -vga none -m 4G -accel tcg,thread=multi \
  -serial mon:stdio \
  -smp cores=$N,maxcpus=$N,threads=1 \
  -kernel overlay/vmlinux \
  -initrd overlay/rootfs.cpio \
  -bios overlay/slof.bin \
  -virtfs local,path=overlay,mount_tag=host0,security_model=mapped-xattr,id=host0
