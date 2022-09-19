#-------------------------------------------------------------------------------


_OS := $(shell uname -s)


#-----------------------------------------------------------------------
ifeq ($(_OS), Linux)
#-----------------------------------------------------------------------

export QNX_TARGET = /opt/qnx650/target/qnx6
export QNX_HOST   = /opt/qnx650/host/linux/x86

QCC = /opt/qnx650/host/linux/x86/usr/bin/qcc -Bstatic -I. ##-std=gnu99
AR = ar

GCC  = gcc -std=gnu99 -Wall -I.
GPP  = g++ -g
LCC  = LANG=C g++ -Wall -fPIC -D_UNI -D_LIN

#CFLAGS = #-g -O2 -fno-unwind-tables -fno-asynchronous-unwind-tables 

TCLSH = tclsh

g11 = g++ -std=gnu++11

#------------------------------------------
else
#------------------------------------------
# Windows

QCC  = C:/qnx650/host/win32/x86/usr/bin/qcc.exe  -Bstatic  -I. 
AR   = ntox86-ar

#CFLAGS = -g -O2 -fno-unwind-tables -fno-asynchronous-unwind-tables 

#-----------------------------------------------------------------------
endif
#-----------------------------------------------------------------------



#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


#NOISE_DIR = .
NOISE_DIR = ./noise
#NOISE_DIR = ./line-noise

OBJS_noise_lin = $(NOISE_DIR)/T/linenoise.o 
OBJS_noise_qnx = $(NOISE_DIR)/Q/linenoise.o 


CFLAGS += -g -I$(NOISE_DIR)

#------------------------------------------


_OBJS_lin = T/_glob.o T/_oo.o T/_stdlib.o T/_tclcompat.o T/_tree.o T/_nshelper.o 

OBJS_lin :=  $(_OBJS_lin)  T/_load-static-exts.o \
	T/jim-subcmd.o T/jim-interactive.o T/jim-format.o T/jim.o T/utf8.o \
	T/jimregexp.o T/jimiocompat.o \
        T/jim-tty.o T/jim-aio.o T/jim-array.o T/jim-clock.o \
	T/jim-eventloop.o T/jim-exec.o T/jim-file.o T/jim-history.o T/jim-interp.o \
	T/jim-load.o T/jim-namespace.o T/jim-pack.o T/jim-package.o T/jim-posix.o \
	T/jim-readdir.o T/jim-regexp.o T/jim-signal.o T/jim-syslog.o 



_OBJS_qnx = Q/_glob.o Q/_oo.o Q/_stdlib.o Q/_tclcompat.o Q/_tree.o Q/_nshelper.o 

OBJS_qnx :=  $(_OBJS_qnx)  Q/_load-static-exts.o \
	Q/jim-subcmd.o Q/jim-interactive.o Q/jim-format.o Q/jim.o Q/utf8.o \
	Q/jimregexp.o Q/jimiocompat.o \
        Q/jim-tty.o  Q/jim-aio.o Q/jim-array.o Q/jim-clock.o \
	Q/jim-eventloop.o Q/jim-exec.o  Q/jim-file.o  Q/jim-history.o Q/jim-interp.o \
	Q/jim-load.o Q/jim-namespace.o Q/jim-pack.o   Q/jim-package.o Q/jim-posix.o \
	Q/jim-readdir.o  Q/jim-regexp.o Q/jim-signal.o Q/jim-syslog.o 


#-----------------------------------------------------------

JIMCOM_qnx = Q/common.o
JIMCOM_lin = T/common.o 

#-------------------------------------------------------------------------------

LIBJIM_lin := libjim.a
LIBJIM_qnx := libjim_qnx.a

LIN = .
TST = ../qnx

JIMSH_lin  := $(LIN)/jimsh
JIMSH_qnx  := $(TST)/jimsh


ifeq ($(_OS), Linux)
PROGS += $(OBJS_lin) $(JIMSH_lin) $(LIN)/jim_hello
endif

PROGS += $(OBJS_qnx) $(JIMSH_qnx) $(TST)/jim_hello

#------------------------------------------

all: $(JIMSH) $(PROGS)

#-------------------------------------------------------------------------------

$(NOISE_DIR)/T/linenoise.o: $(NOISE_DIR)/linenoise.c
	$(GCC) $(CFLAGS) -c $< -o $@

$(NOISE_DIR)/Q/linenoise.o: $(NOISE_DIR)/linenoise.c
	$(QCC) $(CFLAGS) -c $< -o $@

#------------------------------------------

T/common.o: common.c common.h
	$(GCC)  -c -o $@ $<   

Q/common.o: common.c common.h
	$(QCC)  -c -o $@ $<   

#------------------------------------------

$(LIN)/jim_hello: jim_hello.c  
	$(GCC) $(CFLAGS) -o $@  $< $(LIBJIM_lin)  -ldl -lm

$(TST)/jim_hello: jim_hello.c  
	$(QCC)           -o $@  $< $(LIBJIM_qnx)  -lsocket -lm

#------------------------------------------

