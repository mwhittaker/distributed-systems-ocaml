SRCS   = $(wildcard *.ml)
BYTES  = $(SRCS:.ml=.byte)
PKGS   = async
CFLAGS = -warn-error,A

all: $(BYTES)

%.byte: %.ml
	corebuild -pkgs $(PKGS) -cflags $(CFLAGS) $@

clean:
	rm -rf _build
	rm -f *.byte
