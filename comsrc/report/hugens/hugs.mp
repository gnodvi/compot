%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

verbatimtex \documentclass{article}
%<-- My T2A encoding
\usepackage[warn]{mathtext}
\usepackage[T2A]{fontenc}
\usepackage[koi8-r]{inputenc}
\usepackage[english,russian]{babel}

\newcommand{\fns}{\footnotesize}

\begin{document}
etex;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%vardef sqr primary x = (x*x) enddef;
%vardef log primary x = (if x=0: 0 else: mlog(x)/mlog(10) fi) enddef;
%vardef ln primary x = (if x=0: 0 else: mlog(x)/256 fi) enddef;
%vardef exp primary x = ((mexp 256)**x) enddef;
%vardef inv primary x = (if x=0: 0 else: x**-1 fi) enddef;
%vardef pow (expr x,p) = (x**p) enddef;

% trigonometric functions
numeric pi; pi := 3.1415926;
numeric radian; radian := 180/pi; % 2pi*radian = 360 ;

%vardef tand primary x = (sind(x)/cosd(x)) enddef;
%vardef cotd primary x = (cosd(x)/sind(x)) enddef;
vardef sin primary x = (sind(x*radian)) enddef;
vardef cos primary x = (cosd(x*radian)) enddef;
%vardef tan primary x = (sin(x)/cos(x)) enddef;
%vardef cot primary x = (cos(x)/sin(x)) enddef;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

color yellow; yellow:= green + red;

% для новой версии (1.000) ?
% filenametemplate "%j.%2c.mps";

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 1  Принцип Гюйгенса
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

u      := 1cm;
%breite := 12.5u; hoehe  :=  6.2u; 
breite := 12.5u; hoehe  :=  6.2u; 

beginfig(1)

%------------------------------------------------------
% задаем и рисуем стрелочки движения фронтов и текст
%------------------------------------------------------
dx := .8u;  
dy := .5u;

% перед исходным фронтом
pair i[];
i0 = (2.5u, 2.0u); % текст
i1 = (5.0, 1.2)*u;
i2 = (3.7, 2.7)*u;
% после продвинутого фронта
pair o[];
o0 = (7.6u, 3.8u); % текст
o1 = (6.7, 4.2)*u;
o2 = (7.7, 2.7)*u;

label (btex Волновой фронт etex, i0); 
label (btex в момент времени $t$ etex, i0-(0, 0.4u)); 
pickup pencircle scaled 1; 
draw i1;
draw i2;
pickup pencircle scaled .5;
drawarrow (i1--(i1+(dx,dy)));
drawarrow (i2--(i2+(dx,dy)));

label.urt (btex Волновой фронт etex, o0); 
label.urt (btex в момент времени  $t+\bigtriangleup t$ etex, o0-(0, 0.4u)); 
pickup pencircle scaled 1;  
draw o1;
draw o2;
pickup pencircle scaled .5;
drawarrow (o1--(o1+(dx,dy)));
drawarrow (o2--(o2+(dx,dy)));

%------------------------------------------------------
pair R;
numeric r; r := 1.2u;
%R := (1.2u, 1.2u);
R := (r, r);

%------------------------------------------------------
pair A, B;

A  := (3.7u, 5.0u);
B  := (7.2u, .7u);
z2  = 1/2[A,B];
z1  = 1/2[A,z2] + (.2u, .2u);
z3  = 1/2[z2,B] - (.2u, .2u);

pickup pencircle scaled 3; 
draw A ; label.ulft ("A", A);
draw B ; label.rt ("B", B);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1 upto 3:
  pickup pencircle scaled 3; 
  draw z[i];
  
  pickup pencircle scaled .5; 
  draw quartercircle scaled 2r rotated -15 shifted z[i];
endfor

path p; % сформируем путь (кривую фронта)
p := A..z1..z2..z3..B ;   
draw p withpen pencircle scaled  0.9; % рисуем начальный фронт

vardef vect (expr l,alfa) = r * (cosd(alfa),sind(alfa)) enddef;

