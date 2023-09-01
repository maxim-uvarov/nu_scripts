def 'ramdisk_create' [
    size: filesize = 4194304kb
] {
    let $vol = (hdiutil attach -nobrowse -nomount $'ram://($size | into int | $in / 1000)' | str trim);
    sleep 2sec
    (^diskutil erasevolume HFS+ RAMDisk $vol)
}
