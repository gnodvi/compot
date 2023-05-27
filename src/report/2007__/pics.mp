%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

verbatimtex \documentclass{article}
%<-- My T2A encoding
\usepackage[warn]{mathtext}
\usepackage[T2A]{fontenc}
\usepackage[koi8-r]{inputenc}
\usepackage[english,russian]{babel}
\begin{document}
etex;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2  LineSegments
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

u := 25;                % 25 = 25bp = 25 PostScript points = 25/72 in

wi := 10;               % width  in units u
he := 7;                % height in units u
hoehe  := he*u;         % height
breite := wi*u;         % width

beginfig (02)

% %%%%%%%%%%%%%%%% Grid %%%%%%%
for i=0 upto he:
  draw (0, i*u)--(breite, i*u) withcolor .7white;
endfor
for j=0 upto wi:
  draw (j*u, 0)--(j*u, hoehe) withcolor .7white;
endfor

draw (0, 0)--(breite, 0)--(breite, hoehe)--(0, hoehe)--cycle;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

draw (.7u, 4u)--(5u, 6.5u) withcolor red;           % Line Segment 
drawarrow (6.4u, 6u)--(9.5u, 4.8u) withcolor blue;  % Arrow 

pickup pencircle scaled 2; % default:
                           % 0.5 (= 0.5bp = 0.5 PostScript Points)

draw (u, 5u)--(0, 4u)--(u, 3u)--(2u, 4u)--(3u, 3u)--(u,u)--(2u, 0)--(3u, u); % Polyline
drawarrow (5u, 5u)--(4u, 3u)--(5u, 4u)--(4u, 2u)--(6u, 3u)--(5u, u); % Polyarrow 

% Polygon %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fill (7.7u, .3u)--(9.6u, 1.5u)--(9.3u, 3.6u)--(7.2u, 3.8u)
     --(6.4u, 2.5u)--(7.3u, 1.9u)--cycle withcolor .9white;

pickup pencircle scaled .5;

draw (7.7u, .3u)--(9.6u, 1.5u)--(9.3u, 3.6u)--(7.2u, 3.8u)
--(6.4u, 2.5u)--(7.3u, 1.9u)--cycle;

endfig; 

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 3  Circles
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

u  := 25;           % 25 = 25bp = 25 PostScript points = 30/72 in

wi := 10;           % width in units u
he :=  7;           % height in units u
hoehe  := he*u;     % height
breite := wi*u;     % width

beginfig(03)

% %%%%%%%%%%%%%%%% Grid %%%%%%%
for i=0 upto he:
  draw (0, i*u)--(breite, i*u) withcolor .7white;
endfor
for j=0 upto wi:
  draw (j*u, 0)--(j*u, hoehe) withcolor .7white;
endfor

draw (0, 0)--(breite, 0)--(breite, hoehe)--(0, hoehe)--cycle;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% %%%
%%% fullcircle %%%
%%% halfcircle %%%
%%% %%%

draw fullcircle scaled 3u shifted (5u, 5.2u);

draw fullcircle xscaled 3u yscaled 1.2u shifted (5u, 2.2u);
draw fullcircle xscaled 1.2u yscaled 3u shifted (8u, 5.2u);
fill fullcircle xscaled 3u yscaled 1.2u rotated 45 shifted (8u, 2.2u) withcolor .9white;
draw fullcircle xscaled 3u yscaled 1.2u rotated 45 shifted (8u, 2.2u);

draw halfcircle scaled 2u shifted (1.5u, 5u);
pickup pencircle scaled 1.5;
draw halfcircle scaled 2u rotated  90 shifted (1.5u, 4u) withcolor red;
draw halfcircle scaled 2u rotated -90 shifted (1.5u, 3u) withcolor blue;

endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 4  CircleParametrization
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

u  := 25;             % 25 = 25bp = 25 PostScript points = 25/72 in
wi := 10;             % width in units u
he :=  7;             % height in units u
hoehe  := he*u;       % height
breite := wi*u;       % width

path p[];

p0 := fullcircle scaled 3u shifted (2.3u, hoehe-2.1u);
p1 := fullcircle xscaled 3u yscaled u rotated 225 shifted (2.3u, 1.6u);
p2 := fullcircle xscaled 4u yscaled 2u shifted (7.25u, hoehe/2);
p3 := fullcircle xscaled 5u yscaled 6.5u shifted (7.25u, hoehe/2);

