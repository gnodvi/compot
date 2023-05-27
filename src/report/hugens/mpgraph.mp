% $Id: mpgraph.mp,v 1.2 2004/09/19 19:10:08 karl Exp $
% Figures for MetaPost doc, by John Hobby.  Public domain.

input graph

%filenametemplate "%j-%c.mps";

%if false:  %% Begin skipping already debugged figures
%fi input sarith %% End skipping of already debugged figures

%path p;
%gdata("PLOT.dat", s, augment.p(s1, newy(scantokens s2)); );

%-----------------------------------------------------------
verbatimtex
%&latex   %???????????!!
%\documentclass[5pt]{article}
\documentclass{article}

\newfont{\cyr}{wncyr7}
\newfont{\fnt}{cmr7}

\usepackage[T2A]{fontenc}
\usepackage[koi8-r]{inputenc}
\usepackage[english,russian]{babel}

\begin{document}
etex
%-----------------------------------------------------------
%verbatimtex
%\font\cyr=wncyr7
%etex

%-----------------------------------------------------------
u  := 1cm;
W  := 14u; 
%H  := 10u; 
H  := 9u; 

beginfig(1);

%path border; border = (0,0)--(W,0)--(W,H)--(0,H)--cycle;
%fill border withcolor 0.9 white; % 0.95 white;
  
draw begingraph (W, H);
%draw begingraph (3in, 2in);
%defaultfont:="cmr5"; %?????
%defaultfont:="\fnt"; %?????

path p[]; % пути для записи в них графиков

gdata ("PLOT.dat",
  $,  % имя переменной для обращения к столбцам данных (в нее считывается строка)  
  % далее идут команды выполняющиеся для каждой строчки:
  
  augment.p[2] ($1, scantokens $2); % 'scantokens' встраивает значение аргумента в код
  augment.p[3] ($1, scantokens $3);
)

color clr[];
clr1 := 0.9white;  clr2 := 0.8white;
%clr1 := 0.8white;  clr2 := 0.9white;
%clr1 := blue;  clr2 := red;

% границы графиков -----------------------------------
xmin := 3;
xmax := 9;

%setrange(origin, whatever,whatever);
%setrange (2, whatever, 10,whatever);

%setrange (2, 0, 10,whatever);
setrange (xmin, 0, xmax,whatever);

%gfill (2,0)--p3--(10,0)--cycle withcolor clr1;
%gfill (2,0)--p2--(10,0)--cycle withcolor clr2;
gfill (xmin,0)--p3--(xmax,0)--cycle withcolor clr1;
gfill (xmin,0)--p2--(xmax,0)--cycle withcolor clr2;
gdraw p3;
gdraw p2;


pair l[]; %%% "легенда" графиков
%l1  := (8.5, 3.2);
%l2  := l1 - (0, 0.3);
%len := 0.8;

l1  := (7.8, 10.0);
l2  := l1 - (0, 0.9);
len := 0.7;

interim linecap := butt; % надо только для легенды..
glabel.lft (btex MaxErr etex, l1);
gdraw l1--(l1 + (len,0)) withcolor clr1 withpen pencircle scaled 8;
glabel.lft (btex MidErr etex, l2);
gdraw l2--(l2 + (len,0)) withcolor clr2 withpen pencircle scaled 8; 

%\lower\fontdimen22\cmsy \
%autogrid ( otick.bot , itick.lft );
%setrange(2,10, whatever,whatever);

%glabel.lft (btex \cyr Error (in cells) etex rotated 90 ,OUT) ;
%glabel.bot (btex \cyr Huigens radius (in cells) etex ,OUT) ;
glabel.lft (btex Относительная ошибка (в процентах) etex rotated 90 ,OUT) ;
glabel.bot (btex Радиус Гюйгенса (в ячейках) etex ,OUT) ;

%gdraw (4.6, 0)--(4.6, 1.07) withcolor black withpen pencircle scaled 0.8; 
%gdraw (5.5, 0)--(5.5, 1.13) withcolor black withpen pencircle scaled 0.8; 
%gdraw (6.8, 0)--(6.8, 0.87) withcolor black withpen pencircle scaled 0.8; 
%gdraw (7.7, 0)--(7.7, 0.72) withcolor black withpen pencircle scaled 0.8;

for x:=3 upto 9:
  otick.bot(format("%g", x), x);
endfor

for y:=0 upto 10:
  otick.lft(format("%g", y), y);
endfor

endgraph;
endfig; 

%-----------------------------------------------------------
input hatching ;
%input mpattern ;
    
beginfig(2); 

numeric u; u=0.5cm;
path q;
q = (10u, 0 )..{dir -135}(0u, 0u){dir 135 }..
    (-10u, 0)..{dir 90}(0u, 0u){dir -90}..cycle;
