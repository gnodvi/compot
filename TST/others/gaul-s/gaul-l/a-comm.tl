# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 

#package provide common 1.2.1
#package provide common 1.0  ;# надо ли тут вообще?

#puts "a-comm.tl ................."

#-------------------------------------------------------------------------------
#
# TODO: здесь надо бы получать гл. переменную с именем корневой папки

#set ::MAIN_SRC_DIR  "~/.MGENA/simlab/simbat/src"

# здесь это разве надо?
#

set auto_path [linsert $auto_path 0 "COMPOT/ext/tcl-tk/snit"]

package require snit
   
# package require Itcl
# namespace import itcl::*


#-------------------------------------------------------------------------------
# ТЕСТЫ ОБЩИЕ   ТЕСТЫ ОБЩИЕ   ТЕСТЫ ОБЩИЕ   ТЕСТЫ ОБЩИЕ   ТЕСТЫ ОБЩИЕ  
#-------------------------------------------------------------------------------

proc USE_REFS { {char &}} {

  foreach v [uplevel 1 {info locals}] {

    if [string match $char* $v] {
      uplevel 1 "upvar 1 \${$v} [string range $v 1 end]"
    }
  }

}

#-------------------------------------------------------------------------------
proc system_get_os {} {

  global tcl_platform

  set os [lindex $tcl_platform(os) 0]

  return $os
}
#-------------------------------------------------------------------------------
proc system_get_osver {} {

  set osver [eval exec uname -r]
  
  #puts ""
  #puts "OSVER = $osver"
  #puts ""
  
  #	if {$osver == "6.5.0"} {
  # 	set ::OSVER "6.5.0"
  #	} else {
  #  	set ::OSVER "6.6.0"
  #	}
  
  return $osver
}
#-------------------------------------------------------------------------------

#set ::OS "Linux" ;# пусть будет значение по умолчанию?
set ::OS    [system_get_os]
set ::OSVER [system_get_osver]


# /******************************************************************************/
# //
# //   Формирование символьной экранной информации
# //   с дальнейшим выводом на терминал
# //
# /******************************************************************************/

set ::is_koi8       1
set ::is_color      1
set ::is_color_menu 1

# //-----------------------------------------------------
# // ANSI  color-change escape sequences.
# // Xterm Control Sequences (this is the file ctlseqs.ms)
# // man console_codes

#define ED  printf("\x1b[2J") // стереть экран
#define EL  printf("\x1b[K")  // стереть строку
#define CUP(row,col) printf("\x1b[%d;%dH", row,col) // переместить курсор

#define CUU printf("\x1b[A")  // на одну строку вверх
#define CUD printf("\x1b[B")  // на одну строку вниз

#define CUF printf("\x1b[C")  // на одну строку вправо
#define CUB printf("\x1b[D")  // на одну строку влево

#define SCP printf("\x1b[s")  // считать текущую позицию курсора
#define RCP printf("\x1b[u")  // восстановит позицию курсора

#-------------------------------------------------------------------------------

set  ::SGR_DEFAULT  0
set  ::SGR_BOLD     1

set  ::SGR_BLACK   30   
set  ::SGR_RED     31   
set  ::SGR_GREEN   32   
set  ::SGR_YELLOW  33   ;# BROWN
set  ::SGR_BLUE    34    
set  ::SGR_PURPLE  35   ;# MAGENTA
set  ::SGR_CYAN    36   
set  ::SGR_WHITE   37   

# еще вроде должны быть цвета:

# GRAY
# LIGHT_BLUE
# LIGHT_GREEN
# LIGHT_CYAN
# LIGHT_RED
# PURPLE, LIGHT_PURPLE (magenta??)
# YELLOW, LIGHT_YELLOW

#-------------------------------------------------------------------------------

# In addition to the default foreground and background colours, rxvt can display 
# up to 16 colours (8 ANSI colours plus high-intensity bold/blink
# versions of the same). Here is a list of the colours with their rgb.txt names.

# color0 	(black) 	= Black
# color1 	(red) 	        = Red3
# color2 	(green) 	= Green3
# color3 	(yellow) 	= Yellow3
# color4 	(blue) 	        = Blue3
# color5 	(magenta) 	= Magenta3
# color6 	(cyan) 	        = Cyan3
# color7 	(white) 	= AntiqueWhite
# color8 	(bright black) 	= Grey25
# color9 	(bright red) 	= Red
# color10 (bright green) 	= Green
# color11 (bright yellow) = Yellow
# color12 (bright blue) 	= Blue
# color13 (bright magenta)= Magenta
# color14 (bright cyan) 	= Cyan
# color15 (bright white) 	= White
# foreground 		= Black
# background 		= White

#-------------------------------------------------------------------------------

# http://www.saltycrane.com/blog/2009/11/how-make-urxvt-look-gnome-terminal/

# echo -e "\\e[0mCOLOR_NC (No color)"
# echo -e "\\e[1;37mCOLOR_WHITE\\t\\e[0;30mCOLOR_BLACK"
# echo -e "\\e[0;34mCOLOR_BLUE\\t\\e[1;34mCOLOR_LIGHT_BLUE"
# echo -e "\\e[0;32mCOLOR_GREEN\\t\\e[1;32mCOLOR_LIGHT_GREEN"
# echo -e "\\e[0;36mCOLOR_CYAN\\t\\e[1;36mCOLOR_LIGHT_CYAN"
# echo -e "\\e[0;31mCOLOR_RED\\t\\e[1;31mCOLOR_LIGHT_RED"
# echo -e "\\e[0;35mCOLOR_PURPLE\\t\\e[1;35mCOLOR_LIGHT_PURPLE"
# echo -e "\\e[0;33mCOLOR_YELLOW\\t\\e[1;33mCOLOR_LIGHT_YELLOW"
# echo -e "\\e[1;30mCOLOR_GRAY\\t\\e[0;37mCOLOR_LIGHT_GRAY"