$(JIMSH_lin): T/jimsh.o  T/_initjimsh.o $(LIBJIM_lin)
	$(GCC) $(CFLAGS) -o $@ $^ -ldl  -lm

$(JIMSH_qnx): Q/jimsh.o  Q/_initjimsh.o $(LIBJIM_qnx) 
	$(QCC) -o $@ $^          -lsocket -lm 

##------------------------------------------

$(LIBJIM_lin): $(OBJS_lin) $(JIMCOM_lin) $(OBJS_noise_lin)  
	$(AR) cr $@ $^

$(LIBJIM_qnx): $(OBJS_qnx) $(JIMCOM_qnx) $(OBJS_noise_qnx) 
	$(AR) cr $@ $^

#------------------------------------------

_glob.c: glob.tcl
	$(TCLSH) ./make-c-ext.tcl $< > $@
_oo.c: oo.tcl
	$(TCLSH) ./make-c-ext.tcl $< > $@
_stdlib.c: stdlib.tcl
	$(TCLSH) ./make-c-ext.tcl $< > $@
_tclcompat.c: tclcompat.tcl
	$(TCLSH) ./make-c-ext.tcl $< > $@
_tree.c: tree.tcl
	$(TCLSH) ./make-c-ext.tcl $< > $@
_nshelper.c: nshelper.tcl
	$(TCLSH) ./make-c-ext.tcl $< > $@
_initjimsh.c: initjimsh.tcl
	$(TCLSH) ./make-c-ext.tcl $< > $@


_load-static-exts.c: ./make-load-static-exts.tcl 
	$(TCLSH) ./make-load-static-exts.tcl  aio array clock eventloop exec file history interp load namespace pack package posix readdir regexp signal syslog glob nshelper oo stdlib tclcompat tree >$@ || ( rm $@; exit 1)

#------------------------------------------

T/_glob.o: _glob.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/_oo.o: _oo.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/_stdlib.o: _stdlib.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/_tclcompat.o: _tclcompat.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/_tree.o: _tree.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/_nshelper.o: _nshelper.c
	$(GCC) $(CFLAGS) -c $< -o $@


T/_load-static-exts.o: _load-static-exts.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/_initjimsh.o: _initjimsh.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jimsh.o: jimsh.c
	$(GCC) $(CFLAGS) -c $< -o $@


T/jim-subcmd.o: jim-subcmd.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-interactive.o: jim-interactive.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-format.o: jim-format.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim.o: jim.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/utf8.o: utf8.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jimregexp.o: jimregexp.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jimiocompat.o: jimiocompat.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-tty.o: jim-tty.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-aio.o: jim-aio.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-array.o: jim-array.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-clock.o: jim-clock.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-eventloop.o: jim-eventloop.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-exec.o: jim-exec.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-file.o: jim-file.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-history.o: jim-history.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-interp.o: jim-interp.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-load.o: jim-load.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-namespace.o: jim-namespace.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-pack.o: jim-pack.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-package.o: jim-package.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-posix.o: jim-posix.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-readdir.o: jim-readdir.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-regexp.o: jim-regexp.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-signal.o: jim-signal.c
	$(GCC) $(CFLAGS) -c $< -o $@
T/jim-syslog.o: jim-syslog.c
	$(GCC) $(CFLAGS) -c $< -o $@

#------------------------------------------

Q/_glob.o: _glob.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/_oo.o: _oo.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/_stdlib.o: _stdlib.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/_tclcompat.o: _tclcompat.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/_tree.o: _tree.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/_nshelper.o: _nshelper.c
	$(QCC) $(CFLAGS) -c $< -o $@

Q/_load-static-exts.o: _load-static-exts.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/_initjimsh.o: _initjimsh.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jimsh.o: jimsh.c
	$(QCC) $(CFLAGS) -c $< -o $@


Q/jim-subcmd.o: jim-subcmd.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-interactive.o: jim-interactive.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-format.o: jim-format.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim.o: jim.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/utf8.o: utf8.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jimregexp.o: jimregexp.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jimiocompat.o: jimiocompat.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-tty.o: jim-tty.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-aio.o: jim-aio.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-array.o: jim-array.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-clock.o: jim-clock.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-eventloop.o: jim-eventloop.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-exec.o: jim-exec.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-file.o: jim-file.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-history.o: jim-history.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-interp.o: jim-interp.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-load.o: jim-load.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-namespace.o: jim-namespace.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-pack.o: jim-pack.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-package.o: jim-package.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-posix.o: jim-posix.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-readdir.o: jim-readdir.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-regexp.o: jim-regexp.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-signal.o: jim-signal.c
	$(QCC) $(CFLAGS) -c $< -o $@
Q/jim-syslog.o: jim-syslog.c
	$(QCC) $(CFLAGS) -c $< -o $@

#-------------------------------------------------------------------------------

test check: $(JIMSH)
	cd ./tests; $(DEF_LD_PATH) $(MAKE)  TOPSRCDIR=..

#-------------------------------------------------------

clean:
	rm -f *.o T/*.o Q/*.o *.so *.dll *.exe lib*.a $(PROGS) 

cleanall: clean
	rm -f _*.c

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
