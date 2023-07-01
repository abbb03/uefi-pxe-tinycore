#!/bin/sh
cp /usr/share/OVMF/OVMF_VARS.fd /tmp/qemu-pxe-OVMF_VARS.fd
qemu-kvm -cpu host -accel kvm -machine q35,smm=on -m 2G -global driver=cfi.pflash01,property=secure,value=on \
-drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on -drive file=/tmp/qemu-pxe-OVMF_VARS.fd,if=pflash,format=raw,unit=1 \
-netdev user,id=net0,net=192.168.88.0/24,tftp=$HOME/pxeserver/tftp/,bootfile=grubx64.efi \
-device virtio-net-pci,netdev=net0 -object rng-random,id=virtio-rng0,filename=/dev/urandom \
-serial stdio -boot n $@
