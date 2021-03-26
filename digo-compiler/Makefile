all : semant printer

semant : parser.cmo scanner.cmo semant.cmo
	ocamlc -o semant $^

printer : parser.cmo scanner.cmo printer.cmo
	ocamlc -o printer $^

%.cmo : %.ml
	ocamlc -c $<

%.cmi : %.mli
	ocamlc -c $<

scanner.ml : scanner.mll
	ocamllex $^

parser.ml parser.mli : parser.mly
	ocamlyacc $^

# Depedencies from ocamldep
semant.cmo : scanner.cmo parser.cmi ast.cmi
semant.cmx : scanner.cmx parser.cmx ast.cmi
printer.cmo : scanner.cmo parser.cmi ast.cmi
printer.cmx : scanner.cmx parser.cmx ast.cmi
parser.cmo : ast.cmi parser.cmi
parser.cmx : ast.cmi parser.cmi
scanner.cmo : parser.cmi
scanner.cmx : parser.cmx

.PHONY : remake

remake: clean printer semant

.PHONY : clean
clean :
	rm -rf *.cmi *.cmo parser.ml parser.mli scanner.ml printer.out printer semant.out semant

generate-compiler: clean
	ocamlbuild -use-ocamlfind semant.native -package llvm,llvm.analysis