def draw_point(expr P, colInt, colPer) =
fill fullcircle scaled 1.5mm shifted P withcolor colInt;
draw fullcircle scaled 1.5mm shifted P withcolor colPer;
enddef;

beginfig(04)

% --- Draw frame ---
draw (0, 0)--(breite, 0)--(breite, hoehe)--(0, hoehe)--cycle;

draw p0; % Draw p0

pickup pencircle scaled 1.5;
draw subpath (0, 4) of p0 withcolor red;
pickup pencircle scaled 0.5;

for t=0 upto 7:
z[t]=point t of p0;
draw_point(z[t], white, red);
if (t<2) or (t=7):
label.rt("t = "&decimal t, z[t]);
elseif t=2:
label.top("point "&decimal t&" of p0", z[t]);
elseif (t=3) or (t=5):
label.lft("t = "&decimal t, z[t]);
elseif t=4:
label.lft(decimal t, z[t]);
else:
label.ulft(decimal t, z[t]);
fi
endfor

label("p0", center p0 + (0, .25u));
label("length(p0)="&decimal length(p0), center p0 - (0, .25u));

draw p1; % Draw p1

pickup pencircle scaled 1.5;
draw subpath (0, 4) of p1 withcolor red;
pickup pencircle scaled 0.5;

for t=0 upto 7:
z[10+t]=point t of p1;
draw_point(z[10+t], white, red);
if t=0:
label.llft("t = "&decimal t, z[10+t]);
elseif t=1:
label.lrt("t = "&decimal t&" - point "&decimal t&" of p1", z[10+t]);
elseif t<4:
label.lrt ("t = "&decimal t, z[10+t]);
elseif t=4:
label.urt ("t = "&decimal t, z[10+t]);
else:
label.ulft("t = "&decimal t, z[10+t]);
fi
endfor

label("p1", center p1);

draw p2; % Draw p2

pickup pencircle scaled 1.5;
draw subpath (0, 4) of p2 withcolor red;
pickup pencircle scaled 0.5;
label("subpath (0, 4) of p2", center p2 + (0, .25u));
label("subpath (4, 8) of p2", center p2 - (0, .25u));
draw p3 dashed evenly; % Draw p3
label.llft("p3", point 1.4 of p3);

for t=0 upto 7: % Draw blue arrows
  p99:=(point t of p3)--center p3;
  pickup pencircle scaled 1.5;
  if t<4:
    drawarrow p99 cutafter subpath (0, 4) of p2 withcolor blue;
  else:
    drawarrow p99 cutafter subpath (4, 8) of p2 withcolor blue;
  fi
endfor

endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 6 GraphSqrt
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

u  := 50;    % 50 = 50bp = 50 PostScript points = 50/72 in
wi :=  5;    % width in units u
he :=  4;       % height in units u
hoehe  := he*u; % height
breite := wi*u; % width

beginfig(6)

% --- Grid ---

for i=0 upto he:
  draw (0, i*u)--(breite, i*u) withcolor .7white;
endfor
for j=0 upto wi:
  draw (j*u, 0)--(j*u, hoehe) withcolor .7white;
endfor

% --- End Grid ---

draw (0, 0)--(breite, 0)--(breite, hoehe)--(0, hoehe)--cycle;
z1 = (0, sqrt 0);
z2 = (1, sqrt 1);
z3 = (2, sqrt 2);
z4 = (3, sqrt 3);

drawarrow ((0,0)--(3.5, 0)) scaled u shifted (u, u); % x-Achse
drawarrow ((0,0)--(0,2.5)) scaled u shifted (u, u); % y-Achse

pickup pencircle scaled 4;

draw (z1..z2..z3..z4) scaled u shifted (u, u) withcolor 0.8white;
pickup pencircle scaled 8;

for i=1 upto 4:
draw z[i] scaled u shifted (u,u) withcolor .8white;
endfor

pickup pencircle scaled 2;
draw (z1{up}..z2..z3..z4) scaled u shifted (u, u);

endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 9  TeXLabels
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

verbatimtex
\font\cyr=wncyr10
etex

u:=50; % 50 = 50bp = 50 PostScript points = 50/72 in
wi:=5; % width in units u
he:=3.5; % height in units u
hoehe:=he*u; % height
breite:=wi*u; % width

path p, q[];
transform t;
picture lab[];

beginfig(09)

z0=.5(u,u);
t:=identity scaled u shifted z0;

