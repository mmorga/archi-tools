#
# Pure OCaml, no packages, no _tags, code in several directories
# Targets starting with "doc_" generate documentation for the Util and Hello
# modules
#

# bin-annot is required for Merlin and other IDE-like tools
# The -I flag introduces sub-directories to search for code
# - -use-ocamlfind is required to find packages (from Opam)
# - _tags file introduces packages, bin_annot flag for tool chain

.PHONY: all clean byte native profile debug sanity test

OCB_FLAGS = -tag bin_annot -use-ocamlfind -I src
OCB = 		ocamlbuild $(OCB_FLAGS)

OPAM_LIBS = oUnit Xmlm Cmdliner ANSITerminal tyxml-ppx ocamlify mustache

RESOURCES = resources/archimate.css resources/svg_template.svg.mustache

GEN_SRC = src/svg_template.ml

default: test

all: native byte profile debug

setup:
	opam install $(OPAM_LIBS)

src/svg_template.ml: $(RESOURCES)
	ocamlify --var-string svg resources/svg_template.svg.mustache > src/svg_template.ml
	ocamlify --var-string css resources/archimate.css >> src/svg_template.ml

clean:
	$(OCB) -clean

native:
	$(OCB) archi.native

byte:
	$(OCB) archi.byte

profile:
	$(OCB) -tag profile archi.native

debug:
	$(OCB) -tag debug archi.byte

test:
	ocamlbuild -use-ocamlfind -Is test,src test.native
	./test.native

docs: doc_html doc_man doc_tex doc_texinfo doc_dot

doc_html:
	$(OCB) doc/api.docdir/index.html

doc_man:
	$(OCB) doc/api.docdir/man

# the name of the .tex file can be anything
doc_tex:
	$(OCB) doc/api.docdir/api.tex

# the name of the .texi file can be anything
doc_texinfo:
	$(OCB) doc/api.docdir/api.texi

# the .dot graph represents inter-module dependencies
# as before, the name doesn't matter
doc_dot:
	$(OCB) doc/api.docdir/api.dot