pair A', B';
pair w[];

A' := A  + vect (r, 45);
B' := B  + vect (r, 45);

w1  = z1 + r*dir 30;
w2 := z2 + r*dir 30;
w3  = z3 + r*dir 30;

pickup pencircle scaled 3; 
draw A'; label.lft ("A'", A');
draw B'; label.rt ("B'", B');

%for i=1 upto 3:
%  draw w[i] withcolor blue;
%endfor

path r; 
r := A'..w1..w2..w3..B' ;   
draw r withpen pencircle scaled  0.9;     

%-------------------------------------------

picture Base; Base :=currentpicture;
clearit;

path border;
border = (0,0)--(breite,0)--(breite,hoehe)--(0,hoehe)--cycle;

%fill border withcolor 0.97 white;
fill border withcolor white;

draw Base shifted (0, -0.3u);

endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2  Пожар в прерии
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

u      := 1cm;
breite := 12.5u; 
hoehe  :=  6.2u; 

%--------------------------------------
def mesh_set (suffix b) (expr i_beg, i_end, j_beg, j_end, color_set) =
begingroup
save i, j;
  
for i=i_beg upto i_end: 
for j=j_beg upto j_end:
  b[i][j] := color_set;
endfor
endfor

endgroup;
enddef;
%--------------------------------------
def mesh_draw (suffix b) (expr ni, nj, xy_beg, xy_step, k_dl,  clr) =
begingroup    
save p, rect, line, w_step, h_step, i, j;

%color clr; clr := red;
pair p[]; path rect, line; numeric w_siz, h_siz;

w_siz := xy_step * ni;
h_siz := xy_step * nj;
 
for i=1 upto ni: 
for j=1 upto nj:
    p0 := xy_beg + ((i-1)*xy_step, (j-1)*xy_step);
    rect := p0--(p0+(xy_step, 0))--(p0+(xy_step, xy_step))--(p0+(0, xy_step))--cycle;

    fill rect withcolor b[i][j];
    %draw rect withpen pencircle scaled  0.9;
endfor
endfor

%dl := 0.4 xy_step;
dl := k_dl * xy_step;

for i=1 upto ni+1: 
  xx := (i-1)*xy_step;
  line := (xx, 0-dl)--(xx, h_siz+dl);
  draw line shifted xy_beg withcolor clr;
endfor

for j=1 upto nj+1: 
  yy :=  (j-1)*xy_step;
  line := (0-dl, yy)--(w_siz+dl, yy); 
  draw line shifted xy_beg withcolor clr;
endfor

endgroup;
enddef;
%--------------------------------------

beginfig(2)

% зададим и инициируем начально массив
color a[][];
numeric nn; nn := 10; 
  
for i=1 upto nn: 
for j=1 upto nn:
  a[i][j] := white;
endfor
endfor

% а теперь раскрасим его, т.е. зададим на нем распределение данных
color co[];
%co0 = red; co1 = red; co2 = blue; co3 = green; 
co0 = black; co1 = 0.8white; co2 = 0.4white; co3 = 0.9white; 

mesh_set (a, 1, 4, 5, 10, co1);
mesh_set (a, 1, 2, 3, 4, co1);
a[3][4] := co1;
mesh_set (a, 5, 6, 9, 10, co1);
mesh_set (a, 5, 5, 7,  8, co1);

mesh_set (a, 8, 10, 9, 10, co2);
mesh_set (a, 9, 10, 8,  8, co2);
a[10][7] := co2;

a[2][2] := co3;
a[4][4] := co3;
a[5][6] := co3;
a[6][8] := co3;
a[7][10] := co3;

%--------------------------------------
path border;
border = (0,0)--(breite,0)--(breite,hoehe)--(0,hoehe)--cycle;

%fill border withcolor 0.98 white;
fill border withcolor white;
%draw border withpen pencircle scaled  0.9;

pair point_beg; point_beg := (4u, 0.5u);
numeric size, st;
size := 5u;
st := size / nn;