z1=(3.5, 0) transformed t;
z2=(0, 2.5) transformed t;

p:=(.5, 2) for i=2 upto 6: ..(.5i, 1/(.5i)) endfor ;
p:=p transformed t;

q0:=((1, -0.5)--(1, 2.5)) transformed t;
q1:=((2.8, -0.5)--(2.8, 2.5)) transformed t;

q2:=buildcycle(z0--z1, q1, p, q0);

lab0:=thelabel(btex $A$ etex, center q2 shifted (0, -u/4));
lab1:=thelabel(btex $\displaystyle A=\int_1^a {dx\over x}=\ln a$ etex,
(2, 1.5) transformed t);

% frame
draw (0, 0)--(breite, 0)--(breite, hoehe)--(0, hoehe)--cycle;

fill q2 withcolor .9white;

% --- Grid ---
for i=0 upto 2:
draw ((0, i)--(3, i)) transformed t withcolor .7white;
endfor
for j=0 upto 3:

draw ((j, 0)--(j, 2)) transformed t withcolor .7white;
endfor
% --- End Grid ---

drawarrow z0--z1; % x-Achse
drawarrow z0--z2; % y-Achse

draw q0 cutbefore (z0--z1) cutafter p;
draw q1 cutbefore (z0--z1) cutafter p;

pickup pencircle scaled 2;
draw p;

% ============================== labels ====================================

label.rt(btex $x$ etex, z1);
label.top(btex $y$ etex, z2);

label.bot(btex $1$ etex, (z0--z1) intersectionpoint q0);
label.bot(btex $a$ etex, (z0--z1) intersectionpoint q1);

label.top(btex $\displaystyle y={1\over x}$ etex, (.5, 2) transformed t);

unfill bbox lab0; draw lab0;
unfill bbox lab1; draw lab1;

label.lft(btex Logarithm and area etex, (3.7, 2.6) transformed t);
label.lft(btex
\cyr logarifm i plowad\char126
etex scaled 1.1, (3.7, 2.4) transformed t);

label.ulft(btex Urs Oswald etex rotated 90, (breite, 0));
label.llft(btex 06.09.2002 etex rotated -90, (breite, hoehe));

% ============================== labels ====================================

endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 14 Directions
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

u      := 40mm/68;
breite := 150u;
hoehe  := 110u;

path p;

beginfig(14)

z0=(.5breite, .3hoehe);

z1  = (7,28)*u;
z2  = (51,98)*u;
z3  = (55,100)*u;
z4  = (54,93)*u;
z5  = (22,24)*u;
z6  = (25,12)*u;
z7  = (36,18)*u;
z8  = (89,94)*u;
z9  = (87,95)*u;
z10 = (49,20)*u;
z11 = (59,11)*u;
z12 = (87,23)*u;

p := z1{2,5}..
     z2{10,9}..
     z3{right}..tension 1.3..
     z4{-4,-9}..tension 1.1..
     z5{-17,-62}..
     z6{right}..
     z7..tension 1.8..
     z8{27,58}..
     z9{-55,-52}..tension 2..
     z10{down}..
     z11{right}..
     z12{50,31};

draw (0,0)--(breite,0)--(breite,hoehe)--(0,hoehe)--cycle;

draw p;                                 % original curve
for i=1 upto 12:                        % labels 1 to 12
  if (i=2) or (i=3) or (i=9) or (i=12):
    label.top(decimal(i), z[i]);
  elseif (i=4) or (i=8):
    label.rt(decimal(i), z[i]);
  elseif (i=6) or (i=11):
    label.bot(decimal(i), z[i]);
  elseif (i=7):
    label.ulft(decimal(i), z[i]);
  else:
    label.lft(decimal(i), z[i]);
  fi
endfor

pickup pencircle scaled 4;    % dot labels
for i=1 upto 12:
  draw z[i];
endfor

% transform original curve
pickup pencircle scaled .5;

draw p rotated 0 shifted (.5breite, 0) scaled 1/16 shifted z0;
pickup pencircle scaled 1;
draw p rotated 10 shifted (.5breite, 0) scaled 1/8 shifted z0;
pickup pencircle scaled 1.5;
draw p rotated 20 shifted (.5breite, 0) scaled 1/4 shifted z0;
pickup pencircle scaled 2;
draw p rotated 30 shifted (.5breite, 0) scaled 1/2 shifted z0;

endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 16 Colors
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

