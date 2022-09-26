# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

all:  
	(cd COM/m; make)
	(cd TST/m; make)

test:  
	(cd .; T.sh)

#--------------------------------------------


# Aclean:  
# 	(cd COM/m; make cleanarx)
# #	(cd COM/m; make Aclean)
# Rclean:  
# 	(cd COM/m; make cleanrel)
# #	(cd COM/m; make Rclean)

clean:  
	(cd COM/m; make clean)
	(cd TST/m; make clean)

cleanall:  
	(cd COM/m; make cleanall)
	(cd TST/m; make cleanall)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