pickup pencircle scaled .9; 
mesh_draw (a, nn, nn, point_beg, st, 0.4, black);

%--------------------------------------
% нарисуем линию фронта по заданным  точкам
pair t[];

t0 := (-0.4, 0.9);

t1 := (1.6, 1.7);
t2 := (3.3, 3.4);
t3 := (4.5, 5.3);
t4 := (5.6, 7.7);
t5 := (6.4, 9.5);

t6 := (6.8, 10.4);

%drawarrow ((0.1,0.1)--(10.0,10.0));
pair pont[];   %%%%%%%%%% !!!!!!!!!  Заменил point -> pont и все заработало !!!!
%drawarrow ((0.1,0.1)--(10.0,10.0));

pickup pencircle scaled 4; 

for i=0 upto 6:
  pont[i] := point_beg + t[i] * st;
  if (i<>0) and (i<>6):
    draw pont[i] withcolor co0;
  fi;
endfor


draw pont0..pont1..pont2..pont3..pont4..pont5..pont6
     withpen pencircle scaled .9;

 
endfig;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%--------------------------------------
def draw_lines (suffix b) (expr point_beg, st, is_array, is_draw,  num, l_beg, l_end, r_beg, r_end,
                           clr) =
begingroup
save t, pbeg, pend, i, j;

%color clr; clr := red;
pair t[][], pbeg[], pend[], ind[][];

for i=0 upto num:
  pbeg[i] = (i/num)[l_beg, r_beg];
  pend[i] = (i/num)[l_end, r_end];
  
  if (is_draw = 1):
  draw pbeg[i]--pend[i] withcolor clr; % рисуем линии
  fi;

  for j=0 upto num:
    t[i][j] = (j/num)[pbeg[i],pend[i]];
    % почему здесь просто нельзя написать 't'

    if (is_draw = 1):
    draw t[i][j] withpen pencircle scaled 4 withcolor clr; % рисуем точки
    fi;

    if (is_array = 1):
    % попробуем посчитать индексы мелкозерн-той ячейки для этой точки
    ind[i][j] = (t[i][j] - point_beg) / st;
    b[ceiling xpart ind[i][j]][ceiling ypart ind[i][j]] := 0.8white;
    fi;
    
  endfor  
endfor

endgroup;
enddef;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 4  Дробление ячеек
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
beginfig(3)

u  := 1cm;
W  := 16.0u; 
H  :=  7.0u; 

path border; border = (0,0)--(W,0)--(W,H)--(0,H)--cycle;
fill border withcolor white; % 0.95 white;

%----------------------------------------------
def draw_cell (suffix b) (expr point_beg, st, is_array, is_draw, clr, num) (suffix p) =
begingroup

%color clr; clr := red;

draw_lines (b, point_beg, st, is_array, is_draw,  num, p1,p2, p3,p4, clr);
draw_lines (b, point_beg, st, is_array, is_draw,  num, p1,p3, p2,p4, clr);
  
endgroup;
enddef;
%----------------------------------------------
def draw_full_pic (suffix b, c_node) (expr num, point_beg) =
begingroup

% переведем узлы в реальную систему координат
pair p[];
for i=1 upto 4:
  p[i] := point_beg + c_node[i] * st;
endfor

pickup pencircle scaled 1.2; 

%% здесь можно не рисовать, а только заполнять массив H-сетки
draw_cell (b, point_beg, st, 1, 0, black, num, p);

pickup pencircle scaled .9; 
mesh_draw (b, ni, nj, point_beg, st, 0.1, black);

%% а здесь наоборот - можно только рисовать  !!
draw_cell (b, point_beg, st, 0, 1, black, num, p);

endgroup;
enddef;
%----------------------------------------------

% зададим и инициируем начально массив
color a[][];
ni := 5; 
nj := 4; 
st := 1.2u;

pair cell_node[]; % узлы ячейки относительно мелкозернистой сетки 
cell_node1 := (0.8, 0.8);
cell_node2 := (3.2, 0.7);
cell_node3 := (1.8, 3.2);
cell_node4 := (3.8, 1.9);

