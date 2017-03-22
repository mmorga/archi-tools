#
# Pure OCaml, no packages, no _tags, code in serveral directories
#

# bin-annot is required for Merlin and other IDE-like tools
# - -I flag introduces sub-directories to search for code
# - -use-ocamlfind is required to find packages (from Opam)
# - _tags file introduces packages, bin_annot flag for tool chain

OCB_FLAGS = -use-ocamlfind -I src
OCB = 		ocamlbuild $(OCB_FLAGS)

all: 		native # byte profile debug

clean:
			$(OCB) -clean

native: 	sanity
			# $(OCB) archi.native
			# $(OCB) readme.native
			$(OCB) archimate21_reader.native

byte:		sanity
			# $(OCB) archi.byte
			$(OCB) archimate21_reader.byte

profile: 	sanity
			$(OCB) -tag profile archi.native

debug: 		sanity
			$(OCB) -tag debug archi.byte

sanity:
			# check that packages can be found
			ocamlfind query oUnit Xmlm

test:
			$(OCB) -I test test.native
			./test.native

.PHONY: 	all clean byte native profile debug sanity test