hatchfill q withcolor red withcolor (25, 1u, -1);
draw q;

endfig;
%-----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%htchuse.mp

%input hatching ;
    
vardef star(expr n) =
 for i_:=0 upto 2n-1:
  if odd i_: 1/2 fi (right rotated (180*(i_/n))) --
 endfor cycle
enddef;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------
beginfig(3); % 100 

 path p; p:=unitsquare xscaled 50mm yscaled 25mm;
 hatchfill p withcolor red withcolor (45,2mm,-.5bp) withcolor (-45,2mm,-.5bp);

endfig;
%-----------------------------------------------------------
beginfig(4); % 101  
 interim hatch_match:=0;  
 path p; p:=star(10) xscaled 35mm yscaled 20mm rotated 20;
 
 hatchfill p withcolor (0,1,.5);
 draw image (hatchfill p
  withcolor (45,3bp,-.5bp) withcolor (-45,3bp,-.5bp);
 ) withcolor red dashed evenly; %evenly=dashpattern(on 3bp off 3bp)

endfig;
%-----------------------------------------------------------

beginfig(5); %102
 path p; p:=star(10) xscaled 35mm yscaled 20mm rotated 20;
 interim hatch_match:=0;
 
 hatchoptions (withcolor blue dashed evenly scaled 2);
 hatchfill p withcolor .75white withcolor (20,6bp,-.5bp);
 
 hatchoptions (withcolor (blue+green) dashed evenly shifted (3/2bp,0));
 hatchfill p withcolor (110,6bp,-.5bp);
endfig;
%-----------------------------------------------------------

beginfig(6); %103
 path p; p:=star(10) xscaled 35mm yscaled 35mm;
 save draw_hatched_band;
 
 vardef draw_hatched_band(expr za,zb,a,l,d) =
  save n_; n_:=length(za-zb)/l;
  for i_:=0 upto ceiling n_:
   fill star(10) xscaled 2/5l yscaled 2/5l
     shifted (i_/n_)[za,zb] withcolor (i_/n_)[green,blue];
  endfor
enddef;

 hatchfill p withcolor (red+green) withcolor (45,10bp,-1bp);
endfig;
%-----------------------------------------------------------


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 6  Границы
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
beginfig (7) 

u  := 1cm;
W  := 10.0u;  
H  :=  6.0u; 

path border; border = (0,0)--(W,0)--(W,H)--(0,H)--cycle;
%fill border withcolor 0.9 white; 

w  := W;
h  := H;
Cx := w/2;
Cy := h/2;

%path rect; rect = (0,0)--(w,0)--(w,h)--(0,h)--cycle;
%draw rect;

numeric r; r := 2.2u;
l_add := r / 5;
w_mid := w / 5;

pair p[], l[];

p1 := (Cx-w_mid/2, h);
p2 := (Cx-w_mid/2, 0);

p3 := (Cx+w_mid/2, h);
p4 := (Cx+w_mid/2, 0);

l1 := p1 - (l_add,0);
l2 := p2 - (l_add,0);

fill (0,0)--p2--p1--(0,h)--cycle withcolor 0.9white;
fill p4--(w,0)--(w,h)--p3--cycle withcolor 0.8white;

draw p1--p2;
draw p3--p4;
%draw l1--l2;

draw (0,0)--(w,0)--(w,h)--(0,h)--cycle;

%-------------------
xB := w_mid/2 + l_add;
yB := sqrt (r*r - xB*xB);
pair B; B := (Cx-xB, Cy+yB);
pair D; D := (Cx-xB, Cy-yB);

draw B withpen pencircle scaled 4;
draw D withpen pencircle scaled 4;

path p;
%p := fullcircle scaled 2r shifted (Cx, Cy);
p := D--B..(Cx, Cy+r)..(Cx+r, Cy)..cycle;

%-------------------
drawdot (Cx, Cy) withpen pencircle scaled 4;

%hatchoptions (withcolor (0.7white));
%hatchfill p withcolor (45,2mm,-.5bp) withcolor (-45,2mm,-.5bp);

interim hatch_match:=0;  
draw image (hatchfill p
  withcolor (45,3bp,-.5bp) withcolor (-45,3bp,-.5bp);
  ) withcolor 0.6white dashed evenly; %evenly=dashpattern(on 3bp off 3bp)

draw p;

%label (btex Низкая-Cкорость etex,  (  (w-w_mid)/4, 0.7u)) ;%scaled 1.2;
%label (btex Высокая-Cкорость etex, (w-(w-w_mid)/4, 0.7u)) ;%scaled 1.2;
label (btex \large LOW etex,  (  (w-w_mid)/4, 0.9u)) ;%scaled 1.2;
label (btex \large HIGH etex, (w-(w-w_mid)/4, 0.9u)) ;%scaled 1.2;
endfig;

