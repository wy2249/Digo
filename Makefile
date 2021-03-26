all: test-link

test-link:
	clang++ -stdlib=libc++ -pthread dependency.ll test.ll -o executable

.PHONY: test
test: clean generate-dependency
	clang++ -stdlib=libc++ -pthread dependency.ll test.ll -o executable

.PHONY: build
build: generate-dependency
	./digo-compiler/semant.native < test/hello_world.digo > hello_world.ll
	clang++ -stdlib=libc++ -pthread dependency.ll -o executable

.PHONY: generate-async-remote-lib
generate-async-remote-lib:
	$(MAKE) link-all-llvm -C async-remote-lib

.PHONY: generate-digo-linker
generate-digo-linker:
	$(MAKE) build-all -C digo-linker

.PHONY: generate-digo-compiler
generate-digo-compiler:
	$(MAKE) generate-compiler -C digo-compiler

.PHONY: generate-dependency
generate-dependency: generate-async-remote-lib generate-digo-compiler generate-digo-linker
	llvm-link -S -v -o dependency.ll async-remote-lib/allinone.ll digo-linker/allinone.ll

.PHONY: clean
clean:
	rm -f dependency.ll executable
	$(MAKE) clean -C digo-linker
	$(MAKE) clean -C async-remote-lib
	$(MAKE) clean -C digo-compiler
