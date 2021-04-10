all: build-all

.PHONY: build-all
build-all: clean generate-digo-dependency generate-digo-linker

.PHONY: generate-digo-dependency
generate-digo-dependency:
	clang -stdlib=libc++ -std=c++2a -O3 -S -emit-llvm src/serialization.cpp src/wrapper.cpp src/serialization_wrapper.cpp
	llvm-link -S -v -o allinone.ll serialization.ll wrapper.ll serialization_wrapper.ll

.PHONY: generate-digo-linker
generate-digo-linker:
	clang -stdlib=libc++ -lstdc++ -std=c++2a -O3 src/metadata.cpp src/linker_main.cpp -o digo-linker

.PHONY: clean
clean:
	rm -f serialization.ll wrapper.ll serialization_wrapper.ll
	rm -f allinone.ll digo-linker
