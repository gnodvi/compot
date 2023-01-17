# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# #ifndef XCOMM
# #define XCOMM #
# #endif

# XCOMM Imakefile for xzoom
# XCOMM Copyright Itai Nahshon 1995, 1996
# XCOMM
# XCOMM Valid compile time options:
# XCOMM -DFRAME: source area is marked with a rectangular frame.
# XCOMM -DXSHM:  use X11 shared memory extension.
# XCOMM -DTIMER: count time between window updates (just for testing).
# XCOMM -DNO_USLEEP: for system that do not have the usleep function
# XCOMM -DBCOPY: use bcopy() instead of memmove()

# XCOMM DEFINES = -DFRAME -DXSHM -DTIMER -DNO_USLEEP

# DEFINES = -DFRAME -DXSHM

LOCAL_LIBRARIES = -lXext -lX11 -lXt

# NAME = xzoom

# BINDIR = /usr/bin
# MANPATH = /usr/share/man

# SimpleProgramTarget($(NAME))


LOCAL_LIBRARIES +=  -lXrandr  ## X11 Xrandr Xi Xxf86vm Xcursor Xinerama
#------------------------------------------------------------------------------

PROGS = xev

all: $(PROGS)

xev: xev.c 
	gcc -o $@ $< $(LOCAL_LIBRARIES)


clean:
	rm -f $(PROGS)

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------












































# 5 "<command-line>" 2
# 1 "Imakefile.c"
