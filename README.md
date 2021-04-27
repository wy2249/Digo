# Digo
## Environment Setup

We recommend using docker to easily set up everything
```
  git clone https://github.com/wy2249/Digo.git
  cd Digo
  docker run --rm -it -v `pwd`:/home/digo -w=/home/digo wy2249/plt
 ```

## Compile with digo

After setting up the environment, you can compile a digo file to executable by:

```
  make digo=DIGOFILE.digo out=ExecutableName
```
  For example,

```
  make digo=./digo-compiler/test/test-async-remote1.digo out=executable
```

And run the executable with either master mode or worker mode. For example,

```
./executable --master 127.0.0.1:20001
```
or
```
./executable --worker 127.0.0.1:20001 127.0.0.1:20002
```

The above full clean compilation is slow, so we recommend to break the compilation into two parts:

(1) Generate Digo Compiler, Digo Library & Linker

```
    make clean
    make gen
```
In this way, there is no need to generate them every time!

(2)  Compile a Digo file:
```
    make build digo=DIGOFILE.digo out=ExecutableName
```

  For example:
```
  make build digo=./digo-compiler/test/test-future-decl.digo out=test-future-decl
```

(3)   Other debugging commands:

Running this command can print llvm
```
    make print-llvm digo=./digo-test/Basic/test-fib.digo
```

