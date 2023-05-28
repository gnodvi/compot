# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#
#sudo apt install texlive-metapost
#
# ============================================================================#
#
# Makefile для проекта <<Создание иллюстраций в MetaPost>>.
# 2006 (c) Балдин Е.М. 
#
# ============================================================================#

b_name := bald
b_figs := 11  12  13  14  24  27  28
B_RESULT := $(foreach fig,$(b_figs),$(b_name).$(fig).eps)

m_name := pics
m_figs := 2 3 4 6 9 14 16 23
M_RESULT := $(foreach fig,$(m_figs),$(m_name).$(fig).eps)

h_name := hugs
h_figs := 1 2 3 4 5 6 7 8
H_RESULT := $(foreach fig,$(h_figs),$(h_name).$(fig).eps) 

g_name := mpgraph
g_figs := 1 2 3 4 5 6 7
G_RESULT := $(foreach fig,$(g_figs),$(g_name).$(fig).eps) 

#временный файл
tmp_file := tmp_file

#программы
LATEX := latex 
MPOST := TEX=latex mpost 
DVIPS := dvips

# ============================================================================#

ALL_RESULT = $(G_RESULT) $(H_RESULT) #$(B_RESULT) $(M_RESULT) 

#ALL_RESULT = mpgraph.2.eps
 
all: $(ALL_RESULT)  report.dvi report.pdf

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

report.pdf : report.dvi
	dvipdfm $^

report.dvi : report.tex
	$(LATEX) $^ 


%.eps:  % 
	@echo  "\documentclass{article}">$(tmp_file).tex
	@echo  "\usepackage[warn]{mathtext}">>$(tmp_file).tex
	@echo  "\usepackage[T2A]{fontenc}">>$(tmp_file).tex
	@echo  "\usepackage[koi8-r]{inputenc}">>$(tmp_file).tex
	@echo  "\usepackage[english,russian]{babel}">>$(tmp_file).tex
	@echo  "\usepackage{graphicx}">>$(tmp_file).tex
	@echo  "\DeclareGraphicsRule{*}{eps}{*}{}">>$(tmp_file).tex

	@echo  '\\nofiles'               >> $(tmp_file).tex
	@echo  '\\begin{document}'       >> $(tmp_file).tex
	@echo  '\\thispagestyle{empty}'  >> $(tmp_file).tex

	@echo  "\includegraphics{$(basename $@)}">> $(tmp_file).tex
	@echo  "\end{document}">> $(tmp_file).tex

	$(LATEX) $(tmp_file) 
	$(DVIPS) -E -o $@ $(tmp_file) 
	rm  $(tmp_file).* 
	@echo  ""

# ============================================================================#

# выполняется один раз на все картинки
mpgraph.1: mpgraph.mp 
	TEX=tex mpost mpgraph



#Зависимости
%.1: %.mp 
	$(MPOST) $<
%.2: %.mp 
	$(MPOST) $<
#mv %.2 %.02

%.3: %.mp 
	$(MPOST) $<
%.4: %.mp 
	$(MPOST) $<
%.5: %.mp 
	$(MPOST) $<
%.6: %.mp 
	$(MPOST) $<
%.7: %.mp 
	$(MPOST) $<
%.8: %.mp 
	$(MPOST) $<
%.9: %.mp 
	$(MPOST) $<
%.10: %.mp 
	$(MPOST) $<
%.11: %.mp 
	$(MPOST) $<
%.12: %.mp 
	$(MPOST) $<
%.13: %.mp 
	$(MPOST) $<
%.14: %.mp 
	$(MPOST) $<
%.15: %.mp 
	$(MPOST) $<
%.16: %.mp 
	$(MPOST) $<
%.17: %.mp 
	$(MPOST) $<
%.18: %.mp 
	$(MPOST) $<
%.19: %.mp 
	$(MPOST) $<
%.20: %.mp 
	$(MPOST) $<
%.21: %.mp 
	$(MPOST) $<
%.22: %.mp 
	$(MPOST) $<
%.23: %.mp 
	$(MPOST) $<
%.24: %.mp 
	$(MPOST) $<
%.25: %.mp 
	$(MPOST) $<
%.26: %.mp 
	$(MPOST) $<
%.27: %.mp 
	$(MPOST) $<
%.28: %.mp 
	$(MPOST) $<
%.29: %.mp 
	$(MPOST) $<
%.30: %.mp 
	$(MPOST) $<
%.31: %.mp 
	$(MPOST) $<
%.32: %.mp 
	$(MPOST) $<
%.33: %.mp 
	$(MPOST) $<
%.34: %.mp 
	$(MPOST) $<
%.35: %.mp 
	$(MPOST) $<
%.36: %.mp 
	$(MPOST) $<
%.37: %.mp 
	$(MPOST) $<
%.38: %.mp 
	$(MPOST) $<
%.39: %.mp 
	$(MPOST) $<
%.40: %.mp 
	$(MPOST) $<
%.41: %.mp 
	$(MPOST) $<
%.42: %.mp 
	$(MPOST) $<
%.43: %.mp 
	$(MPOST) $<
%.44: %.mp 
	$(MPOST) $<
%.45: %.mp 
	$(MPOST) $<
%.46: %.mp 
	$(MPOST) $<
%.47: %.mp 
	$(MPOST) $<
%.48: %.mp 
	$(MPOST) $<
%.49: %.mp 
	$(MPOST) $<
%.50: %.mp 
	$(MPOST) $<
%.51: %.mp 
	$(MPOST) $<
%.52: %.mp 
	$(MPOST) $<
%.53: %.mp 
	$(MPOST) $<
%.54: %.mp 
	$(MPOST) $<
%.55: %.mp 
	$(MPOST) $<
%.56: %.mp 
	$(MPOST) $<
%.57: %.mp 
	$(MPOST) $<
%.58: %.mp 
	$(MPOST) $<
%.59: %.mp 
	$(MPOST) $<

# ============================================================================#

ARX_NAME = report

save : clean 
	tar --ignore-failed-read -cvf $(ARX_NAME).tar  *
	gzip -6 $(ARX_NAME).tar  
	(cd Archiv; mdat) 
#	tar --ignore-failed-read -cvf $(ARX_NAME).tar  *.mp *.tex *.dat *.cls *.sty Makefile* 

# ============================================================================#

LATEX_FILES = *.aux  *.dvi  *.glo *.toc 
MPOST_FILES =  mpx*  *.log  *.mpx 

clean:
	rm  -f *~ $(ALL_RESULT) $(MPOST_FILES) $(LATEX_FILES) *.pdf
	rm  -f *.{1..4}


#	@rm -f $(tmp_file).*

# ============================================================================#
