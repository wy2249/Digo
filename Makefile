all: clean generate-dependency build

.PHONY: build
build:
	./digo-compiler/digo.native $(digo) > tmp.compiled.nometadata.ll
	./digo-compiler/tmp_metadata_gen < $(digo) > tmp.metadata.ll
	cat tmp.compiled.nometadata.ll tmp.metadata.ll > tmp.compiled.ll
	./digo-linker/digo-linker async tmp.compiled.ll tmp.async.linker.ll
	llvm-link -S -v -o tmp.async.ll tmp.compiled.ll tmp.async.linker.ll
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
	$(MAKE) metadata-generator -C digo-compiler

.PHONY: generate-dependency
generate-dependency: generate-async-remote-lib generate-digo-compiler generate-digo-linker
	llvm-link -S -v -o dependency.ll async-remote-lib/allinone.ll digo-linker/allinone.ll

.PHONY: clean
clean:
	rm -f dependency.ll executable
	rm -f tmp.compiled.ll tmp.async.ll tmp.metadata.ll tmp.compiled.nometadata.ll tmp.async.linker.ll
	$(MAKE) clean -C digo-linker
	$(MAKE) clean -C async-remote-lib
	$(MAKE) clean -C digo-compiler
