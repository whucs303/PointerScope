# install tools
apt-get -y install build-essential cmake bison libtool python3 python3-dev python3-pip xz-utils curl autoconf automake unzip git pkg-config vim texinfo flex yasm ftp libssl-dev
if [ $? -ne 0 ];then
	echo "apt install failed."
	exit 1
fi

git config --global url."https://github.91chi.fun/https://github.com/".insteadOf "https://github.com/"
git config protocol.https.allow always

# install python3 package
python3 -m pip install pyelftools protobuf==3.12.4
if [ $? -ne 0 ];then
	echo "pip install failed."
	exit 1
fi

# decompress source code
tar -xf src.tar.xz -C /
mv /src /PointerScope
tar -xf examples.tar.xz -C /
rm /src.tar.xz
rm /examples.tar.xz

# build and install protobuf
echo "Compile protobuf"
cd /PointerScope
git clone https://github.91chi.fun/https://github.com/protocolbuffers/protobuf.git
if [ $? -ne 0 ];then
	echo "clone protobuf failed."
	exit 1
fi
cd /PointerScope/protobuf
git checkout v3.15.8
git submodule update --init --recursive
./autogen.sh
./configure
make -j$(nproc)
make install
ldconfig

# compile protobuf_def
function replace_gold {
	cp "$protobuf/shuffleInfo.pb.h" "$gold/shuffleInfo.pb.h"
    cp "$protobuf/shuffleInfo.pb.cc" "$gold/shuffleInfo.pb.cc"
	cp "$protobuf/shuffleInfo.so" "$gold/libshuffleInfo.so"
}

function replace_llvm {
	cp "$protobuf/shuffleInfo.pb.h" "$llvm/include/llvm/Support/shuffleInfo.pb.h"
	cp "$protobuf/shuffleInfo.pb.h" "/usr/local/include/shuffleInfo.pb.h"
}

function compile_protobuf {
	cd $protobuf
	protoc --proto_path="$protobuf" --cpp_out=. "$protobuf/shuffleInfo.proto"
	protoc --proto_path="$protobuf" --python_out=. "$protobuf/shuffleInfo.proto"
	c++ -fPIC -g -shared "$protobuf/shuffleInfo.pb.cc" -o "$protobuf/shuffleInfo.so" -std=c++11 `pkg-config --cflags --libs protobuf`
	
	USER=`whoami`
	chmod 755 "$protobuf/shuffleInfo.so"
	chown $USER:$USER "$protobuf/shuffleInfo.so" "$protobuf/shuffleInfo.pb.cc" "$protobuf/shuffleInfo_pb2.py"
	
	cp "$protobuf/shuffleInfo.so" "/usr/lib/libshuffleInfo.so"
	cp "$protobuf/shuffleInfo.so" "/usr/local/lib/libshuffleInfo.so"

	cp "$protobuf/shuffleInfo_pb2.py" "/PointerScope/python/shuffleInfo_pb2.py"
	cp "$protobuf/shuffleInfo.pb.h" "/usr/local/include/shuffleInfo.pb.h"
}

protobuf="/PointerScope/protobuf_def"
gold="/PointerScope/binutils-2.36.1/gold"
llvm="/PointerScope/llvm10/llvm"

echo "Compile protobuf_def"
compile_protobuf
replace_gold
replace_llvm

# compile LLVM
echo "Compile LLVM v10.0.0"
cd /PointerScope/llvm10
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="/usr/local/llvm10" -DCMAKE_EXE_LINKER_FLAGS="-Wl,--no-as-needed -I/usr/local/include -L/usr/local/lib -lprotobuf -lpthread -lshuffleInfo" -DCMAKE_SHARED_LINKER_FLAGS="-Wl,--no-as-needed -I/usr/local/include -L/usr/local/lib -lprotobuf -lpthread  -lshuffleInfo" -DLLVM_ENABLE_RTTI=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_TOOLS=OFF -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD="X86" /PointerScope/llvm10/llvm/
make -j$(nproc)
make install

# compile binutils
echo "Compile binutils"
cd /PointerScope/binutils-2.36.1
mkdir build
cd build
../configure --prefix="/usr/local/binutils2.36.1/" --enable-gold --enable-plugins LDFLAGS='-Wl,--no-as-needed -L/usr/local/lib -lprotobuf -lshuffleInfo' LIBS='-lshuffleInfo -lprotobuf'
make -j$(nproc)
make install
if [ $? -ne 0 ];then
	echo "build binutils failed."
	exit 1
fi

# set env
echo "Setup Env"
if [ -f "/usr/local/llvm10/bin/clang" ] &&
   [ -f "/usr/local/llvm10/bin/clang++" ] &&
   [ -f "/usr/local/binutils2.36.1/bin/ld.gold" ]; then
	echo "Build Success"
	mv  /usr/bin/ld /usr/bin/ld-orig
	ln -s /usr/local/binutils2.36.1/bin/ld.gold /usr/bin/ld
	ln -s /usr/local/llvm10/bin/clang /usr/bin/psc
	ln -s /usr/local/llvm10/bin/clang /usr/bin/psc++
else
	echo "Build Error"
fi