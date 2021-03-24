all: generate-executable

.PHONY: generate-llvm
generate-llvm: clean
	clang -stdlib=libc++ -std=c++2a -O3 -S -emit-llvm ./src/*.cpp
	clang -O3 -S -emit-llvm ./src/linker_reserved.c ./src/print.c

.PHONY: link-all-llvm
link-all-llvm: generate-llvm
	llvm-link -S -v -o allinone.ll *.ll

.PHONY: generate-executable
generate-executable: link-all-llvm
	clang++ -stdlib=libc++ -pthread allinone.ll -o executable

.PHONY: clean
clean:
	rm -f *.ll
	rm -f executable
