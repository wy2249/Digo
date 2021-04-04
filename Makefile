all: compile-ll

.PHONY: build
build: clean generate-dependency
	./digo-compiler/semant.native < $(digo) > tmp.compiled.ll
	./digo-linker/digo-linker async tmp.compiled.ll tmp.async.ll
	clang++ -stdlib=libc++ -pthread dependency.ll tmp.async.ll -o $(out)

.PHONY: compile-ll
compile-ll: clean generate-dependency
	./digo-linker/digo-linker async $(ll) tmp.async.ll
	clang++ -stdlib=libc++ -pthread dependency.ll tmp.async.ll -o $(out)

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
	rm -f dependency.ll executable tmp.compiled.ll tmp.async.ll
	$(MAKE) clean -C digo-linker
	$(MAKE) clean -C async-remote-lib
	$(MAKE) clean -C digo-compiler
