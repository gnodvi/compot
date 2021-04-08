#-------------------------------------------------------------------------------
#  11 February 2016

#  27 November 2020
#-------------------------------------------------------------------------------

CC = gcc

CFLAGS = -I.

DEPS = cips.h

#-------------------------------------------------------------------------------

PROGS = histeq himage findt header side halftone hidet flip bmp2tif \
        dumpb dumpi create stega boolean mainover cipscat showi invert mainas \
	maincp mainseg mainsk mfilter \
	hello hello0 

#geometry bmpedge stretch mainl iso iso2 main2seg medge 

all: $(PROGS)

#----------------------------------------------------

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

T/%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

#-------------------------------------------------------------------------------

histeq: histeq.o imageio.o hist.o
		$(CC) -o $@ $^ $(CFLAGS)

himage: himage.o imageio.o hist.o
	$(CC) -o $@ $^ $(CFLAGS)

findt: findt.o imageio.o tiffs.o
	$(CC) -o $@ $^ $(CFLAGS)

header: header.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

side: side.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

halftone: halftone.o ht.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

hidet: hidet.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

flip: flip.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

bmp2tif: bmp2tif.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

#----------------------------------------------------

GEOMETRYOBJS=geometry.o geosubs.o imageio.o
geometry: $(GEOMETRYOBJS)
	$(CC) -o $@ $^ $(CFLAGS)


BMPedgeOBJS=bmpedge.o imageio.o
bmpedge: $(BMPedgeOBJS)
	$(CC) -o $@ $^ $(CFLAGS)


STRETCHOBJS=stretch.o geosubs.o imageio.o
stretch: $(STRETCHOBJS)
	$(CC) -o $@ $^ $(CFLAGS)


MAINLOBJS=mainl.o lambert.o imageio.o
mainl: $(MAINLOBJS)
		$(CC) -o $@ $^ $(CFLAGS)


iso: iso.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

ISO2OBJS=iso2.o imageio.o
iso2: $(ISO2OBJS)
		$(CC) -o $@ $^ $(CFLAGS)


MAIN2SEGOBJS=main2seg.o hist.o imageio.o segment.o \
             edge2.o edge3.o edge.o filter.o \
             segment2.o utility.o
main2seg: $(MAIN2SEGOBJS)
	$(CC) -o $@ $^ $(CFLAGS)


MEDGEOBJS=medge.o imageio.o edges.o utility.o
medge: $(MEDGEOBJS)
	$(CC) -o $@ $^ $(CFLAGS)

#----------------------------------------------------

dumpb: dumpb.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

dumpi: dumpi.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

create: create.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

stega: stega.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

boolean: boolean.o boole.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

mainover: mainover.o overlay.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

cipscat: cipscat.o
	$(CC) -o $@ $^ $(CFLAGS)

showi: showi.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

invert: invert.o imageio.o
	$(CC) -o $@ $^ $(CFLAGS)

mainas: mainas.o imageio.o addsub.o
	$(CC) -o $@ $^ $(CFLAGS)

maincp: maincp.o imageio.o cutp.o
	$(CC) -o $@ $^ $(CFLAGS)

mainseg: mainseg.o hist.o imageio.o segment.o
	$(CC) -o $@ $^ $(CFLAGS)

mainsk: mainsk.o imageio.o skeleton.o ed.o utility.o
	$(CC) -o $@ $^ $(CFLAGS)

mfilter: mfilter.o imageio.o filter.o utility.o
	$(CC) -o $@ $^ $(CFLAGS)


####################### TEST PLATFORM ###############

hello: T/hello.o T/hello2.o T/hello3.o
	$(CC) -o $@ $^ $(CFLAGS)

hello0: hello0.c
	gcc -o hello0 hello0.c

#----------------------------------------------------

TESTBEDOBJS=testbed.o imageio.o hist.o
testbed: $(TESTBEDOBJS)
	$(CC) -o $@ $^ $(CFLAGS)

TEXTOBJS=text.o imageio.o tiffs.o
text: $(TEXTOBJS)
		$(CC) -o $@ $^ $(CFLAGS)


TIF2BMPOBJS=tif2bmp.o imageio.o
tif2bmp: $(TIF2BMPOBJS)
	$(CC) -o $@ $^ $(CFLAGS)

XEMBOSSOBJS=xemboss.o imageio.o
xemboss: $(XEMBOSSOBJS)
		$(CC) -o $@ $^ $(CFLAGS)


TESTSEGOBJS=testseg.o imageio.o segment.o hist.o
testseg: $(TESTSEGOBJS)
	$(CC) -o $@ $^ $(CFLAGS)


IIIOBJS=iii.o imageio.o segment.o hist.o
iii: $(IIIOBJS)
	$(CC) -o $@ $^ $(CFLAGS)

#-------------------------------------------------------------------------------

clean:
	rm -f *.o $(PROGS)

#-------------------------------------------------------------------------------
