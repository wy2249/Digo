# Digo

目前完整的编译链已经完成

要编译一个 Digo 文件，执行

```
  make build digo=DIGOFILE.digo out=可执行文件名
```

另外提供 LLVM IR 直接编译的选项

```
  make ll=llrmir.ll out=可执行文件名
```

可以试一下：
```
  make ll=./digo-linker/test/test-async-1.ll out=executable
  ./executable --master 127.0.0.1:20001
```
这里的 digo-test/test1.ll 和 Compiler 生成的是一致的（即没有经过Linker链接的LL）

gitignore太难写了，在commit前如果要清理文件的话，
直接执行一下 make clean 就行

Dependencies:
```
  docker run --rm -it -v `pwd`:/home/microc -w=/home/microc columbiasedwards/plt
  apt-get install libc++-dev
  apt-get install libc++abi-dev
  apt install clang
  apt install llvm
 ```
