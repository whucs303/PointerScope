tar -cf src.tar ../src
xz -T 0 -k -z src.tar
rm src.tar

tar -cf examples.tar ../examples
xz -T 0 -k -z examples.tar
rm examples.tar
