# bin-annot is required for Merlin and other IDE-like tools
# - -I flag introduces sub-directories to search for code
# - -use-ocamlfind is required to find packages (from Opam)
# - _tags file introduces packages, bin_annot flag for tool chain

OCB_FLAGS = -use-ocamlfind -I src
OCB = 		ocamlbuild $(OCB_FLAGS)
OPAM_LIBS = oUnit Xmlm Cmdliner ANSITerminal tyxml-ppx ocamlify mustache
OPAM_PKGS = oUnit Xmlm Cmdliner ANSITerminal tyxml.ppx mustache
RESOURCES = resources/archimate.css resources/svg_template.svg.mustache
GEN_SRC = src/svg_template.ml

all: 		native # byte profile debug

setup:
			opam install $(OPAM_LIBS)

src/svg_template.ml: $(RESOURCES)
			ocamlify --var-string svg resources/svg_template.svg.mustache > src/svg_template.ml
			ocamlify --var-string css resources/archimate.css >> src/svg_template.ml

clean:
			$(OCB) -clean
			rm $(GEN_SRC)

native: 	sanity $(GEN_SRC)
			$(OCB) archi.native

byte:		sanity $(GEN_SRC)
			$(OCB) archi.byte

profile: 	sanity $(GEN_SRC)
			$(OCB) -tag profile archi.native

debug: 		sanity $(GEN_SRC)
			$(OCB) -tag debug archi.byte

# check that packages can be found
sanity:
			ocamlfind query $(OPAM_PKGS)

test:
			$(OCB) -I test test.native
			./test.native

.PHONY: 	all clean byte native profile debug sanity test
