
# msh

msh is a basic shell implemented in OCaml. It does not aim to be
POSIX-compatible or particularly useful.

msh can parse commands that look like this:
```sh
ENV_VAR=1 ENV_VAR=2 command -args --args -args | ENV_VAR=3 command
```

As of now, it *does not* support:
- escaping
- command/process substitution
- tab completion
- history searching
- most other things

## Build

You will need the [OCaml](https://ocaml.org/docs/install.html) toolchain,
specifically ocamldep, ocamlc and ocamlopt. You will also need
[menhir](http://gallium.inria.fr/~fpottier/menhir/).

To build a native executable, simply
```sh
make nc
```

For other build options, consult the
[OCamlMakefile documentation](https://github.com/mmottl/ocaml-makefile).
