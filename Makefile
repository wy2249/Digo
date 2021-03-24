all: hello-world

.PHONY: build
build: link-all
	clang++ -stdlib=libc++ -pthread all.ll -o executable

.PHONY: generate-async-remote-lib
generate-async-remote-lib:
	$(MAKE) generate-print-only -C async-remote-lib

.PHONY: generate-digo-compiler
generate-digo-compiler:
	$(MAKE) generate-ll-only -C digo-compiler

.PHONY: hello-world
hello-world: generate-async-remote-lib generate-digo-compiler
	llvm-link -S -v -o all.ll async-remote-lib/print.ll digo-compiler/hello_world.ll
	clang++ -stdlib=libc++ -pthread all.ll -o executable

.PHONY: clean
clean:
	rm -f all.ll
