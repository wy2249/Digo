all: generate-executable

.PHONY: generate-llvm
generate-llvm: clean
	clang -stdlib=libc++ -std=c++20 -O3 -S -emit-llvm *.cpp
	clang -O3 -S -emit-llvm linker_reserved.c

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
