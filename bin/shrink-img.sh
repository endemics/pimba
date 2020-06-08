#!/bin/bash

function check_bin() {
    if ! which $1 > /dev/null ; then
        echo "ERROR: $1 must be installed"
        return 1
    fi
    return 0
}

function shrink() {
    local IMG_FILE=$1

    if [ ! -f "$IMG_FILE" ]; then
        echo "** FATAL: No image file found **"
        return 1
    fi

    # Check for our dependencies
    check_bin kpartx
    check_bin awk
    check_bin sync
    check_bin e2fsck
    check_bin resize2fs
    check_bin parted
    check_bin truncate

    local OLD_SIZE=$(ls -lh $IMG_FILE | cut -d' ' -f5)

    echo "INFO: Shrinking $IMG_FILE..."
    kpartx -sa $IMG_FILE

    local LOOP_DEV=$(losetup -O NAME,BACK-FILE -l -n | grep $IMG_FILE | sed "s#^/dev/\(loop[0-9]*\) *.*#\1#")
    local PART_NUM=2
    local ROOT_PART=/dev/mapper/${LOOP_DEV}p${PART_NUM}
    e2fsck -fy $ROOT_PART

    local BLOCK_SIZE=$(tune2fs -l $ROOT_PART | awk '/^Block size/ {print $NF}')
    local MIN_BLOCKS=$(resize2fs -P $ROOT_PART | awk -F': ' '{print $2}')

    # 20MB of extra free space
    local EXTRA_BLOCKS=$(echo "1024 * 1024 * 20 / $BLOCK_SIZE" | bc)
    local SIZE_BLOCKS=$(echo "$MIN_BLOCKS + $EXTRA_BLOCKS" | bc)
    resize2fs $ROOT_PART $SIZE_BLOCKS
    sync && sleep 1
    kpartx -d $IMG_FILE

    local SIZE_BYTES=$(echo "$SIZE_BLOCKS * $BLOCK_SIZE" | bc)
    local FIRST_BYTE=$(parted -m $IMG_FILE unit B print | tail -1 | cut -d':' -f2 | tr -d 'B')
    local LAST_BYTE=$(echo "$FIRST_BYTE + $SIZE_BYTES" | bc)

    parted $IMG_FILE rm $PART_NUM
    parted $IMG_FILE unit B mkpart primary $FIRST_BYTE $LAST_BYTE
    local FINAL_SIZE=$(parted -m $IMG_FILE unit B print free | tail -1 | cut -d':' -f2 | tr -d 'B')
    truncate --size $FINAL_SIZE $IMG_FILE
    sync && sleep 1

    local NEW_SIZE=$(ls -lh $IMG_FILE | cut -d' ' -f5)
    echo "INFO: Reduced $IMG_FILE from $OLD_SIZE to $NEW_SIZE"
    return 0
}
