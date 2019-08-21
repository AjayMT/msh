
SOURCES = src/defs.ml src/lexer.mll src/parser.mly src/builtins.ml src/msh.ml
RESULT = msh
OCAMLYACC = menhir
LIBS = unix

include OCamlMakefile
