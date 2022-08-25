## PointerScope

### Overview

PointerScope is a pointer collection tool improved on CCR. It modifies *LLVM v10.0.0* to collect Layout Metadata and Pointer Metadata in object files during compilation, and modifies *gold v2.36.1* to merge all sub-metadata into the final executable during static linking. This metadata collected at compile time is appended to the .rand section of the ELF file and can be used to perform function-level or basic block-level fine-grained randomization of the executable.

### How to build PointerScope

We provide `build.sh` and `docker/Dockerfile` for building out the environment locally or in a docker container, respectively. We recommend the latter build method in order not to interfere with the local compilation toolchain.

#### Build locally (`build.sh`)

Execute `build.sh` in the root directory of PointerScope. The script mainly completes the following compilation tasks.

1. Build protobuf and compile protobuf_def
   
   ```shell
   ./autogen.sh
   ./configure
   make -j$(nproc)
   make install
   
   protoc --proto_path="$protobuf" --cpp_out=. "$protobuf/shuffleInfo.proto"
    protoc --proto_path="$protobuf" --python_out=. "$protobuf/shuffleInfo.proto"
    c++ -fPIC -g -shared "$protobuf/shuffleInfo.pb.cc" -o "$protobuf/shuffleInfo.so" -std=c++11 `pkg-config --cflags --libs protobuf`
   ```

2. Build LLVM v10.0.0
   
   ```shell
   cmake -DCMAKE_INSTALL_PREFIX="/usr/local/llvm10" -DCMAKE_EXE_LINKER_FLAGS="-Wl,--no-as-needed -I/usr/local/include -L/usr/local/lib -lprotobuf -lpthread -lshuffleInfo" -DCMAKE_SHARED_LINKER_FLAGS="-Wl,--no-as-needed -I/usr/local/include -L/usr/local/lib -lprotobuf -lpthread  -lshuffleInfo" -DLLVM_ENABLE_RTTI=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_TOOLS=OFF -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD="X86" ${ps_path}/src/llvm10/llvm/
   make -j$(nproc)
   make install
   ```

3. Build binutils v2.36.1
   
   ```shell
   ../configure --prefix="/usr/local/binutils2.36.1/" --enable-gold --enable-plugins LDFLAGS='-Wl,--no-as-needed -L/usr/local/lib -lprotobuf -lshuffleInfo' LIBS='-lshuffleInfo -lprotobuf'
   make -j$(nproc)
   make install
   ```

#### Build in the container (`docker/Dockerfile`)

```shell
cd docker
./compress.sh # Compress the /src and /examples directories into /docker
docker build -t pointerscope:v1 .
```

### How to use PointerScope

Users can compile C or C++ projects using the compilation toolchain provided by PointerScope, which collects Layout Metadata and Pointer Metadata during the compilation process and then appends them to the .rand section. We provide `python/reader.py` for parsing .rand sections and formatting the output of this metadata.

**FFmpeg v4.4**

```shell
cd /examples
tar -xvf ffmpeg.tar.bz2
cd ffmpeg
mkdir build
cd build
../configure --cc='psc' --cxx='psc++'
make -j$(nproc)
```

