#!/bin/sh
#
#-----------------------------------------------------------------------
# -*-   mode: sh   ; coding: koi8   -*- --------------------------------


CUR_DIR=$PWD

MSOFT_DIR=$CUR_DIR/..

#----------------------------------------------------------------
add_soft_export () 
{

  export PATH=$SOFT_DIR/bin:$SOFT_DIR/sbin:$PATH
  export LD_LIBRARY_PATH=$SOFT_DIR/lib:$LD_LIBRARY_PATH

  export MANPATH=$SOFT_DIR/man:$SOFT_DIR/share/man:$MANPATH
  export PKG_CONFIG_PATH=$SOFT_DIR/lib/pkgconfig:$PKG_CONFIG_PATH 
  export PKG_CONFIG_PATH=$SOFT_DIR/share/pkgconfig:$PKG_CONFIG_PATH 

  # здесь наверное не надо внутри установосчной папки 
  if [ -f $SOFT_DIR/.bashrc ]; then
       . $SOFT_DIR/.bashrc
  fi
}
#----------------------------------------------------------------

add_soft () 
{
  SOFT_DIR=$MSOFT_DIR/$1/R;

  add_soft_export;

  #echo "add_soft ... $1"

  # это по сути пост-установочный скрипт
  if [ -f $MSOFT_DIR/$1/.bashrc ]; then
       .  $MSOFT_DIR/$1/.bashrc
  fi

  export ADD_SOFT=$ADD_SOFT:$1

}

#----------------------------------------------------------------

add_soft_dir () 
{
  SOFT_DIR=$MSOFT_DIR/$1;

  add_soft_export;
  echo "add_soft_dir ... $1"
}

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

#add_soft  _fossil/fuel/0.9.6;

#add_soft jimtcl/0.80

#add_soft lua/5.4.4

#add_soft JuliaLang/julia/1.7.3

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

