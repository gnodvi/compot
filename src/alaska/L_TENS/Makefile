#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

MAIN_SRC_DIR = ../../h

include $(MAIN_SRC_DIR)/Make.mak

#-------------------------------------------------------------------------------

INCLUDES	= $(subst ', , $(TCL_INCLUDE_SPEC))

SHLIB_LD_LIBS	= $(subst ', , $(TCL_STUB_LIB_SPEC))

#-------------------------------------------------------------------------------

CC		= LANG=C gcc

#-------------------------------------------------------------------------------

#LIBS		=  
#SHLIB_LD_LIBS	= ${LIBS} -L/home/pilot/.MSOFT/_tcl_tk/8.6.0/R/lib -ltcl8.6
#couldn't load file "./libtensor4.0.so": ./libtensor4.0.so: undefined symbol: tclStubsPtr


#========================================================================
# The names of the source files is defined in the configure script.
# The object files are used for linking into the final library.
# This will be used when a dist target is added to the Makefile.
# It is not important to specify the directory, as long as it is the
# $(srcdir) or in the generic, win or unix subdirectory.
#========================================================================

#PKG_SOURCES	=  tensorBasics.c tensorConv.c tensorExpr.c tensorIO.c tensorCmd.c tensorGetNumArr.c tensorOps.c

PKG_OBJECTS	=  T/tensorBasics.o T/tensorConv.o T/tensorExpr.o T/tensorIO.o T/tensorCmd.o T/tensorGetNumArr.o T/tensorOps.o

PKG_STUB_SOURCES =  tensorStubLib.c
PKG_STUB_OBJECTS =  T/tensorStubLib.o

#========================================================================
# PKG_TCL_SOURCES identifies Tcl runtime files that are associated with
# this package that need to be installed, if any.
#========================================================================

PKG_TCL_SOURCES = 

#========================================================================
# This is a list of public header files to be installed, if any.
#========================================================================

PKG_HEADERS	=  generic/tensor.h generic/tensorDecls.h

#========================================================================
# "PKG_LIB_FILE" refers to the library (dynamic or static as per
# configuration options) composed of the named objects.
#========================================================================

PKG_LIB_FILE	  = libtensor4.0.so
PKG_STUB_LIB_FILE = libtensorstub4.0.a

lib_BINARIES	= $(PKG_LIB_FILE) $(PKG_STUB_LIB_FILE)
BINARIES	= $(lib_BINARIES)

SHELL		= /bin/bash

srcdir		= .

top_builddir	= .

PACKAGE_NAME	= tensor
PACKAGE_VERSION	= 4.0

CFLAGS_DEFAULT	= -O2 -fomit-frame-pointer
CFLAGS_WARNING	= -Wall -Wno-implicit-int
EXEEXT		= 
LDFLAGS_DEFAULT	=  -Wl,--export-dynamic 

STLIB_LD	= ${AR} cr


MAKE_LIB	= ${SHLIB_LD} -o $@ $(PKG_OBJECTS) ${SHLIB_LD_LIBS} 
MAKE_SHARED_LIB	= ${SHLIB_LD} -o $@ $(PKG_OBJECTS) ${SHLIB_LD_LIBS}
MAKE_STATIC_LIB	= ${STLIB_LD} $@ $(PKG_OBJECTS)
MAKE_STUB_LIB	= ${STLIB_LD} $@ $(PKG_STUB_OBJECTS)

OBJEXT		= o
RANLIB		= :

RANLIB_STUB	= ranlib
SHLIB_CFLAGS	= -fPIC
SHLIB_LD	= ${CC} -shared ${CFLAGS} ${LDFLAGS_DEFAULT}

#========================================================================
# TCLLIBPATH seeds the auto_path in Tcl's init.tcl so we can test our
# package without installing.  The other environment variables allow us
# to test against an uninstalled Tcl.  Add special env vars that you
# require for testing here (like TCLX_LIBRARY).
#========================================================================


PKG_CFLAGS	=  

DEFS		= -DPACKAGE_NAME=\"tensor\" -DPACKAGE_TARNAME=\"tensor\" -DPACKAGE_VERSION=\"4.0\" -DPACKAGE_STRING=\"tensor\ 4.0\" -DPACKAGE_BUGREPORT=\"\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_LIMITS_H=1 -DHAVE_SYS_PARAM_H=1 -DUSE_THREAD_ALLOC=1 -D_REENTRANT=1 -D_THREAD_SAFE=1 -DTCL_THREADS=1 -DMODULE_SCOPE=extern\ __attribute__\(\(__visibility__\(\"hidden\"\)\)\) -D_LARGEFILE64_SOURCE=1 -DTCL_WIDE_INT_TYPE=long\ long -DHAVE_STRUCT_STAT64=1 -DHAVE_OPEN64=1 -DHAVE_LSEEK64=1 -DHAVE_TYPE_OFF64_T=1 -DUSE_TCL_STUBS=1  $(PKG_CFLAGS)

# Move pkgIndex.tcl to 'BINARIES' var if it is generated in the Makefile
CONFIG_CLEAN_FILES = Makefile pkgIndex.tcl
CLEANFILES	= 

CPPFLAGS	= 
AR		= ar

CFLAGS		=  -pipe ${CFLAGS_DEFAULT} ${CFLAGS_WARNING} ${SHLIB_CFLAGS} 
COMPILE		= $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)

#========================================================================
# Start of user-definable TARGETS section
#========================================================================

#========================================================================
# TEA TARGETS.  Please note that the "libraries:" target refers to platform
# independent files, and the "binaries:" target inclues executable programs and
# platform-dependent libraries.  Modify these targets so that they install
# the various pieces of your package.  The make and install rules
# for the BINARIES that you specified above have already been done.
#========================================================================

all: binaries libraries # doc

#========================================================================
# The binaries target builds executable programs, Windows .dll's, unix
# shared/static libraries, and any other platform-dependent files.
# The list of targets to build for "binaries:" is specified at the top
# of the Makefile, in the "BINARIES" variable.
#========================================================================

binaries: $(BINARIES)

libraries:

#----------------------------------------------------------

test:
	@echo ""
	@echo "TCL_MAJOR_VERSION = $(TCL_MAJOR_VERSION)"
	@echo "TCL_MINOR_VERSION = $(TCL_MINOR_VERSION)"
	@echo "TCL_PATCH_LEVEL   = $(TCL_PATCH_LEVEL)"
	@echo ""

	@echo "TCL_STUB_LIB_SPEC = $(subst ', , $(TCL_STUB_LIB_SPEC))"
	@echo "TCL_INCLUDE_SPEC  = $(TCL_INCLUDE_SPEC)"
	@echo "TCL_INCLUDE_SPEC  = $(subst ', , $(TCL_INCLUDE_SPEC))"
	@echo ""


#========================================================================
# Install documentation.  Unix manpages should go in the $(mandir)
# directory.
#========================================================================

#test: binaries libraries
#	$(TCLSH) `echo $(srcdir)/tests/all.tcl` $(TESTFLAGS)

#========================================================================
# $(PKG_LIB_FILE) should be listed as part of the BINARIES variable
# mentioned above.  That will ensure that this target is built when you
# run "make binaries".
#
# The $(PKG_OBJECTS) objects are created and linked into the final
# library.  In most cases these object files will correspond to the
# source files above.
#========================================================================

$(PKG_LIB_FILE): $(PKG_OBJECTS)
	-rm -f $(PKG_LIB_FILE)
	${MAKE_LIB}
	$(RANLIB) $(PKG_LIB_FILE)

$(PKG_STUB_LIB_FILE): $(PKG_STUB_OBJECTS)
	-rm -f $(PKG_STUB_LIB_FILE)
	${MAKE_STUB_LIB}
	$(RANLIB_STUB) $(PKG_STUB_LIB_FILE)

#========================================================================
# We need to enumerate the list of .c to .o lines here.
#
# In the following lines, $(srcdir) refers to the toplevel directory
# containing your extension.  If your sources are in a subdirectory,
# you will have to modify the paths to reflect this:
#
# sample.$(OBJEXT): $(srcdir)/generic/sample.c
# 	$(COMPILE) -c `echo $(srcdir)/generic/sample.c` -o $@
#
# Setting the VPATH variable to a list of paths will cause the makefile
# to look into these paths when resolving .c to .obj dependencies.
# As necessary, add $(srcdir):$(srcdir)/compat:....
#========================================================================

VPATH = $(srcdir)/generic:$(srcdir)/unix:$(srcdir)/win

.c.o:
	$(COMPILE) -c `echo $<` -o $@

T/tensorBasics.o:  tensorBasics.c
	$(COMPILE) -c `echo $<` -o $@

T/tensorConv.o:  tensorConv.c
	$(COMPILE) -c `echo $<` -o $@

T/tensorExpr.o:  tensorExpr.c
	$(COMPILE) -c `echo $<` -o $@

T/tensorIO.o:  tensorIO.c
	$(COMPILE) -c `echo $<` -o $@

T/tensorCmd.o:  tensorCmd.c
	$(COMPILE) -c `echo $<` -o $@

T/tensorGetNumArr.o:  tensorGetNumArr.c
	$(COMPILE) -c `echo $<` -o $@

T/tensorOps.o:  tensorOps.c
	$(COMPILE) -c `echo $<` -o $@


T/tensorStubLib.o:  tensorStubLib.c
	$(COMPILE) -c `echo $<` -o $@


#========================================================================
# End of user-definable section
#========================================================================


clean:  
	-test -z "$(BINARIES)" || rm -f $(BINARIES)
	-rm -f *.$(OBJEXT) core *.core T/*.o

#	-test -z "$(CLEANFILES)" || rm -f $(CLEANFILES)


.SUFFIXES: .c .$(OBJEXT)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
