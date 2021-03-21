all: generate-dependencies

.PHONY: generate-dependencies
generate-dependencies: clean

.PHONY: generate-serializer-dependency
generate-serializer-dependency: clean
	clang -stdlib=libc++ -std=c++20 -O3 -S -emit-llvm src/serialization.cpp

.PHONY: generate-template
generate-template:
	clang -stdlib=libc++ -std=c++20 -O3 -S -emit-llvm src/serializer_template.cpp

.PHONY: clean
clean:
	rm -f serialization.ll