#-------------------------------------------------------------------------------
proc  win_sgr {par} {

  #puts -nonewline "\033\[ $par m"

  puts -nonewline "\033\[ 0 ; $par m"

  # нужно наверное так, поскольку этот флажок (0 или 1) устанавливается
  # независимо и остается..
  # а может это просто тот самый BOLD ??

}
#-------------------------------------------------------------------------------
proc  win_sgr_light {par} {

  puts -nonewline "\033\[ 1 ; $par m"

}
#-------------------------------------------------------------------------------
proc save_out_to_file {out fname} {


  if {[catch {open $fname w} fout]} {
      # возникновение ошибки
      puts $fout 
      exit
  } else {
      # корректное выполнение команды open       
  }
  
  
  puts $fout ""
  foreach l $out {
      puts $fout $l
  }
  puts $fout ""

  close $fout
}
#-------------------------------------------------------------------------------
proc win_set_color {COLOR} {

  if {$::is_color} {win_sgr [set ::SGR_$COLOR]}

}
#-------------------------------------------------------------------------------
proc win_set_color_light {COLOR} {

  if {$::is_color} {win_sgr_light [set ::SGR_$COLOR]}

}
#-------------------------------------------------------------------------------
proc win_set_DEFAULT {} {

  win_set_color DEFAULT

}
#-------------------------------------------------------------------------------
proc win_puts {text COLOR} {

  win_set_color $COLOR

  puts          $text 

  win_set_color DEFAULT

}
#-------------------------------------------------------------------------------
#       ;; тeпeрь надо сравнить два файла
#     catch {
#       [eval exec diff --ignore-all-space $CALC_FILE_SED $TRUE_FILE_SED >& $DIFF_FILE] 
#     } ret

#     # здeсь можно посмотрeть размeр файла сравнeния 
#     set size [file size $DIFF_FILE]

#     if {$size == 0} {
#       puts "PASSED "
#     } else {
#       # предыдущая команда сравнения обнаружила несовпадение
#     }
#-------------------------------------------------------------------------------
proc make_string {n char} {

  for {set i 0} {$i < $n} {incr i} {

    append str $char
  }

  return $str
}
#-------------------------------------------------------------------------------
proc DebugOn {} {

  global my_debug

  set my_debug 1

}
#-------------------------------------------------------------------------------
proc DebugOff {} {

  global my_debug

  if {[info exists my_debug]} {
      unset my_debug 
  }

}
#-------------------------------------------------------------------------------
proc IsDebug {} {

  global my_debug

  return [info exists my_debug]

}
#-------------------------------------------------------------------------------
proc Debug {args} {

  global my_debug

  if {![info exists my_debug]} {
      return 
  }

  puts stderr [join $args ""]

}
#-------------------------------------------------------------------------------
#
#
#-------------------------------------------------------------------------------
# TclWisw (9) Extending Tcl in Tcl
#-------------------------------------------------------------------------------
proc repeat {n script} {

    while {[incr n -1] >= 0} {
        uplevel 1 $script    ;# вместо eval !!!!
        # but it does not work with break and continue ...
    }
}
#-------------------------------------------------------------------------------
proc with_color {is_flag color script} {

  if {$is_flag} {win_sgr $color}
  uplevel 1 $script 
  if {$is_flag} {win_sgr $::SGR_DEFAULT}

}
#-------------------------------------------------------------------------------
proc mysrand {seed} {

    expr {srand($seed)}

}
#-------------------------------------------------------------------------------
#
# rand() - возвращает случайное число с плавающей точкой в интервале [0.0 1.0]
#
#-------------------------------------------------------------------------------
# генерируем случайное целое из min-max (оба включены) интервала.
#-------------------------------------------------------------------------------
proc rand {min max} {

  expr {$min + int(rand() * (($max-$min)+1))}

}
#-------------------------------------------------------------------------------
# возвращаем случайный элемент из списка 
#-------------------------------------------------------------------------------
proc lrand {list} {
    
  lindex $list [expr {int(rand()*[llength $list])}]
    
}
#-------------------------------------------------------------------------------
# 

# надо бы сделать более гибко !
set BEGINSYM "\{"
set FINALSYM "\}"

#set BEGINSYM "\{@"
#set FINALSYM "@\}"

#TEST_replace

