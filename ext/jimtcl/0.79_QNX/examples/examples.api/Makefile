#-------------------------------------------------------------------------------

JIM_DIR = ../JIM

#-------------------------------------------------------------------------------

CFLAGS+= -Wall -g

#CFLAGS+= -I..
CFLAGS+= -I$(JIM_DIR)

#-------------------------------------------------------------------------------

LDLIBS += -L$(JIM_DIR) -ljim -lutil -lm   -ldl -lz  
LDLIBS += `pkg-config libssl     --libs`
LDLIBS += `pkg-config libcrypto  --libs`


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