%---------------------------------
for i=1 upto ni: 
for j=1 upto nj:
  a[i][j] := white;
endfor
endfor
  
draw_full_pic (a, cell_node, 2, (0.5u, 1.0u));

draw_full_pic (a, cell_node, 4, (9.0u, 1.0u));

endfig;

%----------------------------------------------
def draw_circ_mesh (expr centr, r_min, r_max,  is_array, is_draw, clr) =
begingroup

if (is_array = 1):
  num  := 10;
else:
  num  := 1;
fi;
  
pair n[][];

dfi := 180 / 4;

for i=0 upto 3:
  n[i][1] := (centr) + r_min*dir (i*dfi);
  n[i][2] := (centr) + r_max*dir (i*dfi);
  n[i][3] := (centr) + r_min*dir ((i+1)*dfi);
  n[i][4] := (centr) + r_max*dir ((i+1)*dfi);
  
  %draw_cell (0, 0, 0,  is_array, is_draw,  num, n[i]);
  draw_cell (a, (0.2u, 0.1u), st,  is_array, is_draw,  clr, num, n[i]);
endfor

endgroup;
enddef;
%---------------------------------------------------
def draw_pic_left (expr var) =
begingroup

save i, j, ni, nj, st, centr, a;

numeric i, j, ni, nj, st;
pair centr;
color a[][];

centr := (4.0u, 1.0u);
r_min := 1.5u;
r_max := 3.5u;

% зададим и инициируем начально массив
ni := 13; 
nj := 9; 
st := 0.59u;

for i=1 upto ni: 
for j=1 upto nj:
  a[i][j] := white;
endfor
endfor

pickup pencircle scaled .5; 

if (var = 1):
  mesh_draw (a, ni, nj, (0.2u, 0.1u), st, 0.1, 0.9white);
  draw_circ_mesh (centr, r_min, r_max, 0, 1, black); 
else:
  draw_circ_mesh (centr, r_min, r_max, 1, 0, black); % переносим значения на H-сетку
  
  mesh_draw (a, ni, nj, (0.2u, 0.1u), st, 0.1, black);
  draw_circ_mesh (centr, r_min, r_max, 0, 1, 0.9white); 
fi;

endgroup;
enddef;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 4  Габаритные размеры
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
beginfig(4) 

u  := 1cm;
W  :=  8.0u;  
H  :=  5.5u; 

path border; border = (0,0)--(W,0)--(W,H)--(0,H)--cycle;
fill border withcolor 0.9 white; % 0.95 white;

draw_pic_left (1);
endfig;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 5  Габаритные размеры
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
beginfig(5) 

u  := 1cm;
W  :=  8.0u;  
H  :=  5.5u; 

path border; border = (0,0)--(W,0)--(W,H)--(0,H)--cycle;
fill border withcolor 0.9 white; 

draw_pic_left (2);
 
endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%----------------------------------------------
def x_rectarc (expr x_beg, y_beg,  w, h, a, clr) =
begingroup

numeric i[], j[];

i1 := x_beg;
i4 := i1 + w;
i2 := i1 + a;
i3 := i4 - a;

j1 := y_beg;
j4 := j1 + h;
j2 := j1 + a;
j3 := j4 - a;

path p; p :=

(i2, j1)--

(i3, j1)--
(i4, j2)-- %arc
(i4, j3)-- 
(i3, j4)-- %arc
(i2, j4)--
(i1, j3)-- %arc
(i1, j2)-- cycle;

fill p withcolor clr;
draw p;

endgroup;
enddef;
%----------------------------------------------
def x_rarrow_l (expr x_beg, y_beg,  l, n) =
begingroup

x_end := x_beg + l;
y_end := y_beg;  
xr := x_end - n;
  
draw (x_beg, y_beg)--(x_end, y_end)--(xr, y_end-n)--(xr, y_end+n)--(x_end, y_end);  

endgroup;
enddef;
%----------------------------------------------
vardef x_circle (expr orig, radius) =
begingroup

