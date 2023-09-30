set -e

DISK=$1
NAME=$2

MOUNT_OPTS=compress-force=zstd,noatime,ssd

# partition table
parted $DISK -- mklabel gpt

# root partition
parted $DISK -- mkpart primary 512Mib 100%

# boot partition
parted $DISK -- mkpart ESP fat32 1MiB 512MiB
parted $DISK -- set 2 boot on

sleep 1

# format boot partition
mkfs.fat -F 32 -n boot /dev/disk/by-partlabel/ESP

# format primary parition
mkfs.btrfs -f -L $NAME /dev/disk/by-partlabel/primary

sleep 1

# subvolumes
mkdir -p /tmp/root
mount -t btrfs /dev/disk/by-label/$NAME -o $MOUNT_OPTS /tmp/root

cd /tmp/root
btrfs subvolume create root
btrfs subvolume create nix
btrfs subvolume create persist
btrfs subvolume create swap

mount -t btrfs /dev/disk/by-label/$NAME -o $MOUNT_OPTS,subvol=root /mnt
mkdir /mnt/{boot,nix,persist,swap}

mount -t btrfs /dev/disk/by-label/$NAME -o $MOUNT_OPTS,subvol=nix /mnt/nix
mount -t btrfs /dev/disk/by-label/$NAME -o $MOUNT_OPTS,subvol=persist /mnt/persist
mount -t btrfs /dev/disk/by-label/$NAME -o $MOUNT_OPTS,subvol=swap /mnt/swap
mount /dev/disk/by-partlabel/ESP /mnt/boot

btrfs subvolume snapshot root root-blank
