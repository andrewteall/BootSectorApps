nasm -f bin $1 -o $1.img
mkdir -p bin
mv $1.img bin/

BYTES=$(sed 's/OO.*//' bin/$1.img | wc -c)
echo "$BYTES bytes"

