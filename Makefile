FC=gfortran
CC=gcc
optimize=-O
FFLAGS=$(optimize) -ffpe-trap=overflow,invalid,denormal
CFLAGS=$(optimize)
#if SAC library has been installed, uncomment the next two lines
CFLAGS=$(optimize) -DSAC_LIB
SACLIB=-L$(SACHOME)/lib -lsac -lsacio -no-pie

FFLAGS=$(optimize) -ffixed-line-length-none
CFLAGS=$(optimize) -Wno-unused-result

# Define the target directory for executables
BINDIR=bin
#

SUBS = fft.o Complex.o sacio.o
FKSUBS = fk.o kernel.o prop.o source.o bessel.o $(SUBS)
TARGETS = fk syn st_fk trav sachd fk2mt

all: install $(TARGETS)

# Rule to create the binary directory
install:
	mkdir -p $(BINDIR)

syn: syn.o ${SUBS} radiats.o futterman.o
	${LINK.f} -o $@ $^ ${SACLIB} -lm
	mv $@ $(BINDIR)

fk: ${FKSUBS} haskell.o
	${LINK.f} -o $@ $^ -lm
	mv $@ $(BINDIR)

st_fk: ${FKSUBS} st_haskell.o
	${LINK.f} -o $@ $^ -lm
	mv $@ $(BINDIR)

sachd: sachd.o sacio.o
	${LINK.c} -o $@ $^ -lm
	mv $@ $(BINDIR)

trav: trav.o tau_p.o
	$(LINK.f) -o $@ trav.o tau_p.o -lm
	mv $@ $(BINDIR)

fk2mt: fk2mt.o sacio.o radiats.o
	$(LINK.f) -o $@ $^ -lm
	mv $@ $(BINDIR)

bessel.f: bessel.FF
	cpp -traditional-cpp $< > $@

clean:
	rm -f *.o bessel.f
	rm -r $(BINDIR)

distclean:
	rm -f $(TARGETS)
