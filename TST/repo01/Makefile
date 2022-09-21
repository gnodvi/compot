# ============================================================================#
#
#
# ============================================================================#


LATEX := latex 
MPOST := TEX=latex mpost 
DVIPS := dvips

# ============================================================================#


ALL_RESULT = sample.pdf  zrobot.pdf zrobot.dvi ###report.pdf # ## # report_koi.pdf # report_win.pdf  # report_utf.pdf  

all: $(ALL_RESULT)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# report.pdf : report.dvi
# 	dvipdfm $^

# report.dvi : report.tex Makefile m-titl.sty m-repo.cls
# 	$(LATEX) $^ 
# 	$(LATEX) $^ 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sample.pdf : sample.dvi
	dvipdfm $^

sample.dvi : sample.tex 
	$(LATEX) $^ 
	$(LATEX) $^ 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


zrobot.pdf : zrobot.dvi
	dvipdfm $^

zrobot.dvi : zrobot.tex Makefile m-titl.sty m-repo.cls
	$(LATEX) $^ 
	$(LATEX) $^ 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#report_win.pdf : report_win.dvi
#	dvipdfm $^

#report_win.dvi : report_win.tex Makefile m-titl.sty m-repo.cls
#	$(LATEX) $^ 
#	$(LATEX) $^ 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#report_utf.pdf : report_utf.dvi
#	dvipdfm $^

#report_utf.dvi : report_utf.tex Makefile m-titl.sty m-repo.cls
#	$(LATEX) $^ 
#	$(LATEX) $^ 

# ============================================================================#

LATEX_FILES = *.aux *.dvi *.glo *.toc *.pdf
MPOST_FILES =  mpx*  *.log  *.mpx 

clean:
	@rm  -f *~ $(ALL_RESULT) $(MPOST_FILES) $(LATEX_FILES) 

# ============================================================================#
#
# Установленные пакеты по Latex в Ubuntu:
#
# texlive-latex-base
# texlive-latex-recommended
# texlive-pictures
# texlive-latex-base-doc
# texlive-latex-extra-doc
# texlive-latex-recommended-doc
# preview-latex-style
# latex-beamer
# texlive-latex-extra
# lacheck  : Simple syntax checker for LaTeX
# texlive-lang-cyrillic
# prosper  : LaTeX class for writing transparencies
# tipa     : system for processing phonetic symbols in LaTeX
# feynmf   : set of LaTeX macros for creating Feynman diagrams
# texlive-extra-utils : TeX Live: TeX auxiliary programs
# texlive-base
# latex-xcolor : Easy driver-independent TeX class for color
# texlive-binaries 
# texlive-font-utils
# pgf      : TeX Portable Graphic Format
# texlive-metapost : TeX Live: MetaPost (and Metafont) drawing packages
# texlive-pstricks
# texlive-fonts-recommended
# 
# ============================================================================#
