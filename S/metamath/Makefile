# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


all: update unzip


update: A/develop.zip

A/develop.zip:
	(cd A; wget https://github.com/metamath/set.mm/archive/refs/heads/develop.zip)

unzip: A/set.mm-develop

A/set.mm-develop:
	(cd A; unzip develop.zip)


#-------------------------------------------------------------------------------

cleanall: cleansrc cleanarx  # cleanrel 

clean:    cleansrc


cleansrc: 
	rm -fR ./A/set.mm-develop

#cleanrel: 
#	(. I_LIB ; cleanrel)

cleanarx: 
	rm -f ./A/develop.zip


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
