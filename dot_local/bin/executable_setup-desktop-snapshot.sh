#!/usr/bin/env bash

ROOTFS="/dev/mapper/arch-rootfs"
SNAPSHOT_PATH="__active/rootfs"
SNAPSHOT_SUFFIX="desktop"
MOUNTPOINT="/mnt"
REFIND_CONF="/boot/EFI/refind/local_desktop.conf"

mount_rootfs() {
    echo "Mounting root filesystem"
    if mountpoint -q ${MOUNTPOINT}; then
        echo "Mountpoint ${MOUNTPOINT} is already mounted."
        exit 1
    fi
    if ! sudo mount ${ROOTFS} -o subvol=/ ${MOUNTPOINT}; then
        echo "Failed to mount ${ROOTFS} on ${MOUNTPOINT}"
        exit 1
    fi
}

umount_rootfs() {
    echo "Unmounting root filesystem"
    if mountpoint -q ${MOUNTPOINT}; then
        sudo umount ${MOUNTPOINT}
    else
        echo "Mountpoint ${MOUNTPOINT} is not mounted."
    fi
}

setup_snapshot() {
    mount_rootfs

    if [ -d "${MOUNTPOINT}/${SNAPSHOT_PATH}-${SNAPSHOT_SUFFIX}" ]; then
        echo "Snapshot ${MOUNTPOINT}/${SNAPSHOT_PATH}-${SNAPSHOT_SUFFIX} already exists. Exiting."
        exit 1
    fi

    # snapshot rootfs
    sudo btrfs subvol snapshot ${MOUNTPOINT}/${SNAPSHOT_PATH} ${MOUNTPOINT}/${SNAPSHOT_PATH}-${SNAPSHOT_SUFFIX}
    echo "Snapshot created at ${MOUNTPOINT}/${SNAPSHOT_PATH}${SNAPSHOT_NAME}"

    umount_rootfs
}

destroy_snapshot() {
    mount_rootfs

    if [ ! -d "${MOUNTPOINT}/${SNAPSHOT_PATH}-${SNAPSHOT_SUFFIX}" ]; then
        echo "Snapshot ${MOUNTPOINT}/${SNAPSHOT_PATH}-${SNAPSHOT_SUFFIX} does not exist. Exiting."
        exit 1
    fi

    echo "Destroying snapshot ${MOUNTPOINT}/${SNAPSHOT_PATH}-${SNAPSHOT_SUFFIX}"
    sudo btrfs subvol delete ${MOUNTPOINT}/${SNAPSHOT_PATH}-${SNAPSHOT_SUFFIX}

    umount_rootfs
}

install_packages() {
    mount_rootfs

    echo "Installing packages in the snapshot"
    sudo arch-chroot ${MOUNTPOINT}/${SNAPSHOT_PATH}-${SNAPSHOT_SUFFIX} /bin/bash -c "
        pacman -Syu --noconfirm xfce4 xfce-battery-plugin
    "

    umount_rootfs
}

update_packages() {
    mount_rootfs

    echo "Updating packages in the snapshot"
    sudo arch-chroot ${MOUNTPOINT}/${SNAPSHOT_PATH}-${SNAPSHOT_SUFFIX} /bin/bash -c "
        pacman -Syu --noconfirm
    "

    umount_rootfs
}

enable_refind() {
    mount_rootfs

    echo "Enable XFCE boot menu entry"
    if grep -q 'disabled' "${REFIND_CONF}" && ! grep -q '# disabled' "${REFIND_CONF}"; then
        sudo sed -i 's/disabled/# disabled/' "${REFIND_CONF}"
        echo "XFCE boot menu entry enabled."
    else
        echo "XFCE boot menu entry is already enabled or not found."
    fi

    umount_rootfs
}

disable_refind() {
    mount_rootfs

    echo "Disable XFCE boot menu entry"
    if grep -q 'disabled' "${REFIND_CONF}" && grep -q '# disabled' "${REFIND_CONF}"; then
        sudo sed -i 's/# disabled/disabled/' "${REFIND_CONF}"
        echo "XFCE boot menu entry disabled."
    else
        echo "XFCE boot menu entry is already disabled or not found."
    fi

    umount_rootfs
}

confirmation_prompt() {
    read -p "Are you sure you want to proceed? (y/n): " choice
    case "$choice" in
        y|Y ) echo "Proceeding...";;
        n|N ) echo "Operation cancelled."; exit 1;;
        * ) echo "Invalid input. Operation cancelled."; exit 1;;
    esac
}

print_help () {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help            Show this help message and exit"
  echo "  -s, --setup           Setup BTRFS snapshot"
  echo "  -i, --install         Install desktop packages in the snapshot"
  echo "  -e, --enable          Enable XFCE boot menu entry"
  echo "  -u, --update          Update the snapshot"
  echo "  -x, --destroy         Destroy BTRFS snapshot"
  echo "  -d, --disable         Disable XFCE boot menu entry"
  echo "      --auto-create     Automatically create snapshot, install packages, and enable boot entry"
  echo "      --auto-destroy    Automatically disable boot entry and destroy snapshot"
  echo ""
}

parse_args () {
  args=$@

  if [[ $# -eq 0 ]]; then
    print_help
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        print_help
        exit 0
        ;;
      -s|--setup)
        setup_snapshot
        shift
        ;;
      -i|--install)
        install_packages
        shift
        ;;
      -e|--enable)
        enable_refind
        shift
        ;;
      -u|--update)
        update_packages
        shift
        ;;
      -d|--disable)
        disable_refind
        shift
        ;;
      -x|--destroy)
        confirmation_prompt
        destroy_snapshot
        shift
        ;;
      --auto-create)
        confirmation_prompt
        setup_snapshot
        install_packages
        enable_refind
        shift
        ;;
      --auto-destroy)
        confirmation_prompt
        disable_refind
        destroy_snapshot
        shift
        ;;
      *)
        print_help
        exit 0
        ;;
    esac
  done
}

parse_args $@
