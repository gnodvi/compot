%%
%% This file was created from report.cls
%% ����� ��� ��������� ������ FFFFFF
%%
%% ��������� ����������� (���������� �.�., 20.01.2002):
%%   ��������� ������ ����� a4paper, ��������� ������.
%%   ������ ����� 10pt, 11pt. ��������� 12pt (�� ���������) � ������� 14pt
%%   ���������� ������� \mbnumber ��� ������� ������ �� � ������
%%     �����������
%%   �� ��������� pagestyle{myheadings} ��� ��������� ������ �������� �
%%     � ������� ����������� �� ������ � ����� �� � ������ �����������
%%     �����
%%   ��� ���������� ����� ������ pagestyle{mbheadings} ������� ��������
%%     ����� �� �� �� �������� ����� ��������
%%   ��������� �������� (chapter � section) �� ������, ������ normalsize,
%      \@afterindenttrue, ��� subsection ����� ������ ������ \parindent
%%   ���������� ������� \intro � \concl ��� �������� � ����������
%%   � caption ������ : ������� .
%%   ��������� ���������� �������� normalsize � ������� ������ ������
%%     ��������� ������ � �������� �� ������ ������
%%   ���������� ������� \maketitlepagenum{} ��� ������� ������ ��������
%%     � ��������� ���� (������������, ���� ������ ������� �� ���������
%%     ��������). ���� ������� \maketitlepagenum{} �� ������������, ��
%%     ����� �������� ����� ���������� ����� ����� 2.
%%   ���������� ����� chapt ��� ��������� ��������, ����������, ������
%%     ����������, ���������� ��� chapter (�� ��������� section)
%%   �������������� ���������� ����� �������� � ������ ������� ������:
%%     \renewcommand{\baselinestretch}{1.25}
%%     \parindent12.5mm
%%   ���������� ������� \tabletitle ��� ������� �������� ������� ���
%%     ��� ������� �� FFFFF: ����� ������� 1.1 ������� ������, � �����
%%     ������ ���������. ������� �������� ����� \begin{table} � �����
%%     \caption
%% ----------------------------------------------------------------------------
  
\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{mbreport}
              [2002/01/20 v1.0b
 LaTeX document class for VNIITF mburo]
\newcommand\@ptsize{}
\newif\if@restonecol
\newif\if@titlepage
\@titlepagetrue

\newif\if@isapp  % ��� ���������� ���������� ?!
\@isappfalse     % ���� ���

\newif\if@openright
\if@compatibility\else
\DeclareOption{a4paper}
   {\setlength\paperheight {297mm}%
    \setlength\paperwidth  {210mm}}
\fi
\if@compatibility
  \renewcommand\@ptsize{0}
\else
  \DeclareOption{12pt}{\renewcommand\@ptsize{2}}
\fi
\DeclareOption{14pt}{\renewcommand\@ptsize{4}}
\DeclareOption{13pt}{\renewcommand\@ptsize{3}}
\if@compatibility\else
\DeclareOption{oneside}{\@twosidefalse \@mparswitchfalse}
\fi
\DeclareOption{twoside}{\@twosidetrue  \@mparswitchtrue}
\DeclareOption{draft}{\setlength\overfullrule{5pt}}
\if@compatibility\else
\DeclareOption{final}{\setlength\overfullrule{0pt}}
\fi
\DeclareOption{titlepage}{\@titlepagetrue}
\if@compatibility\else
\DeclareOption{notitlepage}{\@titlepagefalse}
\fi
\if@compatibility
\else
\DeclareOption{openright}{\@openrighttrue}
\DeclareOption{openany}{\@openrightfalse}
\fi
\if@compatibility\else
\DeclareOption{onecolumn}{\@twocolumnfalse}
\fi
\DeclareOption{twocolumn}{\@twocolumntrue}
\DeclareOption{leqno}{\input{leqno.clo}}
\DeclareOption{fleqn}{\input{fleqn.clo}}
\DeclareOption{openbib}{%
  \AtEndOfPackage{%
   \renewcommand\@openbib@code{%
      \advance\leftmargin\bibindent
      \itemindent -\bibindent
      \listparindent \itemindent
      \parsep \z@
      }%
   \renewcommand\newblock{\par}}%
}
%%% ��� ������� ��������, ���������� � ������ ���������� ��� chapter
\newif\if@aschapter
\@aschapterfalse
\DeclareOption{chapt}{\@aschaptertrue}
%%%
\ExecuteOptions{a4paper,12pt,oneside,onecolumn,final,openany}
\ProcessOptions
%%% ��� ������� ������ ��
\newcommand\@mbnumber{\hfil}
\newcommand\@mbnumberforlastpage{}
\def\mbnumber#1{\renewcommand\@mbnumber{\CYRM\CYRB~\No~ #1 \hfil}
\renewcommand\@mbnumberforlastpage{\CYRM\CYRB~\No~ #1 \hfil}}
%%%
%%% ��� ������� ������ �������� �� ��������� ����
\newif\if@titlepgnum
\@titlepgnumfalse
\newcommand\@titlepnum{}
\def\maketitlepagenum#1{
  \setcounter{page}#1
  \@titlepgnumtrue
  %\renewcommand\@titlepnum{\thepage}
  \renewcommand\@titlepnum{\makebox[0.5\textwidth]{\thepage\hfill}}
  \def\@oddfoot{\@mbnumber\makebox[0.5\textwidth]{\thepage\hfill}}
  \def\@evenfoot{\@mbnumber\makebox[0.5\textwidth]{\thepage\hfill}}
  }
