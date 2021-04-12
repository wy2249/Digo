# Digo

A temporary function metadata generator is provided in digo-compiler/tmp_metadata_gen.ml. Merge it into compiler/codegen/semant if possible.

Now you can compile a digo file to executable by:

```
  make digo=DIGOFILE.digo out=ExecutableName
  for example,
  make digo=./digo-compiler/test/test-async-remote1.digo out=executable
```

The above full clean compilation is slow, so you can break the compilation into two parts:
(1) Generate dependency:
```
    make clean
    make generate-dependecy
```
    This generates the Digo Library and Linker. There is no need to generate them every time.
(2) Compile Digo:
```
    make build digo=DIGOFILE.digo out=ExecutableName
```

Compiling from LLVM IR may be no longer supported:
```
  make from-ll ll=llrmir.ll out=ExecutableName
  for example,
  make from-ll ll=./digo-linker/test/test-async-1.ll out=executable
  ./executable --master 127.0.0.1:20001
```

Dependencies:
```
  docker run --rm -it -v `pwd`:/home/microc -w=/home/microc columbiasedwards/plt
  apt update
  apt install -y libc++-dev libc++abi-dev clang llvm
 ```
