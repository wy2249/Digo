all: generate-executable

.PHONY: generate-llvm
generate-llvm: clean
	clang -stdlib=libc++ -std=c++20 -O3 -S -emit-llvm *.cpp
	clang -O3 -S -emit-llvm *.c

.PHONY: link-all-llvm
link-all-llvm: generate-llvm
	llvm-link -S -v -o allinone.ll *.ll

.PHONY: generate-assembly
generate-assembly: link-all-llvm
	llc allinone.ll

.PHONY: generate-executable
generate-executable: generate-assembly
	clang++ -stdlib=libc++ -pthread allinone.s -o executable

.PHONY: clean
clean:
	rm -f *.ll
	rm -f executable
	rm -f allinone.s
