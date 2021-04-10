all: generate-executable

.PHONY: generate-print-only
generate-print-only: clean
	clang -O3 -S -emit-llvm src/print.c

.PHONY: generate-llvm
generate-llvm: clean
	clang -stdlib=libc++ -std=c++2a -O3 -S -emit-llvm ./src/async.cpp ./src/master_worker.cpp ./src/network.cpp ./src/dstring.cpp ./src/dslice.cpp

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
