#!/bin/bash

smaller() {
    local IMG_FILE=$1
    local OLD_SIZE=$(ls -lh $IMG_FILE | cut -d' ' -f5)

    if [ ! -f "$IMG_FILE" ]; then
        echo "** FATAL: No image file found **"
        exit 1
    fi
    sudo echo "INFO: Shrinking $IMG_FILE..."
    local LOOP_DEV=$(sudo losetup -fP --show $IMG_FILE)
    local PART_NUM=2
    local ROOT_PART=${LOOP_DEV}p${PART_NUM}
    sudo e2fsck -fy $ROOT_PART

    local BLOCK_SIZE=$(sudo tune2fs -l $ROOT_PART | grep 'Block size' | awk '{print $3}')
    local MIN_BLOCKS=$(sudo resize2fs -P $ROOT_PART | awk -F': '  '{print $2}')
    # 20MB of extra free space
    local EXTRA_BLOCKS=$(echo "1024 * 1024 * 20 / $BLOCK_SIZE" | bc)
    local SIZE_BLOCKS=$(echo "$MIN_BLOCKS + $EXTRA_BLOCKS" | bc)
    sudo resize2fs $ROOT_PART $SIZE_BLOCKS
    sync && sleep 1
    sudo losetup -D $LOOP_DEV

    local SIZE_BYTES=$(echo "$SIZE_BLOCKS * $BLOCK_SIZE" | bc)
    local FIRST_BYTE=$(sudo parted -m $IMG_FILE unit B print | tail -1 | cut -d':' -f2 | tr -d 'B')
    local LAST_BYTE=$(echo "$FIRST_BYTE + $SIZE_BYTES" | bc)

    sudo parted $IMG_FILE rm $PART_NUM
    sudo parted $IMG_FILE unit B mkpart primary $FIRST_BYTE $LAST_BYTE
    local FINAL_SIZE=$(sudo parted -m $IMG_FILE unit B print free | tail -1 | cut -d':' -f2 | tr -d 'B')
    truncate --size $FINAL_SIZE $IMG_FILE
    sync && sleep 1

    local NEW_SIZE=$(ls -lh $IMG_FILE | cut -d' ' -f5)
    echo "INFO: Reduced $IMG_FILE from $OLD_SIZE to $NEW_SIZE"
    return 0
}