u:=25; % 25 = 25bp = 25 PostScript points = 25/72 in
wi:=10; % width in units u
he:=10; % height in units u
hoehe:=he*u; % height
breite:=wi*u; % width
pair P[], xy[];
path p[]; transform t; color c[];
n:=20; rd:=0.2; b:=(wi-2rd)/4;
P0:=(0, 0);
t:=identity scaled u shifted P0;

beginfig(16)

fill (0, 0)--(breite, 0)--(breite, hoehe)--(0, hoehe)--cycle withcolor .9white;
draw (0, 0)--(breite, 0)--(breite, hoehe)--(0, hoehe)--cycle;
for k=0 upto 3:
blau:=.3333k;
P1:=(rd, he-rd-b)+k*b*(1, -1);
for i=0 upto n-1:
for j=0 upto n-1:
xy0:=P1+(i*b/n, j*b/n);
p0:=xy0--(xy0+(b/n, 0))--(xy0+(b/n, b/n))--(xy0+(0, b/n))--cycle;
c0:=((i+1)/n, (j+1)/n, blau);
fill p0 transformed t withcolor c0;
endfor
endfor
draw (P1--(P1+(b, 0))--(P1+(b, b))--(P1+(0,b))--cycle) transformed t;
P2:=(P1+(0, b))transformed t;
label.lrt("bluepart c", P2);
label.lrt("="&decimal blau, P2+(0, -3mm));
label.urt("latex2html version 2002 - 1", (0,0));
endfor
endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 23 ForSuffixes
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

u:=25; % 25 = 25bp = 25 PostScript points = 30/72 in
wi:=10; % width in units u
he:=9; % height in units u
hoehe:=he*u; % height
breite:=wi*u; % width
transform t, Txy;
pair P[];
path p[];
color wuerfel[], versch; % 3D vectors: MetaPost type ''color''

rotX:=45; % angle of rotation around the x axis
rotY:=45; % angle of rotation around the y axis
rotZ:=45; % angle of rotation around the z axis

versch:=(1.6, 1, 2.7); % translation (in mathematical units)
P0=(3.2, 2.2)*u; % origin in MetaPost coordinates (bp)
P1=(-.6, -.4)/1.5; % x axis in mathematical coordinates
t:=identity % t: maps mathematical 2D coordinates
scaled u % onto MetaPost coordinates (bp)
shifted P0;
Txy:=identity % Txy: maps 3D coordinates x,y onto
reflectedabout((0,0), (1,1)) % MetaPost coordinates
yscaled ypart P1
slanted (xpart P1/ypart P1)
transformed t;

vardef dreheX(expr SpaceVector, winkel) = % rotation of 3D vector
pair yz; % ''SpaceVector'' around
yz:=(greenpart SpaceVector, bluepart SpaceVector); % the x axis by the
yz:=yz rotated winkel; % angle ''winkel''
(redpart SpaceVector, xpart yz, ypart yz)
enddef;

vardef dreheY(expr SpaceVector, winkel) = % rotation around the y axis
pair zx;
zx:=(bluepart SpaceVector, redpart SpaceVector);

zx:=zx rotated winkel;
(ypart zx, greenpart SpaceVector, xpart zx)
enddef;

vardef dreheZ(expr SpaceVector, winkel) = % rotation around the z axis
pair xy;
xy:=(redpart SpaceVector, greenpart SpaceVector);
xy:=xy rotated winkel;
(xpart xy, ypart xy, bluepart SpaceVector)
enddef;

vardef getPixel(expr SpaceVector) = % returns MetaPost coordinates (bp)
% SpaceVector: type ''color'' % of spatial projection of
(redpart SpaceVector, greenpart SpaceVector) % 3D point
transformed Txy % with coordinates ''SpaceVector''
shifted (0, u*bluepart SpaceVector)
enddef;

vardef Zyklus(text t) = % returns cyclic path formed of the
forsuffixes $=t: z$-- endfor % z points with suffixes in argument t
cycle
enddef;
%
% The following construction copies the possibilities one has in Java with
%
% main(String[] args) {
% k = args.length;
%
vardef Pfad(text t) = % returns path formed of the
k:=0; % z points with suffixes in argument t
forsuffixes $=t: k:=k+1; endfor % count number of arguments first
i:=1;
forsuffixes $=t: % problem: the last z must not be followed by --
if i<k: z$-- else: z$ fi
hide(i:=i+1) % hide: to prevent ''i:=i+1'' to be written into the path
endfor % no ; after '')'' (would be written into path)
enddef;

