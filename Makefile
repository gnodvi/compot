# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

all:  
	(cd   ./S; make)
	(cd src/m; make)

test:  
	(cd   ./S; make test)
	(cd     .; T.sh)

#--------------------------------------------

# Aclean:  
# 	(cd COM/m; make cleanarx)
# #	(cd COM/m; make Aclean)
# Rclean:  
# 	(cd COM/m; make cleanrel)
# #	(cd COM/m; make Rclean)

clean:  
	(cd   ./S; make clean)
	(cd src/m; make clean)
#	(cd TST/m; make clean)

cleanall:  clean
#	(cd SRC/m; make cleanall)
	(cd   ./S; make cleanall)


#Aclean : 
#	(cd $(S_DIR);      make cleanarx)
##	(cd $(S_DIR);      make Aclean)
#Rclean : 
#	(cd $(S_DIR);      make cleanrel)
##	(cd $(S_DIR);      make Rclean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
