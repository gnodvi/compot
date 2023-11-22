%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

verbatimtex \documentclass{article}
%<-- My T2A encoding
\usepackage[warn]{mathtext}
\usepackage[T2A]{fontenc}
\usepackage[koi8-r]{inputenc}
\usepackage[english,russian]{babel}
\begin{document}
etex;

%-------------------------------------------------------------------------------
% intro.mp (1-1)
%-------------------------------------------------------------------------------
%А теперь мы его завращали

beginfig(11) ;
  for alpha:=90 step -3 until 0:
    label(btex Linux Format etex
      scaled (5*(1-alpha/100)) rotated alpha,(0,0))
    withcolor (max(1-alpha/45,0)*red+
      min(alpha/45,2-alpha/45)*green+
      max(alpha/45-1,0)*blue);
  endfor;
endfig ;

%-------------------------------------------------------------------------------
% intro.mp (1-2)
%-------------------------------------------------------------------------------
%А теперь мы его завращали

beginfig(12) ;
  for alpha:=-90 step 3 until 0:
    label(btex LinuxFormat в России etex
      scaled (5*(1+alpha/100)) rotated alpha,(0,0))
    withcolor (max(1+alpha/45,0)*red+
      min(-alpha/45,2+alpha/45)*green+
      max(-alpha/45-1,0)*blue);
  endfor;
endfig ;

%-------------------------------------------------------------------------------
% intro.mp (1-3)
%-------------------------------------------------------------------------------
%Математика вместо Hello, World!

beginfig(13) ;
  for alpha:=90 step -9 until 0:
    label(btex \(f(x)=\frac{1}{\sqrt{2\pi}\,\sigma}
	      \int\limits_{-\infty}^{\infty}e^{-\frac{x^2}{2\sigma^2}}dx\) etex
      scaled (5*(1-alpha/100)) rotated alpha,(0,0))
    withcolor (max(1-alpha/45,0)*red+
      min(alpha/45,2-alpha/45)*green+
      max(alpha/45-1,0)*blue);
  endfor;
endfig ;

%-------------------------------------------------------------------------------
% intro.mp (1-4)
%-------------------------------------------------------------------------------
%MetaPost на Википедии 03.09.2006 10:02

beginfig(14) ;
  for alpha:=-90 step 3 until 0:
    label(btex MetaPost на Википедии etex
      scaled (5*(1+alpha/100)) rotated alpha,(0,0))
    withcolor (max(1+alpha/45,0)*red+
      min(-alpha/45,2+alpha/45)*green+
      max(-alpha/45-1,0)*blue);
  endfor;
endfig ;

%-------------------------------------------------------------------------------
% base.mp (2-4)
%-------------------------------------------------------------------------------
%Закон Ньютона - сложение сил

beginfig(24) ;
  numeric u;
  u = 1mm;
  drawarrow (0,0)--(20u,30u)  withpen pencircle scaled 0.3u ;
  label.ulft(btex \(\vec{F}_1\) etex,1/2[(0,0),(20u,30u)]);
  drawarrow (20u,30u)--(40u,30u)  withpen pencircle scaled 0.3u ;
  label.top(btex \(\vec{F}_2\) etex,1/2[(20u,30u),(40u,30u)]);
  drawarrow (40u,30u)--(50u,10u)  withpen pencircle scaled 0.3u ;
  label.urt(btex \(\vec{F}_3\) etex,1/2[(40u,30u),(50u,10u)]);
  drawarrow (50u,10u)--(35u,15u)  withpen pencircle scaled 0.3u ;
  label.llft(btex \(\vec{F}_4\) etex,1/2[(50u,10u),(35u,15u)]);
  drawarrow (0u,0u)--(35u,15u)  withpen pencircle scaled 0.8u ;
  drawarrow (0u,0u)--(35u,15u)  withpen pencircle scaled 0.3u withcolor white;
  draw (0u,0u)  withpen pencircle scaled 2u ;
  label.bot(btex \(\vec{F}_1+\vec{F}_2+\vec{F}_3+\vec{F}_4\) etex,
    1/2[(35u,15u),(0u,0u)]) rotatedaround (1/2[(35u,15u),(0u,0u)],angle(35,15));
endfig ;

%-------------------------------------------------------------------------------
% base.mp (2-7)
%-------------------------------------------------------------------------------
%пример fill
%Рис к 1.6.20 а) струя под углом, разбивающаяся на две, о пол

beginfig(27) ;
  numeric u;
  u = 1mm;
  numeric st;st:=u/(sqrt 3);
  path p;
  p:=(0,10u)--(18u,10u){dir 0}..{dir 30}(22u,10u+2st)--(50u,10u+30st){dir -90}..
{dir -90}(60u,5u+20st)--(42u,5u+2st){dir -150}..{dir 0}(42u,5u)--(60u,5u){dir -120}..
{dir -120}(60u,0u)--(0u,0u){dir 60}..{dir 60}cycle;
  fill p  withcolor 0.8 white;
  draw ((40u,5u)+10u*dir 30){dir -60}..{dir -90}(50u,5u);
  label(btex \(\alpha\) etex,(53u,8u));
  draw (0u,0)--(60u,0u) withpen pencircle scaled 0.8u;
  numeric R,alpha;R:=12u;alpha=30;
  drawarrow (25u+25u,5u+25st)--((25u+25u,5u+25st)-R*dir alpha)
  withpen pencircle scaled 0.6u ;
  label.ulft(btex \(\vec{v}\) etex,1/2[(25u+25u,5u+25st),
    ((25u+25u,5u+25st)-R*dir alpha)]);
  drawarrow (20u,5u)--(20u-R,5u) withpen pencircle scaled 0.6u ;
  label.top(btex \(\vec{v}\) etex,(20u-R/2,5u));
  drawarrow (45u,2.5u)--(45u+R,2.5u) withpen pencircle scaled 0.6u ;
  label.lft(btex \(\vec{v}\) etex,(45u,2.5u));
endfig ;

%-------------------------------------------------------------------------------
% base.mp (2-8)
%-------------------------------------------------------------------------------
%рисует кусок спектра c - текущий цвет, ic=\pm1,\pm2,\pm3
%меняем соотвествующую компоненту, l - высота линии, w- сдвижка от 0
%dw - ширина линии

def spectrline(expr ic,c,l,w,dw) =
  begingroup
    save i,ifirst,ilast,istep,icc;
    color icc;
    if (ic>0):istep:=1;ifirst:=0;ilast=255;
    else:istep:=-1;ifirst=0;ilast:=-255; fi;
    if (abs(ic)=1):icc:=red;fi;
    if (abs(ic)=2):icc:=green;fi;
    if (abs(ic)=3):icc:=blue;fi;
    for i:=ifirst step istep until ilast:
      draw ((0u,0u)--(0u,l)) shifted (w+(dw/2*abs(i),0))
      withpen pencircle scaled dw withcolor (c+i/255*icc);
    endfor;
  endgroup;
enddef;

%спектр
beginfig(28) ;
  color current;
  u:=1mm;w:=200u;dw:=w/512;l:=5u;
  current:=(1,0,0);
  spectrline(2,current,l,(1/4w,0u),dw)
  current:=(1,1,0);
  spectrline(-1,current,l,(1/2w,0u),dw)
  current:=(0,1,0);
  spectrline(3,current,l,(3/4w,0u),dw)
  current:=(0,1,1);
  spectrline(-2,current,l,(w,0u),dw)
endfig ;
%-------------------------------------------------------------------------------



%-------------------------------------------------------------------------------
end.
%-------------------------------------------------------------------------------