path p;
p := fullcircle scaled 2radius shifted orig;

endgroup;
enddef;
%----------------------------------------------
def x_circle_ol (expr orig, radius, clr_fill, clr_line) =
begingroup
    
path p;
  
%  x_circle (cr, xc, yc, radius);
p := fullcircle scaled 2radius shifted orig;
%p := x_circle (orig, radius);

%  x_draw_ol (cr, r0, g0, b0, alpha,  r1, g1, b1);
fill p withcolor clr_fill; 
draw p withcolor clr_line; 
    
endgroup;
enddef;
%----------------------------------------------
def h_schema_newfront (expr orig,  r_min, r_max, clr_fill) =
begingroup
    
%  // рисуем большую окружность и закрашиваем ее как сгоревшую  
x_circle_ol (orig, r_max, clr_fill, black);

%  // рисуем маленькую окружность и закрашиваем ее 
x_circle_ol (orig, r_min, 0.5black, black);

endgroup;
enddef;
%----------------------------------------------
def h_schema_circles (expr num, orig, r, r_hugens) =
begingroup
save xc, yc, alfa_min, alfa_max, alfa, beta, dx, dy; 

numeric xc, yc, alfa_min, alfa_max, alfa, beta, dx, dy;

xc := xpart orig;
yc := ypart orig;

alfa_min := 0; 
alfa_max := 360; 
beta := (alfa_max - alfa_min) / num;
  
alfa := alfa_min;
forever:
  exitif (alfa > alfa_max);

  dx := r * cosd (alfa);
  dy := r * sind (alfa);
  draw fullcircle scaled 2r_hugens shifted (orig+(dx, dy));

  alfa := alfa + beta;    
endfor

endgroup;
enddef;
%----------------------------------------------
def h_schema_step (expr x_beg, y_beg,  w, h,  n_step, rmin, rmax, rhug) =
begingroup

color clr_fill; clr_fill := 0.95white;    %clr_fill := yellow;
color clr_fron; clr_fron := 0.75white;    %clr_fron := red;
  
x_rectarc (x_beg, y_beg, w, h, 4, clr_fill);

%/*   ; вычисляем центр прямоугольника */
pair orig; orig := (x_beg, y_beg) + (w/2, h/2);

if ((n_step = 1) or (n_step = 2)):
    h_schema_newfront (orig, rmin, rmax, clr_fron);
fi  
  
if (n_step = 2):
    h_schema_circles (6, orig, rmax, rhug); %рисуем фронты Гюйгенса
fi  

if (n_step = 3):
    h_schema_newfront (orig, rmax, rmax + rhug, clr_fron);
fi  
  
endgroup;
enddef;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 6  Схема
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
beginfig(6) 

u  := 0.3mm;
  
W := 500u;  H := 400u;
w := 120u;  h := 160u; 

numeric x[], y[];
x1 := 50u;
y2 := 30u;

dx := 20u;
dy := 20u;

rhug = w / 7;
rmin = 0.3u;
rmax = w / 13;

x2 = x1 + w + dx;
x3 = x2 + w + dx;
y1 = y2 + h + dy;

ar  = dx / 3.0;
al  = dx;

numeric ax[], ay[];
ax1 = x1 + w;
ax2 = x2 + w;
ay1 = y1 + 0.5 * h;
ay2 = y2 + 0.5 * h;

path border; border = (0,0)--(W,0)--(W,H)--(0,H)--cycle;
fill border withcolor 1.0 white; 

%draw_pic_left (2);

h_schema_step (x1, y1,  w, h,  1, rmin, rmax, rhug);
h_schema_step (x2, y1,  w, h,  2, rmin, rmax, rhug);
h_schema_step (x3, y1,  w, h,  3, rmin, rmax, rhug);

x_rarrow_l (ax1, ay1, al, ar);
x_rarrow_l (ax2, ay1, al, ar);

rmin := rmax;
rmax := rmax + rhug;

