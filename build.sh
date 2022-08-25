ps_path=`pwd`

# build and install protobuf
echo "Compile protobuf"
cd ${ps_path}/src
git config --global url."https://github.91chi.fun/https://github.com/".insteadOf "https://github.com/"
git config protocol.https.allow always
git clone https://github.91chi.fun/https://github.com/protocolbuffers/protobuf.git
if [ $? -ne 0 ];then
	echo "clone protobuf failed."
	exit 1
fi
cd ${ps_path}/src/protobuf
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

	cp "$protobuf/shuffleInfo_pb2.py" "${ps_path}/src/python/shuffleInfo_pb2.py"
	cp "$protobuf/shuffleInfo.pb.h" "/usr/local/include/shuffleInfo.pb.h"
}

protobuf="${ps_path}/src/protobuf_def"
gold="${ps_path}/src/binutils-2.36.1/gold"
llvm="${ps_path}/src/llvm10/llvm"

echo "Compile protobuf_def"
compile_protobuf
replace_gold
replace_llvm

# compile LLVM
echo "Compile LLVM v10.0.0"
cd ${ps_path}/src/llvm10
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="/usr/local/llvm10" -DCMAKE_EXE_LINKER_FLAGS="-Wl,--no-as-needed -I/usr/local/include -L/usr/local/lib -lprotobuf -lpthread -lshuffleInfo" -DCMAKE_SHARED_LINKER_FLAGS="-Wl,--no-as-needed -I/usr/local/include -L/usr/local/lib -lprotobuf -lpthread  -lshuffleInfo" -DLLVM_ENABLE_RTTI=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_TOOLS=OFF -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD="X86" ${ps_path}/src/llvm10/llvm/
make -j$(nproc)
make install

# compile binutils
echo "Compile binutils"
cd ${ps_path}/src/binutils-2.36.1
mkdir build
cd build
../configure --prefix="/usr/local/binutils2.36.1/" --enable-gold --enable-plugins LDFLAGS='-Wl,--no-as-needed -L/usr/local/lib -lprotobuf -lshuffleInfo' LIBS='-lshuffleInfo -lprotobuf'
make -j$(nproc)
make install
if [ $? -ne 0 ];then
	echo "build binutils failed."
	exit 1
fi