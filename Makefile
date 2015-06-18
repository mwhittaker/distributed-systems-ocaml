SRCS     = $(wildcard *.ml)
BYTES    = $(SRCS:.ml=.byte)
PKGS     = async,cohttp.async,uri
CFLAGS   = -warn-error,A-48
DOCFLAGS = -keep-code,-intro,$$PWD/doc/index.txt
SRCDIRS  = doc,async,readwrite,tcp,serialization,messaging,persistence,http

all: $(BYTES)

%.byte: %.ml
	corebuild -use-menhir -pkgs $(PKGS) -cflags $(CFLAGS) $@

.PHONY: doc
doc:
	cd doc && make && ./gen.byte
	corebuild -use-menhir -pkgs $(PKGS) -docflags $(DOCFLAGS) -Is $(SRCDIRS) doc/doc.docdir/index.html
	cp doc/style.css doc.docdir

.PHONY: clean
clean:
	rm -rf _build
	rm -f *.byte
	rm -f doc.docdir
