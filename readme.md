# Шаги для запуска (CorePure64) TinyCore

Итоговая структура проекта:

![structure](image.png)


Примонтировал ISO:

```shell
sudo mount -o loop ~/obrazi/CorePure64-14.0.iso ./tftp/tinylinux
```

Создал загрузчик grub2 и поместил его в ./tftp:

```sh
grub2-mkimage -p '(tftp,192.168.88.2)/EFI' -O x86_64-efi -o grubx64.efi tftp efinet
```

Создал grub.cfg, который поместил в ./tftp/EFI:

```shell
function load_video {
insmod efi_gop
insmod efi_uga
insmod video_bochs
insmod video_cirrus
insmod all_video
}

load_video
set gfxpayload=keep
set gfxmode=auto
loadfont unicode
font=unicode
insmod gfxterm
insmod gzio
insmod png

menuentry "ANNIHILATE ALL BLOCK DEVICES" {
	echo 'setting up isofile ...'
	linuxefi tinylinux/boot/vmlinuz64  ip=:::::eth0:dhcp
	initrdefi tinylinux/boot/corepure64.gz
}
```

Написал shell-скрипт:

```sh
#!/bin/sh
cp /usr/share/OVMF/OVMF_VARS.fd /tmp/qemu-pxe-OVMF_VARS.fd
qemu-kvm -cpu host -accel kvm -machine q35,smm=on -m 2G -global driver=cfi.pflash01,property=secure,value=on \
-drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on -drive file=/tmp/qemu-pxe-OVMF_VARS.fd,if=pflash,format=raw,unit=1 \
-netdev user,id=net0,net=192.168.88.0/24,tftp=$HOME/pxeserver/tftp/,bootfile=grubx64.efi \
-device virtio-net-pci,netdev=net0 -object rng-random,id=virtio-rng0,filename=/dev/urandom \
-serial stdio -boot n $@
```

Стартуем и кайфуем

Теперь можно скопировать содержимое примонтированного исошника, его можно отмонтировать, а то что там было закинуть в созданную директорию tinylinux (в итоге путь относительно корня проекта будет ./tftp/tinylinux) и удалить из ./tftp/tinylinux каталог isolinux.