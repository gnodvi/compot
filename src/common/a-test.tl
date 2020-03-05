# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
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


  # 1: i_main -t2 ...
  # child process exited abnormally
  #     while executing
  # "exec ./i_main -t2 > E/OUT/1:i_main,-t2 2> /dev/null"
  
  # Tcl's exec treats any non-zero exit status as an exceptional situation. 
  # You need to catch the exec call, check the return value from catch and if 
  # nonzero examine the $errorCode variable. A thorough example here: 
  # http://wiki.tcl.tk/exec, click "Show Discussion" and scroll down to 
  # KBK's example.

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
  
  #exit ;# !!!!!!!!!
  return

  if ($err) {
    # при этом результат работы может и совпадать ..

    puts "ERROR !!!!!!!!!!!!!! :"
    puts "CMD = $cmd"
    puts "RET = $ret"
    puts ""
    #exit  ;# здесь надо бы тормозить работу
  }

}
#-------------------------------------------------------------------------------
proc run_tests  {dir_cmd dir_tst  n testname  is_replasing} {

  set testname_size [string length $testname]
  set n_beg $n
  set n_end [expr {$n + $testname_size -1}]

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

    #set fname [string trim $i $dir_tst]  ;# отбросим слева название OUT-директории
    #
    # только надо именно слева !!! а то справа отбрасывается буква "Е", например
    # j~.tl 1111 TEST_simp_BE
    set fname [string trimleft $i $dir_tst]  ;# отбросим слева название OUT-директории

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
  
    #puts "rr = $rr"

    # было в lib.sh:
    # (cd ${DIR_CMD} ; eval $CMD > $CALC_FILE  2> /dev/null)

    run_cmd_and_check  $is_replasing $dir_cmd $rr $fname \
      $CALC_FILE $TRUE_FILE  $CALC_FILE_SED $TRUE_FILE_SED  $DIFF_FILE   

  }

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
