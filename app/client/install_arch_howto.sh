# boot EFI mode

# german keyloayout
loadkeys de

# create EFI and system partition
# https://serverfault.com/questions/320590/non-interactively-create-one-partition-with-all-available-disk-size?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
(
  echo o

  echo n
  echo #1
  echo #2048
  echo +512M
  echo EF00

  echo n
  echo #2
  echo #1050624
  echo +12G
  echo #8300

  echo w
  echo Y
) | gdisk /dev/nvme0n1p

mkfs.vfat /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2

# mount
mkdir /new # keep /mnt empty for other purposes
mount /dev/nvme0n1p2 /new
mkdir /new/boot
mount /dev/nvme0n1p1 /new/boot

# copy system
pacstrap /new base

# fstab?
genfstab -U /new >> /new/etc/fstab

# chroot
echo "# TODO"
echo arch-chroot /mnt
echo ./install_displayer.sh