h_schema_step (x2, y2,  w, h,  2, rmin, rmax, rhug);
h_schema_step (x3, y2,  w, h,  3, rmin, rmax, rhug);

x_rarrow_l (ax1, ay2, al, ar); 
x_rarrow_l (ax2, ay2, al, ar); 

endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 7  Метод геодезических
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
beginfig(7) 

u := 0.27mm;  
W := 500u;  H := 250u;

path border; border = (0,0)--(W,0)--(W,H)--(0,H)--cycle;
fill border withcolor 1.0 white; 

numeric wradius, hradius, Xx,Xy, Yx,Yy, Zx,Zy, Dx,Dy, Tx,Ty, Hx,Hy, Sx,Sy;     

wradius = 125u;
hradius =  75u;

Xx = 205u; Xy =    0u;
Yx = -40u; Yy =  -80u;
Zx =   0u; Zy = +125u;

Dx = -110u; Dy = +90u;
Tx =  -45u; Ty = +45u;
Hx =   55u; Hy = +15u;
Sx =  125u; Sy = -35u;

color clr_mark, clr_line, clr_fill;   
%clr_mark := blue;
%clr_line := red;
%clr_fill := yellow;

clr_mark := black;
clr_line := black;
clr_fill := 0.9white;

% ----------------------------------------
picture img; img := image (

path top, bot;

% верхний эллипс - меридиан через зенит
%draw (wradius, 0){dir 90}..tension 1.0..{dir 180}(0, hradius){dir 180}..{dir -90}(-wradius, 0);
top := halfcircle xscaled 2wradius yscaled 2hradius;

% видимый край нижнего сечения (сплощной низ эллипса
bot := halfcircle xscaled 2wradius yscaled hradius rotated 180 ;

fill top--cycle withcolor clr_fill; 
fill bot--cycle withcolor clr_fill; 
draw bot--top; 

% невидимый край нижнего сечения (пунктирный верх эллипса)
path mid; mid := halfcircle xscaled 2wradius yscaled hradius;
draw mid dashed evenly;

% ----------------------------------------
%  Ось OX
draw    (-205u, 0)--(-wradius, 0);
draw (-wradius, 0)--(+wradius, 0) dashed evenly;
drawarrow  (wradius, 0)--(Xx, Xy);

% Ось OY
path Yaxe; Yaxe = ((0, 0)--(Yx, Yy));
numeric u; pair U;
(u, whatever) = Yaxe intersectiontimes bot;
U = point u of Yaxe;
    
draw  (0, 0)--U  dashed evenly; 
drawarrow   U--(Yx, Yy);

% Ось OZ
draw (0, 0)--(0, hradius) dashed evenly; 
drawarrow  ((0, hradius)--(Zx, Zy));
% ----------------------------------------

% линии касательных DT и SH
draw (Dx, Dy)--(Tx, Ty) withcolor clr_line; 
draw (Sx, Sy)--(Hx, Hy) withcolor clr_line; 
% геодезическая по поверхности 
draw (Tx,Ty){dir25} .. {dir-70}(Hx,Hy) withcolor clr_line;

% реперные точки
pickup pencircle scaled 3;

drawdot (0,   0);
drawdot (Dx, Dy);
drawdot (Tx, Ty);
drawdot (Hx, Hy);
drawdot (Sx, Sy);

%  // надписи у точек и концов осей координат
label.top (btex D (target) etex, (Dx, Dy)) withcolor clr_mark;
label.lft ("D*", (Tx-1u, Ty-2u)) withcolor clr_mark;
label.rt  ("S*", (Hx+5u, Hy+1u)) withcolor clr_mark;
label.bot (btex S (source) etex, (Sx, Sy)) withcolor clr_mark;
label.ulft("O",  (0, 0+2u))       withcolor clr_mark;
label.ulft("X",  (Xx-7u, Xy+2u))  withcolor clr_mark;
label.ulft("Y",  (Yx, Yy))        withcolor clr_mark;
label.lrt ("Z",  (Zx+2, Zy))      withcolor clr_mark;

%  горизонты касательных (дуги по трем точкам)
pair L[], R[];

L1 = point 2.3 of bot; %draw L1 withpen pencircle scaled 3;
R1 = point 0.7 of top; %draw R1 withpen pencircle scaled 3;
draw L1..(Hx, Hy)..R1 withpen pencircle scaled 0.5;

L2 = point 0.5 of bot; %draw L2 withpen pencircle scaled 3;
R2 = point 2.4 of top; %draw R2 withpen pencircle scaled 3;
draw L2..(Tx, Ty)..R2 withpen pencircle scaled 0.5;

path rot; rot = halfcircle xscaled 40u yscaled 30u rotated 90 shifted (-wradius-20, 0);
drawarrow rot withpen pencircle scaled 0.5 withcolor clr_mark;

);

draw img  shifted (W/2, H/2-20u);

endfig;

% ------------------------------------------------------------------------------
def x_draw_cell (suffix a) =
begingroup

  fill a8--a4--a3--a7--cycle withcolor 0.85white;
  fill a8--a7--a5--a6--cycle withcolor 0.9white;
  fill a8--a6--a2--a4--cycle withcolor 0.75white;
  
  draw a5--a6--a2--a4--a3--a7--a5;

  draw a8--a7;
  draw a8--a6;
  draw a8--a4;

  draw a1--a5 dashed evenly;
  draw a1--a2 dashed evenly;
  draw a1--a3 dashed evenly;

endgroup;
enddef;
% ------------------------------------------------------------------------------
def make_a (suffix a)(expr xc, yc, size) =
begingroup

  stp := (size/2);
  a1:= (xc, yc);

  a2:= a1 + (size, 0);
  a3:= a1 + (0, size);
  a4:= a1 + (size, size);

  a5:= a1 - (stp, stp);
  a6:= a2 - (stp, stp);
  a7:= a3 - (stp, stp);
  a8:= a4 - (stp, stp);

endgroup;
enddef;
% ------------------------------------------------------------------------------
def x_draw_cube_old (expr xc, yc, size) =
begingroup

  pair a[];

  make_a (a, xc, yc, size);

  x_draw_cell (a);

  label.urt (btex \small 0 etex, a1);
  
  label.ulft (btex \small 1 etex, a2);
  label.lrt (btex \small 1 etex, a3);
  label.urt (btex \small 1 etex, a5);

endgroup;
enddef;
% ------------------------------------------------------------------------------
vardef TEX primary s =
  write "verbatimtex"            to "mptextmp.mp";
  write "\input{preheader-base}" to "mptextmp.mp";
  write "\begin{document}"       to "mptextmp.mp";
  write "etex"                   to "mptextmp.mp";
  write "btex "&s&" etex"        to "mptextmp.mp";
  write EOF                      to "mptextmp.mp";
  scantokens "input mptextmp"
enddef ;

%def not (expr n) = begingroup btex \fns n etex endgroup; enddef;
%def nnn = btex \fns 1 etex enddef;
%ydef nnn (expr n) = btex \fns n etex enddef;
%def nnn (expr n) = TEX(\\fns n) enddef;
% ------------------------------------------------------------------------------
def x_draw_cube_new (expr xc, yc, s) =
begingroup

  pair a[];

  make_a (a, xc, yc, s);

  a1 := a1 - (0,   s/5);
  a4 := a4 - (s/5, s/5);
  a7 := a7 - (0,   s/5);

  x_draw_cell (a);

%  i := 10;
%  label.ulft (TEX("\("&decimal(i)&"\)"), a1);
  %label.ulft (TEX("O"), (0,0));
  
  label.ulft (btex \fns 1 etex, a1);  label.urt  (btex \fns 000 etex, a1);
  label.lft  (btex \fns 2 etex, a2);  label.rt   (btex \fns 100 etex, a2);
  label.bot  (btex \fns 3 etex, a3);  label.top  (btex \fns 010 etex, a3);
  label.lft  (btex \fns 4 etex, a4);  label.rt   (btex \fns 110 etex, a4);
  label.urt  (btex \fns 5 etex, a5);  label.llft (btex \fns 001 etex, a5);
  label.ulft (btex \fns 6 etex, a6);  label.lrt  (btex \fns 101 etex, a6);
  label.lrt  (btex \fns 7 etex, a7);  label.lft  (btex \fns 011 etex, a7);
  label.llft (btex \fns 8 etex, a8);  label.lrt  (btex \fns 111 etex, a8);

endgroup;
enddef;
% ----------------------------------------------
def x_rarrow (expr x_beg, y_beg, l, n) =
begingroup

% стрелочка вправо
numeric p; p := n / 2;

x_end := x_beg + l;
y_end := y_beg;  
xr := x_end - n;

%draw (x_beg, y_beg)--(x_end, y_end)--(xr, y_end-n)--(xr, y_end+n)--(x_end, y_end);

draw (x_beg, y_beg+p)--(x_beg, y_beg-p)--(xr, y_beg-p)--(xr, y_beg-n)--(x_end, y_end)--
     (xr, y_beg+n)--(xr, y_beg+p)--cycle;

endgroup;
enddef;
% ----------------------------------------------
def x_draw_axes (expr xc, yc,  x_size, x_label,
                               y_size, y_label,
                               z_size, z_label) =
begingroup

save stp, x;
numeric stp, x[], y[];


ox_x := xc+x_size; ox_y := yc;
oy_x := xc;        oy_y := yc+y_size;

stp  := z_size * 0.6;  % наклон оси OZ
oz_x := xc-stp;  oz_y := yc-stp;

drawarrow (xc, yc)--(ox_x, ox_y); label.llft (x_label, (ox_x-2u, ox_y));
drawarrow (xc, yc)--(oy_x, oy_y); label.lft (y_label, (oy_x, oy_y));
drawarrow (xc, yc)--(oz_x, oz_y); label.rt  (z_label, (oz_x+2u, oz_y));

label.urt (btex \small 0 etex, (xc, yc));

endgroup;
enddef;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 8 Единичный куб
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
beginfig(8) 

u := 0.27mm;  
W := 500u;  H := 250u;

path border; border = (0,0)--(W,0)--(W,H)--(0,H)--cycle;
fill border withcolor 1.0 white; 

Lx := -120;  Ly :=  0;
Rx := +120;  Ry :=  0;

% ----------------------------------------
picture img; img := image (

  x_draw_axes (Lx, Ly,
    70u, btex $\xi$ etex,
    70u, btex $\eta$ etex,
    70u, btex $\zeta$ etex);
  x_draw_cube_old (Lx, Ly, 50u); 

  x_rarrow (-40u,+20u, 100u,20u); 

  x_draw_cube_new (Rx, Ry, 50u); 

  x_draw_axes (0, -90u,  60u, "x", 60u, "y", 40u, "z");

);
% ----------------------------------------

draw img  shifted (W/2, H/2+20u);
%  cairo_translate (cr, W/2, H/2+20);

endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
end.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



















%------------------------------------------------
def make_pattern (expr W, H, st) =
begingroup;

nn := round (1u / st);
  
picture img; img := image (
  
for i=1 upto nn:
for j=1 upto nn:
  drawdot (i*st, j*st) withpen pencircle scaled 1;
endfor
endfor

);

ni := round (W / 1u);
nj := round (H / 1u);

for i=0 upto ni:
for j=0 upto nj:
  draw img  shifted (i*u, j*u);
endfor
endfor

endgroup;
enddef;
%------------------------------------------------
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 7  Графики
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
beginfig(7); 

u  := 1cm;
W  := 10.0u;  
H  :=  6.0u; 

path border; border = (0,0)--(W,0)--(W,H)--(0,H)--cycle;

path p;
p := fullcircle scaled 2u shifted (3u, 2u) ;
pickup pencircle scaled 3;

picture patt; patt := image (make_pattern (W, H, 0.2u));

fill border withcolor 0.7white; 

clip patt to p; draw patt;

draw p withcolor red ;

endfig;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
