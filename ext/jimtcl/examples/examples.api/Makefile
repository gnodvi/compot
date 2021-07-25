#-------------------------------------------------------------------------------

JIM_DIR = ../JIM

#-------------------------------------------------------------------------------

CFLAGS+= -Wall -g

#CFLAGS+= -I..
CFLAGS+= -I$(JIM_DIR)

#-------------------------------------------------------------------------------

LDFLAGS += -L/home/mgena/.MSOFT/openssl/1.1.1d/R/lib

#LDLIBS += -L.. -ljim -lutil -lm -lssl -lcrypto   -ldl -lz  
LDLIBS += -L$(JIM_DIR) -ljim -lutil -lm -lssl -lcrypto   -ldl -lz  

EXAMPLES=		\
	jim_command	\
	jim_hello	\
	jim_list	\
	jim_obj		\
	jim_return

all: $(EXAMPLES)

clean:
	rm -rf $(EXAMPLES)
	rm -rf *.core

#-------------------------------------------------------------------------------