%-----------------------------------------------------------
end
%-----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%path p;
%gdata("timepop.d", s, augment.p(s1, newy(scantokens s2)); );
%gdraw p;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

beginfig(2);
draw begingraph(3in,2in);
  gdraw "G/agepop91.d" plot btex$\bullet$etex;
  endgraph;
endfig;

beginfig(3);
draw begingraph(3in,2in);
  glabel.lft(btex \vbox{\hbox{Population} \hbox{in millions}} etex, OUT);

%  glabel.bot(btex Age in years etex, OUT);
%  glabel.bot(btex \cyr Vozrast in years etex, OUT);
  glabel.bot(btex \cyr qwertyuiop[] asdfghjkl;' zxcvbnm,./ etex, OUT);
%  glabel.bot(btex \cyr logarifm i plowad\char126 etex, OUT);
  
  gdraw "G/agepopm.d";
  endgraph;
endfig;

beginfig(4);
draw begingraph(3in,2in);
 glabel.lft(btex \vbox{\hbox{Population} \hbox{in millions}} etex, OUT);
 glabel.bot(btex Age in years etex, OUT);
 setrange(origin, whatever,whatever);
 gdraw "G/agepopm.d";
 endgraph;
endfig;

beginfig(5);
draw begingraph(2.3in,2in);
 setcoords(log,log);
 glabel.lft(btex Seconds etex,OUT);
 glabel.bot(btex Matrix size etex,
   OUT);
 gdraw "G/matmul.d" dashed evenly;
 glabel.ulft(btex Standard etex,8);
 gdraw "G/matmul.d";
 glabel.lrt(btex Strassen etex,7);
 endgraph;
endfig;

beginfig(6);
draw begingraph(6.5cm,4.5cm);
 setrange(80,0, 90,whatever);
 glabel.bot(btex Year etex, OUT);
 glabel.lft(btex \vbox{\hbox{Emissions in} \hbox{thousands of}
   \hbox{metric tons} \hbox{(heavy line)}}etex, OUT);
 gdraw "G/lead.d" withpen pencircle scaled 1.5pt;
 autogrid(,otick.lft);
 setcoords(linear,linear);
 setrange(80,0, 90,whatever);
 glabel.rt(btex \vbox{\hbox{Micrograms} \hbox{per cubic}
   \hbox{meter of air} \hbox{(thin line)}}etex, OUT);
 gdraw "G/lead.d";
 autogrid(otick.bot,otick.rt);
 endgraph;
endfig;

%-----------------------------------------------------------
input sarith

beginfig(7);
vardef newy(expr y) = (256/75)*y + mlog y enddef;
draw begingraph(3in,2in);
 glabel.lft(btex \vbox{\hbox{Population} \hbox{in millions}} etex, OUT);
 path p;
 gdata("G/timepop.d", $, augment.p($1, newy(Scvnum $2)); );
 gdraw p withpen nullpen;
 for y=5,10,20,50,100,150,200,250:
   grid.lft(format("%g",y), newy(y)) withcolor .85white;
 endfor
 autogrid(grid.bot,) withcolor .85white;
 gdraw p;
 frame.llft;
 endgraph;
endfig;

beginfig(8);
defaultfont:="cmr7";
draw begingraph(3in,2in);
  glabel.lft(btex \vbox{\hbox{Life}\hbox{expectancy}} etex, OUT);
  glabel.bot(btex Per capita G.N.P. (thousands of dollars) etex, OUT);
  setcoords(log,linear);
  gdata("G/countries.d", s,
    glabel(s3, s1, s2);
  )
  endgraph;
endfig;

beginfig(9);
draw begingraph(3in,2in);
  glabel.lft(btex \vbox{\hbox{Quadrillions}\hbox{of BTU}} etex, OUT);
  path p[];
  numeric t;
  gdata("G/energy.d", $,
    t:=0; augment.p1($1,0);
    for j=2 upto 5:
       t:=t+scantokens $[j]; augment.p[j]($1,t);
    endfor)
  picture lab[];
  lab2=btex coal etex; lab3=btex crude oil etex;
  lab4=btex natural gas etex; lab5=btex hydroelectric etex;
  for j=5 downto 2:
    gfill p[j]--reverse p[j-1]--cycle withcolor .16j*white;
    glabel.lft(image(unfill bbox lab[j]; draw lab[j]), .7+length p[j]);
  endfor
  endgraph;
endfig;

%-----------------------------------------------------------
%end
%-----------------------------------------------------------

beginfig(10);
draw format("%g",2+2);
endfig;

beginfig(11);
draw format("%3g","6.022e23");
endfig;


%-----------------------------------------------------------
end
%-----------------------------------------------------------
