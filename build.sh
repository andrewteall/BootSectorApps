nasm -f bin $1 -o $1.img
mkdir -p bin
mv $1.img bin/
