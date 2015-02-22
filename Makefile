SRCS     = $(wildcard *.ml)
BYTES    = $(SRCS:.ml=.byte)
PKGS     = async
CFLAGS   = -warn-error,A
DOCFLAGS = -keep-code #,-intro,/home/vagrant/distributed-systems/doc/index.txt
SRCDIRS  = doc,async,readwrite

all: $(BYTES)

%.byte: %.ml
	corebuild -pkgs $(PKGS) -cflags $(CFLAGS) $@

.PHONY: doc
doc:
	cd doc && ./gen.sh
	corebuild -pkgs $(PKGS) -docflags $(DOCFLAGS) -Is $(SRCDIRS) doc/doc.docdir/index.html

.PHONY: clean
clean:
	rm -rf _build
	rm -f *.byte
	rm -f doc.docdir
