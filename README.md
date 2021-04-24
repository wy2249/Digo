# Digo

```
  docker run --rm -it -v `pwd`:/home/microc -w=/home/microc wy2249/plt
 ```

Now you can compile a digo file to executable by:

```
  make digo=DIGOFILE.digo out=ExecutableName
```
  For example,

```
  make digo=./digo-compiler/test/test-async-remote1.digo out=executable
```

And run the executable. For example,

```
./executable --master 127.0.0.1:20001
```

The above full clean compilation is slow, so you can break the compilation into two parts:

(1) Generate Digo Compiler, Digo Library & Linker

```
    make clean
    make gen
```
There is no need to generate them every time.

(2)  Compile Digo:
```
    make build digo=DIGOFILE.digo out=ExecutableName
```

  For example:
```
  make build digo=./digo-compiler/test/test-future-decl.digo out=executable
```

(3)   Other debugging commands:

```
    make print-llvm digo=./digo-test/Basic/test-fib.digo
```

--------
Legacy:

The above full clean compilation is slow, so you can break the compilation into three parts:

(1) Generate dependency:
```
    make clean
    make generate-dependency
```

This generates the Digo Library and Linker. There is no need to generate them every time.

(2) Generate Digo compiler:
```
    make generate-digo-compiler
```
This generates the Digo compiler. Re-generate it if compiler implementation changes.

(3) Compile Digo:
```
    make build digo=DIGOFILE.digo out=ExecutableName
```

  For example:
```
  make build digo=./digo-compiler/test/test-future-decl.digo out=executable
```

Compiling from LLVM IR is no longer supported.
