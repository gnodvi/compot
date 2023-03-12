# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


src: update unzip


#-------------------------------------------------------------------------------

update: A/develop.zip

A/develop.zip:
	(cd A; wget https://github.com/metamath/set.mm/archive/refs/heads/develop.zip)


unzip: T/set.mm-develop

T/set.mm-develop:
	(cd T; unzip ../A/develop.zip)


#-------------------------------------------------------------------------------

#cleanall: cleansrc cleanarx  # cleanrel 

clean:  #  cleansrc


#cleansrc: 
#	rm -fR ./R/set.mm-develop

##cleanrel: 
##	(. I_LIB ; cleanrel)

#cleanarx: 
#	rm -f ./A/develop.zip


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