%%% ----------------------------------------------------------------------------
%%% ��� ��������� ��������� � ������� ��� ������� �� FFFFF
\newif\if@tabletitle
\@tabletitlefalse
\def\tabletitle{
\@tabletitletrue
}
%%% ----------------------------------------------------------------------------
%%% ��� ������� ��������
\newcommand{\intro}{
\if@aschapter
  \chapter*{\CYRV\cyrv\cyre\cyrd\cyre\cyrn\cyri\cyre}
  \addcontentsline{toc}{chapter}{\CYRV\cyrv\cyre\cyrd\cyre\cyrn\cyri\cyre}
\else
  \section*{\CYRV\cyrv\cyre\cyrd\cyre\cyrn\cyri\cyre}
  \addcontentsline{toc}{section}{\CYRV\cyrv\cyre\cyrd\cyre\cyrn\cyri\cyre}
\fi
}
%%% ----------------------------------------------------------------------------
%%% ��� ������� ����������
\newcommand{\concl}{
\if@aschapter
  \chapter*{\CYRZ\cyra\cyrk\cyrl\cyryu\cyrch\cyre\cyrn\cyri\cyre}
  \addcontentsline{toc}{chapter}{\CYRZ\cyra\cyrk\cyrl\cyryu\cyrch\cyre\cyrn\cyri\cyre}
\else
  \section*{\CYRZ\cyra\cyrk\cyrl\cyryu\cyrch\cyre\cyrn\cyri\cyre}
  \addcontentsline{toc}{section}{\CYRZ\cyra\cyrk\cyrl\cyryu\cyrch\cyre\cyrn\cyri\cyre}
\fi
}
%%% ----------------------------------------------------------------------------
\input{size1\@ptsize.clo}
\setlength\lineskip{1\p@}
\setlength\normallineskip{1\p@}
\renewcommand\baselinestretch{}
\setlength\parskip{0\p@ \@plus \p@}
\@lowpenalty   51
\@medpenalty  151
\@highpenalty 301
\setcounter{topnumber}{2}
\renewcommand\topfraction{.7}
\setcounter{bottomnumber}{1}
\renewcommand\bottomfraction{.3}
\setcounter{totalnumber}{3}
\renewcommand\textfraction{.2}
\renewcommand\floatpagefraction{.5}
\setcounter{dbltopnumber}{2}
\renewcommand\dbltopfraction{.7}
\renewcommand\dblfloatpagefraction{.5}
\if@twoside
  \def\ps@headings{%
      \let\@oddfoot\@empty\let\@evenfoot\@empty
      \def\@evenhead{\thepage\hfil\slshape\leftmark}%
      \def\@oddhead{{\slshape\rightmark}\hfil\thepage}%
      \let\@mkboth\markboth
    \def\chaptermark##1{%
      \markboth {\MakeUppercase{%
        \ifnum \c@secnumdepth >\m@ne
            \@chapapp\ \thechapter \ %
% #### s4145            \@chapapp\ \thechapter. \ %
        \fi
        ##1}}{}}%
    \def\sectionmark##1{%
      \markright {\MakeUppercase{%
        \ifnum \c@secnumdepth >\z@
          \thesection \ %
% #### s4145          \thesection. \ %
        \fi
        ##1}}}}
\else
  \def\ps@headings{%
    \let\@oddfoot\@empty
    \def\@oddhead{{\slshape\rightmark}\hfil\thepage}%
    \let\@mkboth\markboth
    \def\chaptermark##1{%
      \markright {\MakeUppercase{%
        \ifnum \c@secnumdepth >\m@ne
            \@chapapp\ \thechapter \ %
% #### s4145            \@chapapp\ \thechapter. \ %
        \fi
        ##1}}}}
\fi
\def\ps@mbheadings{%
  \def\@oddfoot{\@mbnumber\hfil\@titlepnum}
%  \def\@oddfoot{\hfill\@titlepnum}
    \def\@evenhead{}
    \def\@oddhead{}
    % #### s4145 \def\@evenhead{\hfil\@titlepnum\hfil}%
    % #### s4145 \def\@oddhead{\hfil\@titlepnum\hfil} %
    }
\def\ps@myheadings{%
  % #### s4145 pagenumber
    \def\@oddfoot{\@mbnumber\makebox[0.5\textwidth]{\thepage\hfill}}
    \def\@evenfoot{\@mbnumber\makebox[0.5\textwidth]{\thepage\hfill}}
    %\def\@oddfoot{\@mbnumber}
    %\def\@evenfoot{\@mbnumber}
    %\def\@evenhead{\hfil\thepage\hfil}%
    %\def\@oddhead{\hfil\thepage\hfil} %
    \let\@mkboth\@gobbletwo
    \let\chaptermark\@gobble
    \let\subsectionmark\@gobble
    }
  \if@titlepage
  \newcommand\maketitle{\begin{titlepage}%
  \let\footnotesize\small
  \let\footnoterule\relax
  \let \footnote \thanks
  \null\vfil
  \vskip 60\p@
  \begin{center}%
    {\LARGE \@title \par}%
    \vskip 3em%
    {\large
     \lineskip .75em%
      \begin{tabular}[t]{c}%
        \@author
      \end{tabular}\par}%
      \vskip 1.5em%
    {\large \@date \par}%       % Set date in \large size.
  \end{center}\par
  \@thanks
  \vfil\null
  \end{titlepage}%
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}
\else
\newcommand\maketitle{\par
  \begingroup
    \renewcommand\thefootnote{\@fnsymbol\c@footnote}%
    \def\@makefnmark{\rlap{\@textsuperscript{\normalfont\@thefnmark}}}%
    \long\def\@makefntext##1{\parindent 1em\noindent
            \hb@xt@1.8em{%
                \hss\@textsuperscript{\normalfont\@thefnmark}}##1}%
    \if@twocolumn
      \ifnum \col@number=\@ne
        \@maketitle
      \else
        \twocolumn[\@maketitle]%
      \fi
    \else
      \newpage
      \global\@topnum\z@   % Prevents figures from going at top of page.
      \@maketitle
    \fi
    \thispagestyle{mbheadings}\@thanks
  \endgroup
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}
\def\@maketitle{%
  \newpage
  \null
  \vskip 2em%
  \begin{center}%
  \let \footnote \thanks
    {\LARGE \@title \par}%
    \vskip 1.5em%
    {\large
      \lineskip .5em%
      \begin{tabular}[t]{c}%
        \@author
      \end{tabular}\par}%
    \vskip 1em%
    {\large \@date}%
  \end{center}%
  \par
  \vskip 1.5em}
\fi
\newcommand*\chaptermark[1]{}
\setcounter{secnumdepth}{2}
\newcounter {part}
\newcounter {chapter}
\newcounter {section}[chapter]
\newcounter {subsection}[section]
\newcounter {subsubsection}[subsection]
\newcounter {paragraph}[subsubsection]
\newcounter {subparagraph}[paragraph]
\renewcommand \thepart {\@Roman\c@part}
\renewcommand \thechapter {\@arabic\c@chapter}
%\renewcommand \thesection {\thechapter \@arabic\c@section}
%\renewcommand\thesubsection   {\thesection \@arabic\c@subsection}
%\renewcommand\thesubsubsection{\thesubsection \@arabic\c@subsubsection}
%\renewcommand\theparagraph    {\thesubsubsection\@arabic\c@paragraph}
%\renewcommand\thesubparagraph {\theparagraph\@arabic\c@subparagraph}
% #### s4145
\renewcommand \thesection {\thechapter.\@arabic\c@section} % ����� � ������ ��������������

\renewcommand\thesubsection   {\thesection.\@arabic\c@subsection}
\renewcommand\thesubsubsection{\thesubsection .\@arabic\c@subsubsection}
\renewcommand\theparagraph    {\thesubsubsection.\@arabic\c@paragraph}
\renewcommand\thesubparagraph {\theparagraph.\@arabic\c@subparagraph}
\newcommand\@chapapp{\chaptername} % �� �������� ����� ����� !

\newcommand\part{%
  \if@openright
    \cleardoublepage
  \else
    \clearpage
  \fi
  \thispagestyle{plain}%
  \if@twocolumn
    \onecolumn
    \@tempswatrue
  \else
    \@tempswafalse
  \fi
  \null\vfil
  \secdef\@part\@spart}

\def\@part[#1]#2{%
    \ifnum \c@secnumdepth >-2\relax
      \refstepcounter{part}%
      \addcontentsline{toc}{part}{\thepart\hspace{1em}#1}%
    \else
      \addcontentsline{toc}{part}{#1}%
    \fi
    \markboth{}{}%
    {\centering
     \interlinepenalty \@M
     \normalfont
     \ifnum \c@secnumdepth >-2\relax
       \huge\bfseries \partname~\thepart
       \par
       \vskip 20\p@
     \fi
     \Huge \bfseries #2\par}%
    \@endpart}
\def\@spart#1{%
    {\centering
     \interlinepenalty \@M
     \normalfont
     \Huge \bfseries #1\par}%
    \@endpart}
\def\@endpart{\vfil\newpage
              \if@twoside
               \if@openright
                \null
                \thispagestyle{empty}%
                \newpage
               \fi
              \fi
              \if@tempswa
                \twocolumn
              \fi}

%-------------------------------------------------------------------------
% 
\newcommand\chapter{
        \if@openright\cleardoublepage\else\clearpage\fi % �� ����������� � ��������
        \thispagestyle{myheadings}%
        \global\@topnum\z@
%-------------------------------------------------
        \@afterindentfalse  % false - ��������� �������� ������, true - ����� ������
        %\@afterindenttrue  % false - ��������� �������� ������, true - ����� ������
%-------------------------------------------------
        \secdef\@chapter\@schapter
}
%-------------------------------------------------------------------------


\def\@chapter[#1]#2{\ifnum \c@secnumdepth >\m@ne
                         \refstepcounter{chapter}%
                         \typeout{\@chapapp\space\thechapter}%
% #### s4145                         \typeout{\@chapapp\space\thechapter.}%
                         \addcontentsline{toc}{chapter}%
                                   {\protect\numberline{\thechapter}#1}%
% #### s4145                                   {\protect\numberline{\thechapter.}#1}%
                    \else
                      \addcontentsline{toc}{chapter}{#1}%
                    \fi
                    \chaptermark{#1}%
                    \addtocontents{lof}{\protect\addvspace{10\p@}}%
                    \addtocontents{lot}{\protect\addvspace{10\p@}}%
                    \if@twocolumn
                      \@topnewpage[\@makechapterhead{#2}]%
                    \else
                      \@makechapterhead{#2}%
                      \@afterheading
                    \fi}
%-----------------------------------------------------------------------
% ���������� ���� ���������� �� ���������� ��������� ��������
%

\def\@makechapterhead#1{ % ���������� ���� �������� - ���������
    \vspace*{-1em} % ������ ����� ������ ��������%  \vspace*{20\p@}%

    \if@isapp % ���� ��� ����������
    { \parindent \z@ \raggedright \normalfont
      \ifnum \c@secnumdepth >\m@ne
      \centering\normalsize\bfseries \@chapapp \space\thechapter 
      \par\nobreak
%      \vskip 20\p@
      \fi
      \interlinepenalty\@M
%      \normalsize \bfseries #1\par\nobreak
      \large \bfseries #1\par\nobreak
% #### s4145    \centering\normalsize \bfseries #1\par\nobreak
      \vskip 20\p@
    }
    \else % ���� ��� �� ���������� , � ���������� �����
    { 
      \parindent \z@ \raggedright \normalfont
      \ifnum \c@secnumdepth >\m@ne
%-------------------------------------------------
%      {\hspace{11.0mm}} % ������ �� �������� �����
%-------------------------------------------------
      \large\bfseries \@chapapp \space \thechapter {} \hspace{3.0mm} %mgena
      \fi
      \interlinepenalty\@M
% #### s4145     \normalsize \bfseries #1\par\nobreak
%      \large \bfseries #1 QQQQ\par\nobreak
      \large \bfseries #1\par\nobreak
      \vskip 20\p@ 
%      \vskip 20\p@\noindent
      } 
    \fi
  }
%-----------------------------------------------------------------------

\def\@schapter#1{\if@twocolumn
                   \@topnewpage[\@makeschapterhead{#1}]%
                 \else
                   \@makeschapterhead{#1}%
                   \@afterheading
                 \fi}
\def\@makeschapterhead#1{%
%  \vspace*{20\p@}%
   \vspace*{-1em}
  {\parindent \z@ \raggedright
    \normalfont
    \interlinepenalty\@M
% #### s4145    \centering \normalsize \bfseries  #1 \par\nobreak
    \centering \large \bfseries  #1 \par\nobreak
    \vskip 20\p@
  }}

%-------------------------------------------------------------------------
%mgena
%\newcommand\section{\@startsection {section}{1}{\parindent}% 
%                                   {3.5ex \@plus 1ex \@minus .2ex}%
%                                   {2.3ex \@plus.2ex}%
%                                   {\normalfont\large\bfseries}}

\newcommand\section{\@startsection % ����� 6 ����������
        {section} % ��� �������� ��� ��������� �������� (����� �����������)
        {1}       % ������� ����������� �������
        {0pt}     % {\z@} ������ ��������� �� ������ ���� 
        {-3.5ex \@plus 1ex \@minus .2ex} % ������������ ������ ����� ����������
                                         % ���� '-' ��������� �������� ������
        {2.3ex \@plus.2ex}               % --//-- ����� ���������
        {\normalfont\large\bfseries}     % ����� ���������� ���������
}

%\newcommand\subsection{\@startsection{subsection}{2}{\parindent}%%{\z@}%
\newcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                     {-3.25ex\@plus 1ex \@minus .2ex}%
                                     {1.5ex \@plus .2ex}%
                                     {\normalfont\normalsize\bfseries}}

%\newcommand\subsubsection{\@startsection{subsubsection}{3}{\parindent}%%{\z@}%
\newcommand\subsubsection{\@startsection{subsubsection}{3}{\parindent}%%{\z@}%
                                     {3.25ex\@plus 1ex \@minus .2ex}%
                                     {1.5ex \@plus .2ex}%
                                     {\centering\normalfont\normalsize\bfseries}}
\newcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
                                    {3.25ex \@plus1ex \@minus.2ex}%
                                    {-1em}%
                                    {\normalfont\normalsize\bfseries}}
\newcommand\subparagraph{\@startsection{subparagraph}{5}{\parindent}%
                                       {3.25ex \@plus1ex \@minus .2ex}%
                                       {-1em}%
                                      {\normalfont\normalsize\bfseries}}
%----------------------------------------------------------
% ���������� ��������

\if@twocolumn
  \setlength\leftmargini  {2em}
\else
  \setlength\leftmargini  {2.5em}
\fi

\leftmargin  \leftmargini
\setlength\leftmarginii  {2.2em}
\setlength\leftmarginiii {1.87em}
\setlength\leftmarginiv  {1.7em}

\if@twocolumn
  \setlength\leftmarginv  {.5em}
  \setlength\leftmarginvi {.5em}
\else
  \setlength\leftmarginv  {1em}
  \setlength\leftmarginvi {1em}
\fi

\setlength  \labelsep  {.5em}

\setlength  \labelwidth{\leftmargini}
\addtolength\labelwidth{-\labelsep}
\@beginparpenalty -\@lowpenalty
\@endparpenalty   -\@lowpenalty
\@itempenalty     -\@lowpenalty
\renewcommand\theenumi{\@arabic\c@enumi}
\renewcommand\theenumii{\@alph\c@enumii}
\renewcommand\theenumiii{\@roman\c@enumiii}
\renewcommand\theenumiv{\@Alph\c@enumiv}

% #### s4145 \newcommand\labelenumi{\theenumi.}
\newcommand\labelenumi{\theenumi)}
\newcommand\labelenumii{(\theenumii)}
\newcommand\labelenumiii{\theenumiii.}
\newcommand\labelenumiv{\theenumiv.}
\renewcommand\p@enumii{\theenumi}
\renewcommand\p@enumiii{\theenumi(\theenumii)}
\renewcommand\p@enumiv{\p@enumiii\theenumiii}

% #### s4145 \newcommand\labelitemi{\textbullet}
\newcommand\labelitemi{--}
\newcommand\labelitemii{\normalfont\bfseries \textendash}
\newcommand\labelitemiii{\textasteriskcentered}
\newcommand\labelitemiv{\textperiodcentered}
%----------------------------------------------------------
%----------------------------------------------------------

\newenvironment{description}
               {\list{}{\labelwidth\z@ \itemindent-\leftmargin
                        \let\makelabel\descriptionlabel}}
               {\endlist}
\newcommand*\descriptionlabel[1]{\hspace\labelsep
                                \normalfont\bfseries #1}
   \newenvironment{abstract}{%
      \if@twocolumn
        \section*{\abstractname}%
      \else
        \normalsize
        \begin{center}%
%          {\bfseries \abstractname\vspace{-.5em}\vspace{\z@}}%
          {\bfseries \abstractname\vspace{+.5em}\vspace{\z@}}%
        \end{center}%
        \par
      \fi}{\newpage}
\newenvironment{verse}
               {\let\\\@centercr
                \list{}{\itemsep      \z@
                        \itemindent   -1.5em%
                        \listparindent\itemindent
                        \rightmargin  \leftmargin
                        \advance\leftmargin 1.5em}%
                \item\relax}
               {\endlist}
\newenvironment{quotation}
               {\list{}{\listparindent 1.5em%
                        \itemindent    \listparindent
                        \rightmargin   \leftmargin
                        \parsep        \z@ \@plus\p@}%
                \item\relax}
               {\endlist}
\newenvironment{quote}
               {\list{}{\rightmargin\leftmargin}%
                \item\relax}
               {\endlist}
\if@compatibility
\newenvironment{titlepage}
    {%
      \if@twocolumn
        \@restonecoltrue\onecolumn
      \else
        \@restonecolfalse\newpage
      \fi
      \thispagestyle{mbheadings}%
      \setcounter{page}\z@
    }%
    {\if@restonecol\twocolumn \else \newpage \fi
    }
\else
\newenvironment{titlepage}
    {%
      \if@twocolumn
        \@restonecoltrue\onecolumn
      \else
        \@restonecolfalse\newpage
      \fi
      \thispagestyle{mbheadings}%
      \if@titlepgnum
      \else
        \setcounter{page}\@ne
      \fi
    }%
    {\if@restonecol\twocolumn \else \newpage \fi
     \if@twoside\else
       \if@titlepgnum
       \else
         \setcounter{page}{2}%% ����� ��������� ����� ���. �������� ����� 2 %% \@ne
       \fi
     \fi
    }
\fi
%---------------------------------------------------------------------
%\newcommand\Ralph[1]{ #1}

% ���������� 
%---------------------------------------------------------------------
\newcommand\appendix{\par
  \setcounter{chapter}{0}%
  \setcounter{section}{0}%
  \@isapptrue
  \gdef\@chapapp{\appendixname}%

%  \gdef\thechapter{\@Roman\c@chapter}
%  \gdef\thechapter{\ifnum \number\c@chapter=1 � \else � \fi}
  \gdef\thechapter{\ifnum \number\c@chapter=1 \CYRA \else \CYRB  \fi}

%------------------------------------------
%  \gdef\thechapter{\@roman\c@chapter}
%  \gdef\thechapter{\@Alph\c@chapter}
%  \gdef\thechapter{\@alph\c@chapter}
%  \gdef\thechapter{\@arabic\c@chapter}

%   \gdef\thechapter{\number\c@chapter}
%   \gdef\thechapter{\romannumeral\c@chapter}
%  \gdef\thechapter{\@Ralph\c@chapter}
%------------------------------------------
}
%---------------------------------------------------------------------
% 
%---------------------------------------------------------------------

\setlength\arraycolsep{5\p@}
\setlength\tabcolsep{6\p@}
\setlength\arrayrulewidth{.4\p@}
\setlength\doublerulesep{2\p@}
\setlength\tabbingsep{\labelsep}
\skip\@mpfootins = \skip\footins
\setlength\fboxsep{3\p@}
\setlength\fboxrule{.4\p@}
\@addtoreset {equation}{chapter}
\renewcommand\theequation
  {\ifnum \c@chapter>\z@ \thechapter.\fi \@arabic\c@equation}

%----------------------------------------------
%\newcounter{figure}[chapter]
%\renewcommand \thefigure {\ifnum \c@chapter>\z@ \thechapter.\fi \@arabic\c@figure}
\newcounter{figure}    % �� ���� ����� ���������� �������� �����
\renewcommand \thefigure {\@arabic\c@figure} %  � ������� ���������� ���������

\def\fps@figure{tbp}
\def\ftype@figure{1}
\def\ext@figure{lof}
\def\fnum@figure{\figurename~\thefigure}
\newenvironment{figure}
               {\@float{figure}}
               {\end@float}
\newenvironment{figure*}
               {\@dblfloat{figure}}
               {\end@dblfloat}
%----------------------------------------------

\newcounter{table}[chapter]
\renewcommand \thetable
     {\ifnum \c@chapter>\z@ \thechapter.\fi \@arabic\c@table}
\def\fps@table{tbp}
\def\ftype@table{2}
\def\ext@table{lot}
\def\fnum@table{\tablename~\thetable}
\newenvironment{table}
               {\@float{table}}
               {\end@float}
\newenvironment{table*}
               {\@dblfloat{table}}
               {\end@dblfloat}
\newlength\abovecaptionskip
\newlength\belowcaptionskip
\setlength\abovecaptionskip{10\p@}
\setlength\belowcaptionskip{5\p@}
\long\def\@makecaption#1#2{%
  \vskip\abovecaptionskip
  \if@tabletitle
    \hbox to \hsize {\hfil #1.} %%
    \sbox\@tempboxa{#2} %%%  \hspace*{12.5mm} �������� ���� ����� ������
    \ifdim \wd\@tempboxa >\hsize
      #2\par %%% \hspace*{12.5mm} �������� ���� ����� ������
    \else
      \global \@minipagefalse
      \hb@xt@\hsize{\hfil\box\@tempboxa\hfil}%
    \fi
  \else
    \sbox\@tempboxa{#1 -- #2} %
% #### s4145    \sbox\@tempboxa{#1. #2} %
    \ifdim \wd\@tempboxa >\hsize
        #1 -- #2\par
% #### s4145       #1. #2\par
    \else
        \global \@minipagefalse
        \hb@xt@\hsize{\hfil\box\@tempboxa\hfil}%
    \fi
  \fi
  \vskip\belowcaptionskip}
\DeclareOldFontCommand{\rm}{\normalfont\rmfamily}{\mathrm}
\DeclareOldFontCommand{\sf}{\normalfont\sffamily}{\mathsf}
\DeclareOldFontCommand{\tt}{\normalfont\ttfamily}{\mathtt}
\DeclareOldFontCommand{\bf}{\normalfont\bfseries}{\mathbf}
\DeclareOldFontCommand{\it}{\normalfont\itshape}{\mathit}
\DeclareOldFontCommand{\sl}{\normalfont\slshape}{\@nomath\sl}
\DeclareOldFontCommand{\sc}{\normalfont\scshape}{\@nomath\sc}
\DeclareRobustCommand*\cal{\@fontswitch\relax\mathcal}
\DeclareRobustCommand*\mit{\@fontswitch\relax\mathnormal}
\newcommand\@pnumwidth{1.55em}
\newcommand\@tocrmarg{2.55em}
\newcommand\@dotsep{4.5}
\setcounter{tocdepth}{2}
\newcommand\tableofcontents{%
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \if@aschapter
       \chapter*{\contentsname
          \@mkboth{%
          \MakeUppercase\contentsname}{\MakeUppercase\contentsname}}%
    \else
        \section*{\contentsname
          \@mkboth{%
          \MakeUppercase\contentsname}{\MakeUppercase\contentsname}}%
    \fi
    \@starttoc{toc}%
    \if@restonecol\twocolumn\fi
    }
\newcommand*\l@part[2]{%
  \ifnum \c@tocdepth >-2\relax
    \addpenalty{-\@highpenalty}%
    \addvspace{2.25em \@plus\p@}%
    \begingroup
      \parindent \z@ \rightskip \@pnumwidth
      \parfillskip -\@pnumwidth
      {\leavevmode
       \large \bfseries #1\hfil \hb@xt@\@pnumwidth{\hss #2}}\par
       \nobreak
         \global\@nobreaktrue
         \everypar{\global\@nobreakfalse\everypar{}}%
    \endgroup
  \fi}
\newcommand*\l@chapter[2]{%
  \ifnum \c@tocdepth >\m@ne
    \addpenalty{-\@highpenalty}%
    \vskip 1.0em \@plus\p@
    \setlength\@tempdima{1.5em}%
    \begingroup
      \parindent \z@ \rightskip \@pnumwidth
      \parfillskip -\@pnumwidth
      \leavevmode \bfseries
      \advance\leftskip\@tempdima
      \hskip -\leftskip
      #1\nobreak\hfil \nobreak\hb@xt@\@pnumwidth{\hss #2}\par
      \penalty\@highpenalty
    \endgroup
  \fi}
\newcommand*\l@section{\@dottedtocline{1}{1.5em}{2.3em}}
\newcommand*\l@subsection{\@dottedtocline{2}{3.8em}{3.2em}}
\newcommand*\l@subsubsection{\@dottedtocline{3}{7.0em}{4.1em}}
\newcommand*\l@paragraph{\@dottedtocline{4}{10em}{5em}}
\newcommand*\l@subparagraph{\@dottedtocline{5}{12em}{6em}}

%-----------------------------------------------------
\newcommand\listoffigures{%
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \chapter*{\listfigurename
      \@mkboth{\MakeUppercase\listfigurename}%
              {\MakeUppercase\listfigurename}}%
    \@starttoc{lof}%
    \if@restonecol\twocolumn\fi
    }
\newcommand*\l@figure{\@dottedtocline{1}{1.5em}{2.3em}}
%-----------------------------------------------------

\newcommand\listoftables{%
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \chapter*{\listtablename
      \@mkboth{%
          \MakeUppercase\listtablename}{\MakeUppercase\listtablename}}%
    \@starttoc{lot}%
    \if@restonecol\twocolumn\fi
    }
\let\l@table\l@figure

%------------------------------------------------------------
\newdimen\bibindent
\setlength\bibindent{1.5em}

%
% ������������
%------------------------------------------------------------
\newenvironment{thebibliography}[1]
  {
  \if@aschapter
     \chapter*{\bibname
        \@mkboth{\MakeUppercase\bibname}{\MakeUppercase\bibname}
        \addcontentsline{toc}{chapter}{\bibname}}
  \else
     \section*{\bibname
        \@mkboth{\MakeUppercase\bibname}{\MakeUppercase\bibname}
        \addcontentsline{toc}{section}{\bibname}}
  \fi
  %%% ��������� � ���������� ---------------------------------
      \list{\@biblabel{\@arabic\c@enumiv}}%
           {\settowidth\labelwidth{\@biblabel{#1}}%
            \leftmargin\labelwidth
            \advance\leftmargin\labelsep
            \@openbib@code
            \usecounter{enumiv}%
            \let\p@enumiv\@empty
            \renewcommand\theenumiv{\@arabic\c@enumiv}}%
      \sloppy
      \clubpenalty4000
      \@clubpenalty \clubpenalty
      \widowpenalty4000%
      \sfcode`\.\@m}
%------------------------------------------------------------

 {\def\@noitemerr
 {\@latex@warning{Empty `thebibliography' environment}}%
  \endlist}

\newcommand\newblock{\hskip .11em\@plus.33em\@minus.07em}
\let\@openbib@code\@empty
%------------------------------------------------------------

\newenvironment{theindex}
               {\if@twocolumn
                  \@restonecolfalse
                \else
                  \@restonecoltrue
                \fi
                \columnseprule \z@
                \columnsep 35\p@
                \twocolumn[\@makeschapterhead{\indexname}]%
                \@mkboth{\MakeUppercase\indexname}%
                        {\MakeUppercase\indexname}%
                \thispagestyle{plain}\parindent\z@
                \parskip\z@ \@plus .3\p@\relax
                \let\item\@idxitem}
               {\if@restonecol\onecolumn\else\clearpage\fi}
\newcommand\@idxitem{\par\hangindent 40\p@}
\newcommand\subitem{\@idxitem \hspace*{20\p@}}
\newcommand\subsubitem{\@idxitem \hspace*{30\p@}}
\newcommand\indexspace{\par \vskip 10\p@ \@plus5\p@ \@minus3\p@\relax}
\renewcommand\footnoterule{%
  \kern-3\p@
  \hrule\@width.4\columnwidth
  \kern2.6\p@}
\@addtoreset{footnote}{chapter}
\newcommand\@makefntext[1]{%
    \parindent 1em%
    \noindent
    \hb@xt@1.8em{\hss\@makefnmark}#1}

\newcommand\contentsname{Contents}
\newcommand\listfigurename{List of Figures}
\newcommand\listtablename{List of Tables}
\newcommand\bibname{Bibliography}
\newcommand\indexname{Index}

%------------------------------------------------
\newcommand\figurename{Figure}
%------------------------------------------------

\newcommand\tablename{Table}
\newcommand\partname{Part}
\newcommand\chaptername{Chapter}
\newcommand\appendixname{Appendix}
\newcommand\abstractname{Abstract}
\def\today{\ifcase\month\or
  January\or February\or March\or April\or May\or June\or
  July\or August\or September\or October\or November\or December\fi
  \space\number\day, \number\year}
\def\Today{
  \number\day.\number\month}

\setlength\columnsep{10\p@}
\setlength\columnseprule{0\p@}
\pagestyle{myheadings}
\pagenumbering{arabic}
\if@twoside
\else
  \raggedbottom
\fi
\if@twocolumn
  \twocolumn
  \sloppy
  \flushbottom
\else
  \onecolumn
\fi

%%% ----------------------------------------------------------------------------
%% ������������ �������

%\topmargin -19mm
\topmargin -14mm
\topskip -5mm

%\evensidemargin 4.6mm
%\oddsidemargin 4.6mm  % ������ ����� ������ ??!!
\evensidemargin 0.0mm
\oddsidemargin 0.0mm

\textwidth 170mm
\textheight 242mm
%\textheight 237mm
\footskip 10mm
\headheight 4.2mm
\headsep 9.4mm

%% �������������� ���������� ����� �������� � ������ ������� ������
\renewcommand{\baselinestretch}{1.25}
\parindent12.5mm
%\parindent7.0mm  %mgena  

%%% ----------------------------------------------------------------------------
%\flushbottom % ��� �������� ����� ���������� ������ - ��� �����������?

%\renewcommand{\thesection}{\thechapter.\arabic{section}.}
%\renewcommand{\thesubsection}{\thesection\arabic{subsection}.}
%\renewcommand{\thesubsubsection}{\thesubsection\arabic{subsubsection}.}

%%% ----------------------------------------------------------------------------
%%
\endinput
%%% ----------------------------------------------------------------------------
%%
%% End of file `mbreport.cls'.
