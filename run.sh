#!/bin/bash
# Press Esc then Fn+2 and type quit to exit
qemu-system-x86_64 -drive file=$PWD/bin/$1.img,format=raw,if=floppy -curses

#qemu-system-x86_64 -drive file=$PWD/bin/FLOPPY.img,format=raw,if=floppy -curses
#qemu-system-x86_64 -drive file=$PWD/bin/fd12-base.img,format=raw -curses