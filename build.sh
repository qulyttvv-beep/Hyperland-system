#!/bin/bash
# Build the Hyperland System live/installer ISO. Needs an Arch Linux host
# (or: docker run --rm --privileged -v "$PWD:/repo" -w /repo archlinux \
#        bash -c 'pacman -Syu --noconfirm archiso && ./build.sh')
set -euo pipefail
[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"

REPO="$(cd "$(dirname "$0")" && pwd)"
WORK="${WORK:-/tmp/hyperland-build}"
OUT="${OUT:-$REPO/out}"
PROFILE="$WORK/profile"

command -v mkarchiso >/dev/null || pacman -Sy --needed --noconfirm archiso

rm -rf "$WORK"; mkdir -p "$WORK" "$OUT"
cp -r /usr/share/archiso/configs/releng "$PROFILE"

# 32-bit repo for Wine/Steam/lib32 NVIDIA during the build
sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' "$PROFILE/pacman.conf"

# Package list = releng + ours
sed 's/#.*//; s/[[:space:]]//g; /^$/d' "$REPO/packages.txt" >> "$PROFILE/packages.x86_64"
sort -u -o "$PROFILE/packages.x86_64" "$PROFILE/packages.x86_64"

# Filesystem overlays (shared + live-only), plus a copy for the installer
cp -rT "$REPO/overlay" "$PROFILE/airootfs"
cp -rT "$REPO/live" "$PROFILE/airootfs"
mkdir -p "$PROFILE/airootfs/usr/share/hyperland"
cp -r "$REPO/overlay" "$PROFILE/airootfs/usr/share/hyperland/overlay"
cp "$REPO/packages.txt" "$PROFILE/airootfs/usr/share/hyperland/packages.txt"
mkdir -p "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants"
ln -sf /etc/systemd/system/hl-live-setup.service \
    "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/hl-live-setup.service"

# NVIDIA kernel params on every live boot entry (GRUB, systemd-boot, syslinux)
grep -rl 'archisobasedir=' "$PROFILE"/{grub,efiboot,syslinux} 2>/dev/null | while read -r f; do
    sed -i '/archisobasedir=/ s/$/ nvidia_drm.modeset=1 nvidia_drm.fbdev=1 modprobe.blacklist=nouveau/' "$f"
done

# Branding + permissions
sed -i -e 's/^iso_name=.*/iso_name="hyperland-system"/' \
       -e 's/^iso_label=.*/iso_label="HYPERLAND_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"/' \
       -e 's/^iso_publisher=.*/iso_publisher="Hyperland System"/' \
       -e 's/^iso_application=.*/iso_application="Hyperland System Live\/Installer"/' \
       "$PROFILE/profiledef.sh"
{
    echo 'file_permissions+=(["/etc/sudoers.d/10-live"]="0:0:440")'
    for f in "$REPO"/overlay/usr/local/bin/* "$REPO"/live/usr/local/bin/*; do
        b=$(basename "$f")
        echo "file_permissions+=([\"/usr/local/bin/$b\"]=\"0:0:755\")"
    done
    for f in "$REPO"/overlay/usr/local/bin/*; do
        echo "file_permissions+=([\"/usr/share/hyperland/overlay/usr/local/bin/$(basename "$f")\"]=\"0:0:755\")"
    done
} >> "$PROFILE/profiledef.sh"

mkarchiso -v -w "$WORK/work" -o "$OUT" "$PROFILE"
echo "ISO written to: $OUT"
ls -lh "$OUT"/*.iso
