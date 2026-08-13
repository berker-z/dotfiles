set -euo pipefail

bootstrap_system="@bootstrapSystem@"

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

if [[ ${EUID} -ne 0 ]]; then
  die "run this installer as root: sudo wired-install"
fi

if [[ ! -d /sys/firmware/efi ]]; then
  die "this installer was not booted in UEFI mode; reboot and choose the UEFI USB entry"
fi

clear
printf '%s\n' \
  'WIRED OFFLINE INSTALLER' \
  '========================' \
  '' \
  'This will create a 1 GiB EFI partition and use the rest of one disk as ext4.' \
  'It will install the prebuilt headless wired system without internet access.' \
  '' \
  'Available disks:'

lsblk -d -o NAME,PATH,SIZE,TYPE,TRAN,RM,RO,VENDOR,MODEL,SERIAL
printf '\nMounted filesystems (the target disk must have none):\n'
findmnt --real --output SOURCE,TARGET,FSTYPE || true

printf '\nType the complete internal target disk path (example: /dev/nvme0n1): '
read -r requested_target
[[ -n ${requested_target} ]] || die "no target entered"

target=$(readlink -f -- "$requested_target")
[[ -b ${target} ]] || die "$target is not a block device"
[[ $(lsblk -dn -o TYPE -- "$target" | xargs) == disk ]] || die "$target is not a whole disk"
[[ $(lsblk -dn -o RM -- "$target" | xargs) == 0 ]] || die "$target is removable; refusing to erase it"
[[ $(lsblk -dn -o RO -- "$target" | xargs) == 0 ]] || die "$target is read-only"

mounted_descendants=$(lsblk -nrpo MOUNTPOINT -- "$target" | awk 'NF')
[[ -z ${mounted_descendants} ]] || die "the target has mounted filesystems; refusing to continue"

size=$(lsblk -dn -o SIZE -- "$target" | xargs)
model=$(lsblk -dn -o MODEL -- "$target" | xargs)
serial=$(lsblk -dn -o SERIAL -- "$target" | xargs)

printf '\nFINAL TARGET\n'
printf '  path:   %s\n  size:   %s\n  model:  %s\n  serial: %s\n' "$target" "$size" "$model" "$serial"
printf '  layout: 1 GiB FAT32 EFI + remaining space as unencrypted ext4 root\n'
printf '\nALL EXISTING DATA AND PARTITIONS ON %s WILL BE DESTROYED.\n' "$target"
printf 'To authorize this exact disk, type: ERASE %s\n> ' "$target"
read -r confirmation
[[ ${confirmation} == "ERASE $target" ]] || die "confirmation did not match; nothing was changed"

case "$target" in
  *[0-9]) boot_partition="${target}p1"; root_partition="${target}p2" ;;
  *) boot_partition="${target}1"; root_partition="${target}2" ;;
esac

printf '\n[1/7] Clearing old signatures and partition table...\n'
wipefs --all --force "$target"
sgdisk --zap-all "$target"

printf '[2/7] Creating GPT, EFI, and root partitions...\n'
sgdisk \
  --new=1:1MiB:+1GiB --typecode=1:ef00 --change-name=1:WIRED_BOOT \
  --new=2:0:0 --typecode=2:8300 --change-name=2:WIRED_ROOT \
  "$target"
partprobe "$target"
udevadm settle
[[ -b ${boot_partition} && -b ${root_partition} ]] || die "new partitions did not appear"

printf '[3/7] Formatting filesystems...\n'
wipefs --all --force "$boot_partition" "$root_partition"
mkfs.fat -F 32 -n WIRED_BOOT "$boot_partition"
mkfs.ext4 -F -L WIRED_ROOT "$root_partition"

printf '[4/7] Mounting the target...\n'
mount -t ext4 "$root_partition" /mnt
mkdir -p /mnt/boot
mount -t vfat "$boot_partition" /mnt/boot

printf '[5/7] Saving a hardware configuration for the later full flake...\n'
mkdir -p /mnt/root/wired-generated-config
nixos-generate-config --root /mnt --dir /mnt/root/wired-generated-config

printf '[6/7] Installing the prebuilt offline system...\n'
nixos-install \
  --root /mnt \
  --system "$bootstrap_system" \
  --no-root-passwd \
  --no-channel-copy

printf '[7/7] Set a local recovery password for berkerz.\n'
printf 'The password prompt is local and will not be recorded.\n'
nixos-enter --root /mnt -c 'passwd berkerz'

sync
printf '\nINSTALLATION COMPLETE\n'
printf '%s\n' \
  '1. Run: poweroff' \
  '2. Remove the USB after the machine turns off.' \
  '3. Move wired beside the router and connect Ethernet.' \
  '4. Press power once.' \
  '5. From the desktop, follow wired-install-guide.html.'
