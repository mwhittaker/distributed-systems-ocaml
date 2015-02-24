SRCS     = $(wildcard *.ml)
BYTES    = $(SRCS:.ml=.byte)
PKGS     = async,cohttp.async,uri
CFLAGS   = -warn-error,A
DOCFLAGS = -keep-code,-intro,$$PWD/doc/index.txt
SRCDIRS  = doc,async,readwrite,tcp,http

all: $(BYTES)

%.byte: %.ml
	corebuild -pkgs $(PKGS) -cflags $(CFLAGS) $@

.PHONY: doc
doc:
	cd doc && make && ./gen.byte
	corebuild -pkgs $(PKGS) -docflags $(DOCFLAGS) -Is $(SRCDIRS) doc/doc.docdir/index.html
	cp doc/style.css doc.docdir

.PHONY: clean
clean:
	rm -rf _build
	rm -f *.byte
	rm -f doc.docdir