#-------------------------------------------------------------------------------
proc TEST_replace {} {

  global BEGINSYM FINALSYM

  #set str1 "SHOW ALL ERRORS :              {29-Feb-10:52:43-2012}"

  set str1 "SHOW ALL ERRORS :         ${BEGINSYM}29-Feb-10:52:43-2012${FINALSYM}"

  set str2 [replace_time_brackets_in_string $str1]

  puts ""
  puts $str1
  puts $str2
  puts ""

  set is_replasing 1

  replace_time_brackets_in_file  $is_replasing  "T/a_TEST" stdout 

  replace_time_brackets          $is_replasing  "T/a_TEST" "T/a_TEST_out" 

}
#-------------------------------------------------------------------------------
proc replace_time_brackets_in_string {str_inp} {

  global BEGINSYM FINALSYM


  set i1 [string first $BEGINSYM $str_inp]
  if {$i1 == -1} {return $str_inp}    ;# не нашлось левой  открывающей скобочки

  set i2 [string first $FINALSYM $str_inp $i1]
  if {$i2 == -1} {return $str_inp}    ;# не нашлось правой открывающей скобочки

  # установим границы, чтобы сами скобочки остались видимыми 
  set lensym [string length $BEGINSYM]
  #puts "LENSYM ============== $lensym"

  #incr i1      
  #incr i2 -1
  set i1 [expr $i1 + $lensym]      
  set i2 [expr $i2 - $lensym]

  set num [expr $i2 - $i1 + 1] ;# длина строки замены

  string replace $str_inp $i1 $i2 [make_string $num "-"]

}
#-------------------------------------------------------------------------------
proc replace_time_brackets_in_file {is_replasing  fname_r  id_out} {

  # set is_replasing 0 ; # не всегда нужно заменять !!

  if [catch {open $fname_r} fid] {
    puts "Cannot open $fname_r"

  } else {
    # чтение и обработка содержимого файла

    while {[gets $fid line] >= 0} {

      if {$is_replasing} {
        set new_line [replace_time_brackets_in_string $line]
      } else {
        set new_line $line
      }

      puts $id_out $new_line
    }
    
    close $fid
  }
  
}
#-------------------------------------------------------------------------------
proc replace_time_brackets {is_replasing finp fout} {

  #set is_replasing 0 ; # не всегда нужно заменять !!

  if [catch {open $fout w} id_out] {
    puts "Cannot open $fout"

  } else {
    # чтение и обработка содержимого файла
    #puts "OK open $finp"
 
    replace_time_brackets_in_file  $is_replasing $finp $id_out
    
    close $id_out
  }

}
#-------------------------------------------------------------------------------
proc check_true_and_calc_begin {name} { 


  puts -nonewline "$name ................ "  ;
  flush stdout

}
#-------------------------------------------------------------------------------
proc check_true_and_calc { 
                          TRUE_FILE_fordiff  
                          CALC_FILE_fordiff  DIFF_FILE
                          TRUE_FILE_forcopy  
                          CALC_FILE_forcopy  is_to_overwrite
                        } {


  if {$TRUE_FILE_forcopy == ""  &&  $CALC_FILE_forcopy == ""} {
    set TRUE_FILE_forcopy  $TRUE_FILE_fordiff
    set CALC_FILE_forcopy  $CALC_FILE_fordiff
  }

  # > !System Up Time          "0 days 1 hrs 22 mins 31 secs"
  # --ignore-matching-lines=Time
  #           -I "\n"                     
   #          -I " "                     

  set cmd {diff --ignore-all-space --ignore-blank-lines \
             -I "Time" \
             $TRUE_FILE_fordiff \
             $CALC_FILE_fordiff > $DIFF_FILE}

  # --ignore-all-space    игнорирует пустое пространство при сравнении строк
  # --ignore-blank-lines  игнорирует изменения, состоящие в наличии или 
  #                       отсутсвии пустых строк

  # ---------------------------
#   set cmd {diff --ignore-all-space --ignore-blank-lines \
#              -I "\n"                      \
#              -I "Time" \
#              $TRUE_FILE_fordiff \
#              $CALC_FILE_fordiff}

#   puts ""
#   puts "cmd= $cmd"  

#   #eval exec $cmd
#   eval exec {diff --ignore-all-space --ignore-blank-lines -I "\n" sw1-mk11.cfg sw1.out }

#   puts ""
#   puts ""
#   exit
  # ---------------------------

  #puts "cmd= $cmd"  

  if [catch {eval exec $cmd} ret] { ;# сравнение прошло с "ошибкой", т.е. 
    # 
    # файлы различаются? вообще довольно странно, .. хотя ..
    # можно сравнить результирующий файл с нулем, но это ведь тоже не очевидно.

    win_puts "FAILED" RED

    puts "" 
    puts "------------------------------------------------------DIFF-----------" 
    puts [exec more $DIFF_FILE]
    #puts $ret
    #exit
    puts "---------------------------------------------------------------------" 
    puts "" 

    if {$is_to_overwrite} {
    puts -nonewline "FAILED: do you wish to overwrite (y or \[n\]) ? "
    
    flush stdout               ;# все данные должны быть выведены
    set answer [gets stdin]
    puts " "
    
    switch $answer {
      y {
        exec cp $CALC_FILE_forcopy $TRUE_FILE_forcopy 

        # принимаем новый выход как истинный!
        puts "YES   : overwrite NEW -> OLD configure !!"
      }
      default {
        puts "NOT   : continue with OLD configure!"
      }
    }  
    } ;# is_to_overwrite END
 
  } else {

    win_puts "PASSED" GREEN
    
  }
  
}
#-------------------------------------------------------------------------------

set raz1 ":" ;# отделяет начальную букву

set raz2 "," ;# разделители вместо пробелов в команде