def lot(expr n) = % draws perpendicular line from point wuerfel[n]
color SpaceVector; % to (x,y) plane
SpaceVector:=wuerfel[n];
draw getPixel(SpaceVector)--getPixel((redpart SpaceVector,greenpart SpaceVector, 0));
draw_point(getPixel(SpaceVector), white, black);
draw_point( getPixel((redpart SpaceVector,greenpart SpaceVector, 0)), white, black);
enddef;

def draw_point(expr P, colInt, colPer) =
fill fullcircle scaled 1mm shifted P withcolor colInt;
draw fullcircle scaled 1mm shifted P withcolor colPer;
enddef;

def Lote(text t) = % invokes lot(n) for all the suffixes in
forsuffixes $=t: % argument t
lot($);
endfor
enddef;

wuerfel0:=(2.8, 0, 0); % definition of cube ''wuerfel''
wuerfel1:=(2.8, 2.8, 0); % (array of type color)

wuerfel2:=(0, 2.8, 0); % in mathematical 3D coordinates
wuerfel3:=(0, 0, 0);
wuerfel4:=(2.8, 0, 2.8);
wuerfel5:=(2.8, 2.8, 2.8);
wuerfel6:=(0, 2.8, 2.8);
wuerfel7:=(0, 0, 2.8);

beginfig(23)

for i=0 upto 7: % z0,...,z7: MetaPost coordinates of
z[i]=getPixel(wuerfel[i]); % cube in original position
endfor

for i=0 upto 7: % rotation and translation
wuerfel[i]:=dreheX(wuerfel[i], rotX); % of cube
wuerfel[i]:=dreheY(wuerfel[i], rotY);
wuerfel[i]:=dreheZ(wuerfel[i], rotZ);
wuerfel[i]:=wuerfel[i]+versch;
endfor

for i=0 upto 7: % z100,...,z107: MetaPost coordinates of
z[i+100]=getPixel(wuerfel[i]); % cube after rotation
endfor

% --- Grid ---

for i=0 upto 5:
draw getPixel((i,0,0))--getPixel((i,5,0)) withcolor .7white;
draw getPixel((0,i,0))--getPixel((5,i,0)) withcolor .7white;
draw getPixel((0,i,0))--getPixel((0,i,5)) withcolor .7white;
draw getPixel((0,0,i))--getPixel((0,5,i)) withcolor .7white;
draw getPixel((0,0,i))--getPixel((5,0,i)) withcolor .7white;
draw getPixel((i,0,0))--getPixel((i,0,5)) withcolor .7white;
endfor

% --- End Grid ---
% --- Frame ---

draw (0, 0)--(breite, 0)--(breite, hoehe)--(0, hoehe)--cycle;

% --- Axes ---

drawarrow getPixel((0, 0, 0))--getPixel((6, 0, 0));
label.llft(btex $x$ etex, getPixel((6, 0, 0))+(0, 1mm));
drawarrow getPixel((0, 0, 0))--getPixel((0, 6, 0));
label.rt (btex $y$ etex, getPixel((0, 6, 0)));
drawarrow getPixel((0, 0, 0))--getPixel((0, 0, 6));
label.top (btex $z$ etex, getPixel((0, 0, 6)));

% --- Cube in original position ---

fill Zyklus(0, 1, 5, 4) withcolor .7green;
fill Zyklus(4, 5, 6, 7) withcolor .9green;
fill Zyklus(1, 2, 6, 5) withcolor .5green;
draw Pfad(0, 3, 2) dashed evenly;
draw Pfad(3, 7) dashed evenly;
draw Zyklus(1, 2, 6, 7, 4, 0) ;
draw Pfad(4, 5, 1, 5, 6);

% --- Cube after rotation ---

fill Zyklus(104, 105, 106, 107) withcolor .9red;
fill Zyklus(101, 102, 106, 105) withcolor .7red;
fill Zyklus(100, 101, 105, 104) withcolor .5red;
draw Pfad(100, 103, 102) dashed evenly;

draw Pfad(103, 107) dashed evenly;
draw Pfad(104, 105, 101, 105, 106);
draw Zyklus(101, 102, 106, 107, 104, 100);
Lote(0, 1, 4, 5, 7); % suffixes of ''wuerfel''

endfig;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
end.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