```python
python3 /PointerScope/python/reader.py /examples/ffmpeg/build/ffmpeg > /examples/ffmpeg/build/ffmpeg_rand
cat /examples/ffmpeg/build/ffmpeg_rand

Rand Object Offset : 0x00f0
Total BBLs in .text: 408666
    BBL#   0 (  9B) BBL        VA: 0x00406e70 FallThrough: Y 
    BBL#   1 ( 11B) BBL        VA: 0x00406e79 FallThrough: Y 
    BBL#   2 ( 20B) BBL        VA: 0x00406e84 FallThrough: Y 
    BBL#   3 ( 21B) BBL        VA: 0x00406e98 FallThrough: Y 
    BBL#   4 ( 27B) BBL        VA: 0x00406ead FallThrough: N 
    BBL#   5 (  3B) BBL        VA: 0x00406ec8 FallThrough: Y 
    BBL#   6 (  2B) BBL        VA: 0x00406ecb FallThrough: Y 
    BBL#   7 (143B) BBL        VA: 0x00406ecd FallThrough: Y 
    BBL#   8 (188B) BBL        VA: 0x00406f5c FallThrough: N 
    BBL#   9 ( 71B) BBL        VA: 0x00407018 FallThrough: Y 
    BBL#  10 ( 48B) BBL        VA: 0x0040705f FallThrough: Y 
    BBL#  11 (112B) BBL        VA: 0x0040708f FallThrough: N 
    BBL#  12 (  5B) BBL        VA: 0x004070ff FallThrough: N 
    BBL#  13 ( 12B) FUN        VA: 0x00407104 FallThrough: N 
    BBL#  14 ( 64B) FUN        VA: 0x00407110 FallThrough: N 
    BBL#  15 (107B) BBL        VA: 0x00407150 FallThrough: Y 
    ...

Fixups in .text: 534750
    Fixup#   0 VA:0x406e78, offset:0x00f8, Reloc:R_X86_64_PC8, Target:0x406ec8(), add:0x-001 (@Sec .text) (NewSection) (RAND)
    Fixup#   1 VA:0x406e83, offset:0x0103, Reloc:R_X86_64_PC8, Target:0x406ecb(), add:0x-001 (@Sec .text) (RAND)
    Fixup#   2 VA:0x406e85, offset:0x0105, Reloc:R_X86_64_32, Target:0x14be720(), add:0x0000 (@Sec .text) (RAND) (RELOC)
    Fixup#   3 VA:0x406e8d, offset:0x010d, Reloc:R_X86_64_PLT32, Target:0x405a80(), add:0x-004 (@Sec .text) (RAND) (RELOC)
    Fixup#   4 VA:0x406e97, offset:0x0117, Reloc:R_X86_64_PC8, Target:0x406ecd(), add:0x-001 (@Sec .text) (RAND)
    Fixup#   5 VA:0x406e99, offset:0x0119, Reloc:R_X86_64_32, Target:0x14be725(), add:0x0000 (@Sec .text) (RAND) (RELOC)
    Fixup#   6 VA:0x406ea1, offset:0x0121, Reloc:R_X86_64_PLT32, Target:0x405a80(), add:0x-004 (@Sec .text) (RAND) (RELOC)
    Fixup#   7 VA:0x406ea9, offset:0x0129, Reloc:R_X86_64_PC32, Target:0x407104(), add:0x-004 (@Sec .text) (RAND)  
    ...

Fixups in .rodata: 62874
    Fixup#   0 VA:0x14bc6f0, offset:0x98f0, Reloc:R_X86_64_64, Target:0x409420(), add:0x0000 (@Sec .rodata) (NewSection) (JMPTBL) (RAND) (RELOC)
    Fixup#   1 VA:0x14bc6f8, offset:0x98f8, Reloc:R_X86_64_64, Target:0x4087ad(), add:0x0000 (@Sec .rodata) (JMPTBL) (RAND) (RELOC)
    Fixup#   2 VA:0x14bc700, offset:0x9900, Reloc:R_X86_64_64, Target:0x408724(), add:0x0000 (@Sec .rodata) (JMPTBL) (RAND) (RELOC)
    Fixup#   3 VA:0x14bc708, offset:0x9908, Reloc:R_X86_64_64, Target:0x408706(), add:0x0000 (@Sec .rodata) (JMPTBL) (RAND) (RELOC)
    ...

Fixups in .data: 119
    Fixup#   0 VA:0x19d6a30, offset:0x00b0, Reloc:R_X86_64_64, Target:0x94c6a8(), add:0x0000 (@Sec .data) (NewSection) (RAND) (RELOC)
    Fixup#   1 VA:0x19d6a40, offset:0x00c0, Reloc:R_X86_64_64, Target:0x94c6fb(), add:0x0000 (@Sec .data) (RAND) (RELOC)
    Fixup#   2 VA:0x19d6a50, offset:0x00d0, Reloc:R_X86_64_64, Target:0x94c748(), add:0x0000 (@Sec .data) (RAND) (RELOC)
    Fixup#   3 VA:0x19d6a60, offset:0x00e0, Reloc:R_X86_64_64, Target:0x94c795(), add:0x0000 (@Sec .data) (RAND) (RELOC)
    ...

Fixups in .init_array: 2
    Fixup#   0 VA:0x19d5d70, offset:0x0000, Reloc:R_X86_64_64, Target:0x406dc0(), add:0x0070 (@Sec .fini_array) (RELOC)
    Fixup#   1 VA:0x19d5d70, offset:0x0000, Reloc:R_X86_64_64, Target:0x406dc0(), add:0x00a0 (@Sec .init_array) (RELOC)

Fixups in .init: 1
    Fixup#   0 VA:0x405a53, offset:0x000b, Reloc:R_X86_64_REX_GOTPCRELX, Target:0x19d5fe0(), add:0x-004 (@Sec .init) (RELOC)
```

**GCC v7.3.0**

```shell
cd /examples
tar -xvf gcc-7.3.0.tar.xz
cd gcc-7.3.0
./contrib/download_prerequisites
mkdir build
cd build
../configure --prefix=/usr/local/gcc7 --enable-languages=c,c++ --disable-bootstrap --disable-libsanitizer --disable-multilib CC='psc' CXX='psc++'
make -j$(nproc)
```

**Openssh v8.8**

```shell
cd /examples
tar -xvf openssh-8.8p1.tar.gz
cd openssh-8.8p1
mkdir build
cd build
../configure CC='psc' CXX='psc++'
make -j$(nproc)
```

**ProFTPd v1.3.7**

```shell
cd /examples
tar -xvf proftpd-1.3.7c.tar.gz
cd proftpd-1.3.7c
mkdir build
cd build
../configure CC='psc' CXX='psc++'
make -j$(nproc)
```

**Pure-ftpd v1.0.49**

```shell
cd /examples
tar -xvf pure-ftpd-1.0.49.tar.gz
cd pure-ftpd-1.0.49
mkdir build
cd build
../configure CC='psc' CXX='psc++'
make -j$(nproc)
```

**Gzip v1.10**

```shell
cd /examples
tar -xvf gzip-1.10.tar.gz
cd gzip-1.10
mkdir build
cd build
../configure CC='psc' CXX='psc++'
make -j$(nproc)
```

### Thanks

[CCR: Compiler-assisted Code Randomization](https://github.com/kevinkoo001/CCR)
