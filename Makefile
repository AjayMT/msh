
SOURCES = src/defs.ml src/lexer.mll src/parser.mly src/msh.ml
RESULT = msh
OCAMLYACC = menhir

include OCamlMakefile