#-------------------------------------------------------------------------------
proc tst {LL OUT DIR_CMD CMD} { 

  #set raz1 ":" ;# отделяет начальную букву
  #set raz2 "," ;# разделители вместо пробелов в команде
  global  raz1 raz2

  puts "$LL: $CMD ..."

  # формируемый имя тестового файла в несколько этапов:

  # заменяем символы директорий (хотя наверное это теперь не актуальнов TCL?):
  set CMD_TRUE [string map {^ /} $CMD]

  # заменяем пробелы разделителями 
  set map_list [list " " $raz2]
  set T_FILE [string map $map_list $CMD]

  # окончательно подставляем префикс:
  set N_FILE "$LL$raz1$T_FILE"


  # и наконец выполняем команду
  eval exec $DIR_CMD/$CMD_TRUE > $OUT/$N_FILE  2> /dev/null

}
#-------------------------------------------------------------------------------
proc run_cmd_and_check {is_replasing dir_cmd rr i \
     CALC_FILE TRUE_FILE  CALC_FILE_SED TRUE_FILE_SED  DIFF_FILE   
     } {

  global  raz1 raz2

  # и формируем рeальную команду, заменяя ВСЕ разделители пробелами:
  
  set cmd [string map {^ /} $rr]  ;# сначала (!) подменяем спец-символы директорий

  set map_list [list $raz2 " "]
  set cmd [string map $map_list  $rr] ;# а потом спец-символы пробелов
  
  check_true_and_calc_begin "$i"

  # ---------------------------------------------------------
    # было в lib.sh:
    # (cd ${DIR_CMD} ; eval $CMD > $CALC_FILE  2> /dev/null)

  set pwd_dir [pwd]
  if {[catch {cd $dir_cmd} err]} {
    puts stderr $err
    exit
  }
  # так нельзя совсем уходить в директорию.. надо только на выполнение

  # ---------------------------------------------------------
  # запускаем команду на выполнение !!!
  set err 0
  
  if [catch {eval exec $cmd  2> /dev/null >  $CALC_FILE} ret] {
    set err 1 ;# сделаем пометочку об неясной ошибке
  } 

  cd $pwd_dir ;# возврашаемся!
  # ---------------------------------------------------------
  
  # тeпeрь надо сравнить два файла
  # лучше бы разделить ее на до и после выполнения команды !!

  set ::is_color 0 ;# а это здесь для чего ????
  
  # теперь надо сделать временные файлы с ЗАМЕНОЙ СКОБОК {}
  #set is_replasing 0 ; # не всегда нужно заменять !!
  # надо бы это явно указывать и еще сами парные символы замены "\{" "\}"

  replace_time_brackets  $is_replasing  $CALC_FILE $CALC_FILE_SED
  replace_time_brackets  $is_replasing  $TRUE_FILE $TRUE_FILE_SED
  
  # 
  # здесь мне надо по-хитрому: сравнивать время-модифицированные файлы
  # а вот заменять исходные !!
  check_true_and_calc  $TRUE_FILE_SED  $CALC_FILE_SED  $DIFF_FILE \
    $TRUE_FILE  $CALC_FILE  1
  
  if ($err) {
    # при этом результат работы может и совпадать ..

    puts "ERROR !!!!!!!!!!!!!! :"
    puts "CMD = $cmd"
    puts "RET = $ret"
    puts ""
    exit  ;# здесь надо бы тормозить работу
  }

}
#-------------------------------------------------------------------------------
proc run_tests  {dir_cmd dir_tst  n testname  is_replasing} {

  set testname_size [string length $testname]
  set n_beg $n
  set n_end [expr $n + $testname_size -1]

  #puts "testname      = $testname"
  #puts "testname_size = $testname_size"

  # рабочая папка для промежуточного хранения файлов сравнения
  # set dir_tmp "./T"
  # лучше бы тут давать полный путь к файлу !?
  set dir_tmp "[pwd]/T"

  set CALC_FILE      "$dir_tmp/a_CALC"
  set DIFF_FILE      "$dir_tmp/a_DIFF"

  set CALC_FILE_SED  "$dir_tmp/a_CALC_SED"
  set TRUE_FILE_SED  "$dir_tmp/a_TRUE_SED"


  set dir_tst_files [lsort [glob -directory $dir_tst *]]

  # идем по всем файлам в тестовой директории
  foreach  i $dir_tst_files {

    set TRUE_FILE $i
    set fname [string trim $i $dir_tst]  ;# отбросим слева название OUT-директории

    set aa [string range  $fname  0 0] ;# первая буква
    # будем лучше по ней здесь динамиченски определять, нужна ли замена
    if {$aa == "N"} {
      set is_replasing  0
    } else {
      set is_replasing  1
    }

    set bb [string range  $fname  $n_beg $n_end] ;# полe сравнeния

    if {$bb != $testname} {continue}  ;# пропускаемы тесты не с нашего поля

    # полагая, что уровeнь - всeгда одна цифра
    set rr [string range  $fname  2 end] ;# непосредственно заданиe
  
    # было в lib.sh:
    # (cd ${DIR_CMD} ; eval $CMD > $CALC_FILE  2> /dev/null)

    run_cmd_and_check  $is_replasing $dir_cmd $rr $fname \
      $CALC_FILE $TRUE_FILE  $CALC_FILE_SED $TRUE_FILE_SED  $DIFF_FILE   

  }

}
#-------------------------------------------------------------------------------
proc run_bukva_tests  {bukva dir_cmd dir_tst is_replasing} {

  # 1:a~.tl,TEST_5
  
  set n         2
  set testname  $bukva

  run_tests   $dir_cmd $dir_tst  $n $testname  $is_replasing

}
#-------------------------------------------------------------------------------
proc run_numer_tests {numer dir_cmd dir_tst   args} { 

  if {$args == N}  {
    set is_replasing 0
  } else {
    set is_replasing 1
  }

  # 1:a~.tl,TEST_5
  
  set n         0
  set testname  $numer

  run_tests   $dir_cmd $dir_tst   $n $testname  $is_replasing

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc m_dat {} {

  set md [exec date +%m%d]

  foreach ind {p o m m l k j i h g f e d c b a} {

    set mdi $md$ind ;# это имя создаваемой директории

    if {[file exists $mdi]} {break} 
    # уже есть такой каталог, тогда возмем предыдуший?
    # подразумевается, что был уже хоть один свободный ..

    set mdi_old $mdi ;# запомним имя, еще не занятое с конца
  }

  #exec mkdir $mdi_old
  file mkdir $mdi_old

  return $mdi_old ;# возвращаем созданное имя (чего не было ранее)
}
#-------------------------------------------------------------------------------
proc TEST_mdat {} {

  puts ""
  puts "TEST_mdat ........."
  puts ""

  puts "m_dat = [m_dat]"
  puts ""


}
#-------------------------------------------------------------------------------
# [eval] contains a [concat] automatically.  And you left out the "exec",
# so you meant:

#         eval [list exec tar zcf $tarFileName] $fileList

# which will indeed work if $fileList is a canonical list.

# Safer, though far less clear, is:

#         eval [linsert $fileList 0 exec tar zcf $tarFileName]

# Better than all, of course, is:

#         package require Tcl 8.5
#         exec tar zcf $tarFileName {expand}$fileList
#-------------------------------------------------------------------------------
proc make_ARX {files_list} {

  set pwd [pwd] ;# запомнили где были

  cd  ..

  #exec tar cvf ARX.tar stands 
  #set files_list "core00 cp6923 stands tester"

  #eval [list exec tar --exclude=A -cvf ARX.tar] [list *] 
  #eval [list exec tar --exclude=A -cvf ARX.tar] $files_list

  set cmd [list exec tar --exclude=A -cvf ARX.tar]
  #eval [list exec tar -cvf ARX.tar] $files_list
  eval $cmd $files_list
 
  exec gzip -6 ARX.tar 

  #exec tar -cvf {--exclude=A} ARX.tar stands 
  #exec tar {--ignore-failed-read --exclude=A -cvf ARX.tar *}
  #gzip -6 $(ARX_NAME).tar \

  cd $pwd ;# вернулись назад
}
#-------------------------------------------------------------------------------
# proc save_true_config_files_to_A {} {

#   puts ""
#   set pwd [pwd] ;# запомнили где были

#   set cfg_path  $pwd/$::config_dir

#   cd  $::config_dir/A
#   set new_dir [m_dat] ;# создали архив-папку

#   cd  $new_dir ;# зашли в созданную пустую папку

#   file mkdir unix
#   file mkdir wind
#-------------------------------------------------------------------------------
proc make_save {} {

  global argc argv

  puts ""
  set pwd [pwd] ;# запомнили где были

# save : 
# 	(cd $(ARX_HOME); mdat) 
# 	(cd .. ; \
# 	 tar --ignore-failed-read \
# 	     --exclude=A \
# 	     -cvf $(ARX_NAME).tar $(ARX_LIST) ; \
# 	 gzip -6 $(ARX_NAME).tar \
# 	)

  # пока так, а надо бы сделать звездочку
  #set files_list "core00 cp6923 tester"
  #set files_list "core00 cp6923 stands"
  set files_list "cp6923"

  #set files_list "*"   - почему-то не идет !!

  #set files_list  [lindex $argv 1]
  #puts "files_list = $files_list"

  #set files_list "core00 cp6923 stands tester"
  make_ARX  $files_list 

  #set arx_dir  $pwd/../A/UNI ;# почему я туда не попадаю?
  set arx_dir  Archiv
  cd  $arx_dir
  set new_dir [m_dat] ;# создали архив-папку

  cd  $new_dir ;# зашли в созданную пустую папку
  #puts "cur_dir = [pwd]"
  set tar_dir "$pwd/.."
  #puts "tar_dir = $tar_dir"
  file copy    $tar_dir/ARX.tar.gz  ARX.tar.gz
  file delete  $tar_dir/ARX.tar.gz 

  cd $pwd ;# вернулись назад

  puts "ARX.tar.gz -> Archiv/$new_dir ..... OK"
  puts ""
  puts -nonewline "PRESS ANY KEY .. "   
  flush stdout ;# все данные должны быть выведены
  set answer [gets stdin]

  puts ""

}
#-------------------------------------------------------------------------------
# proc COMM {} {

#   #source "a-prog.tcl"
#   #source "a_test.tcl"
  
#   global argv ; set PR [lindex $argv 1] ; eval {$PR 2}

# }
# 
# set helpsymb "!"
# set ind 0

#if {$argc == $ind || [string equal [lindex $argv $ind]  $helpsymb]} {}
#
#-------------------------------------------------------------------------------
proc READ_AND_CALL_ARGUS {BUKVA} {

  global argc argv

  # мда, как же быть?  .. вся строка задается жестко !!
  set dir_cmd   "." 
  set dir_tst   "E/OUT"
  set is_replasing 1

  # если без параметров, то стартует система тестирования
  if {$argc == 0} {
    
    puts "\n"
    run_bukva_tests  $BUKVA  $dir_cmd $dir_tst $is_replasing
    
    puts "\n"   
    exit
  }
  
  # а если с параметрами

  eval [lindex $argv 0]
  
  # здесь вот оно зачем ??
  puts "" 

}
#-------------------------------------------------------------------------------
# запускаем тест из командной строки селдующего уровня
#-------------------------------------------------------------------------------
proc RUN_PROC_IND {ind} {

  global argv 
  
  set    PR [lindex $argv $ind] 
  eval {$PR [expr    1 + $ind]}

}
#-------------------------------------------------------------------------------
# http://www2.tcl.tk/3888
#-------------------------------------------------------------------------------
# Well the log use of macro you had above looks like an assert function, which 
# I believe has been addressed by cleverness in the core that optimizes null 
# functions out of existence.

# I've used macros in a cpp-ish fashion, to eliminate big repeated blocks of code. 
# Here's the macro function I wrote:
#
# procedure to create macros that operate in caller's frame, with arguments
# no default args yet
#-------------------------------------------------------------------------------
proc macro {name formal_args body} {

  proc $name $formal_args [subst -nocommands {

    # locally save all formal variables, and set them in parent conext
    foreach _v [list $formal_args] {
      if {[uplevel 1 info exists \$_v]} {
        set __shadow__\$_v [uplevel 1 set \$_v]
      }
      uplevel 1 set \$_v [set \$_v]
    }

    uplevel 1 { $body }

    # undo formal variables
    foreach _v [list $formal_args] {
      if {[info exists __shadow__\$_v]} {
        uplevel 1 set \$_v [set __shadow__\$_v]
      } else {
        uplevel 1 unset \$_v
      }
    }

  }]
}
#-------------------------------------------------------------------------------
# So you can do something like
#-------------------------------------------------------------------------------
proc TEST_macro {} {

  set text "hello"

  macro foo {a} {
    puts "$text $a"
  }

  puts ""

  foo world
  foo everybody

  #-----------------------------------------
  #   =>
  #   hello world
  #   hello everybody
  
  # Of course this makes more sense when the body of the macro is 70 lines long 
  # and it's used in 8 different files, so it replaces a whole bunch of identical 
  # (except for a few bits) code with something a lot more readable.
}
#-------------------------------------------------------------------------------
proc system_print_all {} {

  global tcl_platform
  puts "" 

  puts "PLATFORM = $tcl_platform(platform)" ;# unix or macintosh or windows
  puts "OS       = $tcl_platform(os)"
  puts "MACHINE  = $tcl_platform(machine)"
  puts "USER     = $tcl_platform(user)"
  puts "THREADED = [info exists tcl_platform(threaded)]"
  puts "HOSTNAME = [info hostname]"

  puts ""  
}
#-------------------------------------------------------------------------------
proc TEST_system {} {

  system_print_all

  # небольшой пример на использование:
  set os [system_get_os]

  puts "Example used:" 
 
  if {$os == "Windows"} {   
    console show   
    puts "" 
    puts "This is Windows!!"
    
    #puts -nonewline "SELECT KEY and PRESS ENTER: "   
    #flush stdout  ;# все данные должны быть выведены
    
    #set answer [gets stdin]
    #puts " "
    
    #puts " ANSWER = $answer"
    #puts "" ;# да не работает это в Винде похоже..
    
    #-------------------------------------------------
  } else {
    puts "This is Not Windows !!"
  }


  puts ""  
}
#-------------------------------------------------------------------------------
proc TEST_dialog {} {

  puts ""
  puts -nonewline "SELECT KEY and PRESS ENTER: "   
  #flush stdout  ;# все данные должны быть выведены
    
  #set answer [gets stdin]        ; # просто виснит
  #set answer [congets stdin]     ; # 
  #set answer [tkcon_gets stdin]
  puts " "
    
  #puts "ANSWER = $answer"
  puts ""
    
}
#-------------------------------------------------------------------------------
proc ERROR {name} {

  puts $name

  exit
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
#

# пока поставим здесь, а потом, нверное, перенесем поближе
# ---> ab-comm.tl
#
# да, но в QNX это не будет работать ..
#package require Expect

# 1:d~.tl,TEST_dlink ................ FAILED
# т.е. только здесь я испольщую пока "pakage require Expect"

#-------------------------------------------------------------------------------
# Extended split command
# Being forced to use perl instead of Tcl, I've noticed that Perl split command 
# is much more powerful than Tcl one - it allows to split strings on arbitrary 
# regexps rather than on particular char, and, optionally, allows to put element 
# separators in the resulting list as separate elements.

# Fortunately, regexp command in Tcl is powerful enough to implement Perl-like 
# split just in few lines of Tcl code.

# This command behaves much like Tcl built-in split, but it takes regexp as 
# second argument, and defaults it to arbitrary amount of whitespace. If regexp 
# contains parentesis, text, which matches them would be inserted in resulting 
# list between splitted items as separate elements. 
#
#-------------------------------------------------------------------------------
# http://www.wagner.pp.ru/~vitus/software/tcl/xsplit.html
#-------------------------------------------------------------------------------
proc xsplit [list str [list regexp "\[\t \r\n\]+"]] {

  set list  {}

  while {[regexp -indices -- $regexp $str match submatch]} {
    lappend list [string range $str 0 [expr [lindex $match 0] -1]]

    if {[lindex $submatch 0]>=0} {
      lappend list [string range $str [lindex $submatch 0]\
                      [lindex $submatch 1]] 
    }	
    set str [string range $str [expr [lindex $match 1]+1] end] 
  }

  lappend list $str

  return $list
}
#-------------------------------------------------------------------------------
proc my_split {string} {

  set list {}

 foreach x [split $string ""] {
   
   if {$x == "\n"} {
     #puts "X = -----------------"

     #set str "spawn j_3620.tl  " ;# - если явно указать, то все зашибись 
     #puts "str = !$str!"         ;# - и печатает правильно
                                  #   ну и соответственно добавляет хорошо..
     lappend list $str
     #puts "LIST = "
     #puts "$list"
     #exit
     set str ""
   } else {
     if {$x == "\r"} {
       # откуда то взялись символы возврата каретки? - В НИХ ВСЕ ДЕЛО И БЫЛО!
       #puts "RRRRRRRRRRRRRRRRRRr"
       continue
     }
     #puts "X = !$x!" ;# оппа! а тут уже наблюдаем в последних символах фигню..
     append str $x
   }
 }

  #puts ""
  #puts "LIST = "
  #puts "$list"

 return $list
}
#-------------------------------------------------------------------------------
proc is_proc_exist {cmd} {

  set list_procs [info procs  $cmd]

  if {[llength $list_procs] != 0} {
    #puts "111"
    return 1
  } else {
    #puts "000"
    return 0
  }

}
#-------------------------------------------------------------------------------
proc xtermcontrol_get_font {} {

  # - сначала надо установить программку xtermcontrol;
  # - она действует только на xterm;
  # - и то чтобы она работала надо разрешить манипуляции с xterm:
  #   ctrl+rightclick and look for menu item names like 'Allow Window Ops'.
  #   или прописать в .Xdefaults:
  # *VT100.allowWindowOps: true
  # *VT100.allowTitleOps: true
  # *VT100.allowFontOps: true
  # 
  catch {[exec xtermcontrol --get-font]} ret

  return $ret
}
#-------------------------------------------------------------------------------
proc is_koi8_font {} {

  set ret [xtermcontrol_get_font]


  if {[string first "koi8" $ret] == -1} {
    return 0
  } else {
    return 1
  }

}
#-------------------------------------------------------------------------------
proc set_en {} {

  set ::is_koi8 0

}
#-------------------------------------------------------------------------------
proc set_ru {} {

  set ::is_koi8 1

#   if {![is_koi8_font]} {
#     puts ""
#     puts "set_ru: WARNING: not KOI8 font !!"
#     puts ""
#   }

}
#-------------------------------------------------------------------------------
proc is_ru {} {

  #return [is_koi8_font]

  return $::is_koi8;
}
#-------------------------------------------------------------------------------
proc latinica_from_koi8 {text_ru} {

  set nata_table {\
     а  a \
     б  b \
     в  v \
     г  g \
     д  d \
     е  e \
     ж  w \
     з  z \
     и  i \
     к  k \
     л  l \
     м  m \
     н  n \
     о  o \
     п  p \
     р  r \
     с  s \
     т  t \
     у  u \
     ф  f \
     х  x \
     ц  c \
     ч  h \
     ь  ` \
     ы  = \
     ю  y \
     я  q \

     А  A \
     Б  B \
     В  V \
     Г  G \
     Д  D \
     Е  E \
     Ж  W \
     З  Z \
     И  I \
     К  K \
     Л  L \
     М  M \
     Н  N \
     О  O \
     П  P \
     Р  R \
     С  S \
     Т  T \
     У  U \
     Ф  F \
     Х  X \
     Ц  C \
     Ч  H \
     Ь  ` \
     Ы  = \
     Ю  Y \
     Я  Q \

  } 

#      ш   
#      щ  d 
#      ъ  d 
#      э   

  set lat [string map $nata_table $text_ru]

  return $lat
}
#-------------------------------------------------------------------------------

# % encoding names

# cp860 cp861 cp862 cp863 cp864 tis-620 cp865 cp866 gb2312-raw gb12345 cp950 cp949 
# cp869 dingbats ksc5601 macCentEuro cp874 macUkraine jis0201 gb2312 euc-cn euc-jp 
# iso8859-10 macThai iso2022-jp jis0208 macIceland iso2022 iso8859-13 iso8859-14 
# jis0212 cp737 iso8859-15 iso8859-16 big5 euc-kr macRomania iso2022-kr gb1988 
# macTurkish macGreek ascii cp437 macRoman iso8859-1 iso8859-2 iso8859-3 iso8859-4 
# ebcdic koi8-r macCroatian iso8859-5 cp1250 macCyrillic iso8859-6 cp1251 cp1252 
# iso8859-7 macDingbats koi8-u iso8859-8 cp1253 iso8859-9 cp1254 cp1255 cp850 cp932 
# cp1256 cp852 cp1257 identity macJapan cp1258 utf-8 shiftjis cp855 cp936 cp775 
# symbol unicode cp857

#-------------------------------------------------------------------------------
proc koi_to_utf {text_koi8} {

  return [encoding convertfrom koi8-r $text_koi8]

}
#-------------------------------------------------------------------------------
proc koi_to_win {text_koi8} {

  set unicode [koi_to_utf $text_koi8]

  #return [encoding convertto cp1251 $unicode]
  return [encoding convertto cp866 $unicode]

}
#-------------------------------------------------------------------------------
proc koi_to_866 {text_koi8} {

  set unicode [koi_to_utf $text_koi8]

  return [encoding convertto cp866 $unicode]

}
#-------------------------------------------------------------------------------
proc koi_to_console {name_koi} {

  if {$::OS == "QNX"} {

    if {$::OSVER == "6.6.0"} {
      set name [koi_to_866  $name_koi]
    } else {
      set name [latinica_from_koi8 $name_koi]
    }

  } else {
    set name [koi_to_utf    $name_koi]
  }
  
  return $name 
} 	
#-------------------------------------------------------------------------------
proc puts_engrus_parse_args {args &text_eng_rus &is_newline} {

  USE_REFS

  if {[llength $args] > 2} {
    error "INVALID ARGUMENTS = $args"
  }

  if {[llength $args] == 2} {
    if {![string match -n* [lindex $args 0]]} {
      error "INVALID ARGUMENTS = $args"
    } 
    set text_eng_rus [lindex $args 1]
    set is_newline 0
  } else {
    set text_eng_rus [lindex $args 0]
    set is_newline 1
  }


}
#-------------------------------------------------------------------------------
proc puts_rus {args} {

  puts_engrus_parse_args  $args  text  is_newline

	set text_new  [koi_to_console $text]

  puts -nonewline  $text_new

  if {$is_newline} {puts ""} 

}
#-------------------------------------------------------------------------------
proc puts_engrus {args} {

# args -  либо один параметр, либо опция
# -nonewline и строка

  puts_engrus_parse_args  $args  text_eng_rus  is_newline

  # на самом деле у нас список:
  set text_en [lindex $text_eng_rus 0] 
  set text_ru [lindex $text_eng_rus 1] 

  #---------------------------------------------------

  if {[is_ru]} {
    # здесь бы надо сделать еще возможную перекодировку KOI8->UTF8
    #set string [koi_to_utf $text_ru]

    if {$::OS == "QNX"} {
      set string [koi_to_866 $text_ru]
    } else {
      # выводим русский текст (из редакторного кои8 в выходной утф8)
      set string [koi_to_utf $text_ru]
    }

  } else {
    set string $text_en 
  }

  #if {$is_newline} {append $string "\n"} 

  puts -nonewline $string

  if {$is_newline} {puts ""} 
}
#-------------------------------------------------------------------------------
proc TEST_en_ru {} {

  set text {
    {
      This is step 1
      Welcome !!! Wow !!!
    }    
    {
      Это шаг 1
      Добро пожаловать !!! Ого !!!
    }
  }

  set_ru

#   puts ""  
#   puts_engrus  {"Hello World !!" "Привет этот грёбаный мир !!"}
#   puts ""

  puts ""
  puts_rus  "Привет этот грёбаный мир !!"
  puts ""

  puts_engrus  $text

  puts ""
  puts -nonewline "Hello "

  set_en
  puts_engrus -nonewline {"World " "МИР "} 
  set_ru
  puts_engrus -nonewline {"World " "МИР "} 

  puts "! -------------------->"
  puts ""


}
#-------------------------------------------------------------------------------
proc simple_proc {arg1 arg2} {

  puts "ARG1 = $arg1"
  puts "ARG2 = $arg2"

}
#-------------------------------------------------------------------------------
proc TEST_info_body {} {

  set proc_args [info args  simple_proc]
  set proc_body [info body  simple_proc]

  puts ""
  puts "INFOARGS = proc_args" 
  puts "INFOBODY = $proc_body" 
  puts ""

  # сщздадим здесь новую процедуру из присланного тела
  #proc new_proc {arg1 arg2} $proc_body
  proc new_proc $proc_args $proc_body

  # и выполним ее:
  new_proc "Hello" "World"

}
#-------------------------------------------------------------------------------

#set_en
#set_ru

#-------------------------------------------------------------------------------
#  здесь надо более гибко, искать файл директроиях  
#-------------------------------------------------------------------------------
proc open_fname {fname paths} {

#   set paths {
#     ""
#     "./L/"
#   }

  foreach p $paths {

    if [catch {open $p$fname} fd] {
      #puts stderr "$fd"
      # никак не реагируем
    } else {
      # нашли и нормально открыли файл
      return $fd
    }
  }

  # не найдено ни одного файла
  puts ""
  puts stderr "OPEN_FNAME not find file $fname in all PATHS !!"
  puts ""

  exit
}
#-------------------------------------------------------------------------------
proc my_source {name} {

  if {[file exist $name]} {
    source $name
  }

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

if {$::OS == "QNX"} {

  set  ::ED "ped"
} else {
  set  ::ED "xe" 
}

set auto_path [linsert $auto_path 0 ./L] 

#-------------------------------------------------------------------------------

# # загрузим
# load b_capt.so Capture

#-------------------------------------------------------------------------------

#set ::SWITCH_DIR "/home/pilot/.MGENA/switch"


  # самая начальная инициация
  #set ::OS [system_get_os]
  #puts "::OS = $::OS"

  if {$::OS == "QNX"} {
    set ::is_color      0
    set ::is_color_menu 0
  }
  
  if {$::OS == "Windows" } {
    set ::is_color      0
    set ::is_color_menu 0
    # fconfigure stdout -encoding cp1251 ;# подвисает при выводе в WIndows
    # ???????????????
  }

#-------------------------------------------------------------------------------
