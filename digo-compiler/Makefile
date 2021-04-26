all : generate-compiler

semant : parser.cmo scanner.cmo semant.cmo
	ocamlc -o semant $^

printer : parser.cmo scanner.cmo printer.cmo
	ocamlc -o printer $^

metadata-generator : parser.cmo scanner.cmo metadata_gen.cmo
	ocamlc -o metadata_gen $^

%.cmo : %.ml
	ocamlc -c $<

%.cmi : %.mli
	ocamlc -c $<

scanner.ml : scanner.mll
	ocamllex $^

parser.ml parser.mli : parser.mly
	ocamlyacc $^

# Depedencies from ocamldep
semant.cmo : scanner.cmo parser.cmi ast.cmo
semant.cmx : scanner.cmx parser.cmx ast.cmo

printer.cmo : scanner.cmo parser.cmi ast.cmo
printer.cmx : scanner.cmx parser.cmx ast.cmo

parser.cmo : ast.cmo parser.cmi
parser.cmx : ast.cmo parser.cmi

scanner.cmo : parser.cmi
scanner.cmx : parser.cmx

.PHONY : remake

remake: clean printer

.PHONY : clean
clean :
	rm -rf *.cmi *.cmo parser.ml parser.mli scanner.ml printer.out printer semant.out semant
	rm -rf _build
	rm -rf digo.native metadata_gen

generate-compiler: clean
	ocamlbuild -use-ocamlfind digo.native -package llvm,llvm.analysis
