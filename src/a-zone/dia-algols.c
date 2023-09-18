// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************/ 

#ifdef  D_DIAL_3  
/*************************************************************************/

#include "dia-y_zone.h" 
#include "dia-algols.h" 


/*-------------------------------MAIN-----------------------------------*/
long
MAIN (PFUNC_VAR)
{

  switch (message) {
  case YCREATE:
    /* YInitDRAW (); */
    YInitWIND (); 
    YInitALGO (); 

    YAlgLoadTest ();

    YAlgParse (mes2, (char**) mes3); 

    YAlgResolve ();

    if (START_ACT == YCALC) {
      YAlgCalc (START_NAME);
      YExit (0);
    } else {
      YBigWindow (NULL, MODLIST, "Dial_3", 0,0, 550-60-80, 340-10, 
		  (long)START_NAME,0,0,0, CLR_DEF);     
    }

    break; 
  case YFINAL:
/*       OUTD(11); */
/*       YFinalYlib (); */
    break; 
  }

  id++;
  RETURN_TRUE;
}
/*----------------------------------------------------------------------*/
/****************************************************************************/ 

#endif
#if defined(D_ALGO) 
/**************************************************************************** 
 *                                                                          * 
 *                          ALGO ALGO ALGO ALGO ALGO                        * 
 *                                                                          * 
 **************************************************************************** 
 */  
 
#include "dia-y_zone.h" 
#include "dia-algols.h" 
 
 
#define  SIZE_MAPS  50 
#define  SIZE_PARS  50 
typedef struct { 
  char    *adir_root_name; 
  int      adir_root_mod; 
  int      adir_cur_mod; 
  void    *allmaps; 
  AT_MAP  *maps[SIZE_MAPS]; 
  AT_PAR  *pars[SIZE_PARS]; 
} YT_ALGO_S; 
 
#define  ALGO_S ((YT_ALGO_S *)(ALGO->zalg_s))  
 
typedef struct { 
  int    id_from; 
  int    how; 
  int    message; 
  int    mes1; 
  int    mes2; 
  long   mes3; 
  long   mes4; 
} AT_OUTPUT; 
 
YT_ALGO *zalg; 
 
void*    YAlgReadMaps(void); 
char**   YAlgReadPars (char **pstr); 
char**   YAlgReadMap (char **pstr); 
long     YAlgMapByName(char *map_name); 
void     YAlgDrawMap (int id_map, void *map); 
char**   YAlgReadMap_plan (char **plandef, long  map_new_long); 
char**   YAlgReadMap_text (char **pstr, AT_TEXT *text); 
int      YAdirRootSet (char *name_init); 
void     YAdirRootDel (void); 
 
YT_BOOL  VParSetNew (VT_PARS *pars, char *name_set, void *pdata); 
 
 
/****************************************************************************/ 
/*---------------------------------YInitALGO--------------------------------*/ 
void   
YInitALGO () 
{ 
  AT_PNAME1 pnames[] = { 
/*     { "MAP",      MAP      },  */ 
    { "mKran",    mKran    },    
    { "mDitto",   mDitto   },    
    { "mControl", mControl },   
    { NULL } 
  }; 
  
  int  i; 
 
  YMALLOC (ALGO, YT_ALGO, 1);   
  YMALLOC (ALGO->zalg_s, YT_ALGO_S, 1); 
 
  YSetPnames (pnames); 
  YSet ("MM_APPLY", MM_APPLY); 
 
  for (i=0; i<SIZE_MAPS; i++)  
    ALGO_S->maps[i] = NULL; 
  ALGO_S->allmaps = ALGO_S->maps;  
 
  for (i=0; i<SIZE_PARS; i++)  
    ALGO_S->pars[i] = NULL; 
 
/*   KERN->stop_flag = FALSE; */ 
  ALGO->stop_flag = FALSE; 
 
  /* ---- */ 
  YSet ("modlist", ID_NULL); 
  /* YNextProcSet (MAP, MAP_gr); */ 
  /* ---- */ 
 
  return; 
} 
/*-------------------------------YAlgReadAll----------------------------*/ 
void 
YAlgReadAll (char **pstr) 
{ 
  char  w1[40], w2[40]; 
 
  if (pstr == NULL)  
    return; 
 
  for ( ; *pstr != NULL; ) { 
    sscanf (*pstr, "%s %s ", w1, w2); 
    if (YStrCmp(w1, "@PARS"))     {pstr = YAlgReadPars (pstr); continue;} 
    if (YStrCmp(w1, "@MAP"))      {pstr = YAlgReadMap (pstr);  continue;} 
    if (YStrCmp(w1, "@OPEN"))     {YAlgSetStart (YOPEN, w2); pstr++;  continue;} 
    if (YStrCmp(w1, "@CALC"))     {YAlgSetStart (YCALC, w2); pstr++;  continue;} 
    if (w1[0] == A_COMMENT)       {pstr++;  continue;} 
    else   
      {/* YWarningS("YAlgReadAll", *pstr); */ pstr++; } 
  } 
 
  return; 
} 
/*------------------------------YParChange---------------------------------*/ 
void 
YParChange (VT_PARS *pars_old, VT_PARS *pars_new) 
{ 
 VT_PARS  *oldpar, *newpar; 
 
 for (newpar=pars_new; (newpar->type!=NULL); newpar++) { 
   for (oldpar=pars_old; (oldpar->type!=NULL); oldpar++) { 
     if (YStrCmp(oldpar->name, newpar->name)) { 
       memcpy (oldpar, newpar, sizeof(VT_PARS)); 
       goto next; 
     } 
   } 
   memcpy (oldpar, newpar, sizeof(VT_PARS)); 
   (oldpar++)->type = NULL; 
   next: ;; 
 } 
 
 return; 
} 
/*--------------------------------YAlgSetNewPars---------------------------*/ 
YT_BOOL  
YAlgSetNewPars (AT_PAR *new_pars) 
{ 
  int      i; 
  AT_PAR *pars; 
 
  for (i=0; TRUE; i++) { 
    if (i == SIZE_PARS)      { 
      YWarning ("SIZE_PARS"); 
      return (FALSE); 
    } 
    pars = ALGO_S->pars[i]; 
    if (pars == NULL) { 
      ALGO_S->pars[i] = new_pars; 
      return (TRUE); 
    } 
    if (YStrCmp(pars->name, new_pars->name)) break; 
  } 
 
  /* change old params !!!!!!*/ 
  YParChange (pars->pars, new_pars->pars); 
 
  return (TRUE); 
} 
/*------------------------------YAlgReadPars---------------------------*/ 
char **  
YAlgReadPars (char **pstr) 
{ 
  AT_PAR  *par; 
  int      i; 
  char buf[20]; 
  VT_PARS *pars; 
 
 
  if (pstr == NULL)  
    return (NULL); 
   
  par = (AT_PAR*) malloc (sizeof(AT_PAR)); 
 
  par->name  = (char*) malloc (80); 
  sscanf (*pstr, "%s %s", buf, par->name); 
 
  pstr++; 
 
  for (i=0; (*pstr)!=NULL; pstr++) { 
 
    if ((*pstr)[0] == A_COMMAND) break; 
    if ((*pstr)[0] == A_COMMENT) continue; 
 
    pars = &(par->pars[i]); 
    strcpy (pars->stype,  ""); 
    strcpy (pars->sname,  ""); 
    strcpy (pars->svalue, ""); 
    sscanf (*pstr, "%s %s %s", pars->stype, pars->sname, pars->svalue); 
    /* fprintf (stderr, "%s %s %s \n", pars->stype, pars->sname, pars->svalue); */ 
    pars->type  = pars->stype; 
    pars->name  = pars->sname; 
    pars->value = pars->svalue; 
    i++; 
 
  } 
  pars = &(par->pars[i]); 
  pars->type = NULL; 
 
 
  YAlgSetNewPars (par); 
 
  return (pstr); 
} 
/*------------------------------YAlgReadMap------------------------------*/ 
char ** 
YAlgReadMap (char **pstr) 
{ 
  char  w1[40], w2[40]; 
 /*  int i; */ 
  AT_MAP   *map_new; 
 
 
  YMALLOC (map_new, AT_MAP, 1); 
  map_new->name = (char*) malloc (100); 
  map_new->text = (AT_TEXT*) malloc (SIZE_MAPTEXT * sizeof(AT_TEXT)); 
 
  sscanf (*pstr, "%s %s", w1, w2); 
  strcpy (map_new->name, w2); 
  pstr++; 
 
  pstr = YAlgReadMap_text (pstr, map_new->text); 
  pstr = YAlgReadMap_plan (pstr, (long)map_new);  
 
  YAlgSetNewMap (map_new); 
 
  return (pstr); 
} 
/*------------------------------YAlgSetNewMap---------------------------*/ 
YT_BOOL  
YAlgSetNewMap (AT_MAP *map_new) 
{ 
  int      i; 
 
  for (i=0; TRUE; i++) { 
    if (i == SIZE_MAPS)  return (FALSE); 
 
    if (ALGO_S->maps[i] == NULL) break; 
    if (YStrCmp(map_new->name, (ALGO_S->maps[i])->name )) break; 
  } 
 
  ALGO_S->maps[i] = map_new; 
 
  return (TRUE); 
} 
/*-----------------------------YAlgReadMap_text-------------------------*/ 
char ** 
YAlgReadMap_text (char **pstr, AT_TEXT *text) 
{ 
  int  i, j; 
  char  txt[250], *txt1, *txt2; 
 
  for (i=0, j=0; TRUE; /* i++, */ j++) { 
 
    if (j >= SIZE_MAPTEXT) { 
      YWarning ("SIZE_MAPTEXT"); 
      continue; 
    } 
    if (pstr[j] == NULL)         break; 
    if (pstr[j][0] == A_COMMAND) break; 
    if (pstr[j][0] == A_COMMENT) continue;  
 
    strcpy (txt, pstr[j]); 
    txt1 = strtok (txt,  "|"); 
    txt2 = strtok (NULL, "|"); 
 
    sscanf (txt1, "%d %d ", &((text[i]).x), &((text[i]).y)); 
    (text[i]).txt = (char*)malloc(250); 
    strcpy((text[i]).txt , txt2);  
 
    i++; 
  } 
  (text[i]).txt = NULL; 
 
  return (&(pstr[j])); 
} 
/*------------------------------YAlgReadMap_plan--------------------------*/ 
char ** 
YAlgReadMap_plan (char **plandef, long  map_new_long) 
{ 
  AT_PLANER  *plan, *pi; 
  AT_MAP     *map_new = (AT_MAP*) map_new_long;  
  char  **pd; 
  int    mid1, mid2, mid3; 
  char   str[250], mnum[50], mbuf[50], wbuf[50], hbuf[50];  
  char  *str1, *str2, *str3; 
 
  plan = (AT_PLANER*)malloc (40*sizeof(AT_PLANER)); 
 
  plandef++; 
  for (pd=plandef, pi=plan; TRUE; pd++/* , pi++ */) { 
 
    if ((*pd == NULL) || (*pd)[0] == A_COMMAND) { 
      pi->mod_id = mid_END; 
      break; 
    } 
    if ((*pd)[0] == A_COMMENT) continue;    /* ?? pd, pi */ 
 
    pi->long1  = YNULL; 
    strcpy (str, *pd); 
 
    str1 = strtok (str,  "|"); 
    str2 = strtok (NULL, "|"); 
    str3 = strtok (NULL, "|"); 
 
    pi->proc_name = (char*) malloc (100); 
    pi->name  = (char*) malloc (100); 
    pi->pars_name = (char*) malloc (100); 
 
    if (str1) 
      sscanf(str1,  " %s %s %s %s %d %d %s %s %s ", mnum, mbuf, pi->proc_name,  
	     pi->pars_name, &(pi->cx), &(pi->cy), wbuf, hbuf, pi->name); 
 
    pi->mod_id = atoi(mnum); 
 
    if      (YStrCmp(mbuf, "YMAP")) pi->type = YMAP; 
    else if (YStrCmp(mbuf, "YMOD")) pi->type = YMOD; 
    else    YWarning("mbuf"); 
 
    if      (YStrCmp(wbuf, "WFU")) pi->w = WFU; 
    else if (YStrCmp(wbuf, "WMI")) pi->w = WMI; 
    else    pi->w = atoi(wbuf); 
 
    if      (YStrCmp(hbuf, "HFU")) pi->h = HFU; 
    else if (YStrCmp(hbuf, "HMI")) pi->h = HMI; 
    else    pi->h = atoi(hbuf); 
 
    if (YStrCmp(pi->pars_name, "NULL")) 
      pi->pars_name = NULL; 
 
    if (YStrCmp(pi->name, "NULL")) 
      pi->name = NULL; 
 
    mid1 = mid2 = mid3 = 0; 
    if (str2) 
      sscanf(str2,  "%d %d %d ", &mid1, &mid2, &mid3); 
    pi->mid[0] = mid1; 
    pi->mid[1] = mid2; 
    pi->mid[2] = mid3; 
 
 
    pi->forphr[0] = (char*) malloc (100); 
    pi->forphr[1] = (char*) malloc (100); 
    pi->forphr[2] = (char*) malloc (100); 
 
    strcpy (pi->forphr[0], ""); 
    strcpy (pi->forphr[1], ""); 
    strcpy (pi->forphr[2], ""); 
 
    if (str3) 
      sscanf(str3,  "%s %s %s ", pi->forphr[0], pi->forphr[1], pi->forphr[2]); 
 
    pi++; 
  } 
 
  map_new->plan = plan; 
  return (pd); 
} 
/*------------------------------YAlgParam------------------------------------*/ 
void 
YAlgParam (VT_PARS *pars_def, char *name, void *pdata, /* char **pars_new */ long pars_new) 
{ 
 
  VParSetNew(pars_def, name, pdata); 
  if (pars_new) { 
    /* VParSet((char**)pars_new, name, pdata); */ 
    VParSetNew((VT_PARS*)pars_new, name, pdata); 
  } 
 
} 
/*-------------------------------YFindPars-----------------------------------*/ 
long YFindPars (char *pars_name) 
{ 
  int  i; 
 
  if (pars_name == NULL) return (YNULL); 
  if (YStrCmp(pars_name, "NULL")) return (YNULL); 
 
  /* OUTS(pars_name); */ 
  for (i=0; TRUE; i++) { 
    if (i == SIZE_PARS)      return (YNULL); 
    if (ALGO_S->pars[i] == NULL) continue; 
    if (YStrCmp((ALGO_S->pars[i])->name, pars_name)) {/* OUTS(pars_name); */break;} 
  } 
 
   
  /* return ((long)((ALGO_S->pars[i])->str)); */ 
  return ((long)((ALGO_S->pars[i])->pars));  /* $$$ */ 
} 
/*--------------------------------YAlgResolve--------------------------------*/ 
void 
YAlgResolve () 
{ 
 
  AT_MAP    **pmap; 
  AT_MAP    *map; 
  AT_PLANER *pi; 
 
  for (pmap=(AT_MAP**)(ALGO_S->allmaps); *pmap != NULL; pmap++) { 
    map = *pmap; 
    for (pi=map->plan; pi->mod_id != mid_END; pi++) { 
 
    if      (pi->type == YMAP) { 
      pi->long1 = (long)YAlgMapByName(pi->proc_name); 
      if (pi->long1 == 0) { 
	pi->type = YMOD; 
	pi->proc_name = "mDitto"; 
      } 
    } else if (pi->type == YMOD)    
      pi->long1 = YFindPars (pi->pars_name); 
    else   
      YWarning ("pi->type"); 
 
    } 
  } 
 
 
  return; 
} 
/*--------------------------------YAlgSetStart------------------------------*/ 
void  
YAlgSetStart (int start_act, char *start_name) 
{ 
 
  START_ACT = start_act; 
  strcpy (START_NAME, start_name); 
 
  return; 
} 
/*-----------------------------YAlgReadFile---------------------------------*/ 
void 
YAlgReadFile (char *file_name) 
{ 
#define SIZE_BUF 200 
#define SIZE_STR 100 
 
  char *buf[SIZE_BUF]; 
  char  str_rab[SIZE_STR]; 
  int i; 
  FILE *fp; 
  YT_BOOL is_shell = FALSE; 
 
  if (!file_name) return; 
  if (!(fp = fopen (file_name, "r"))) { 
    YWarning (file_name); 
    return; 
  } 
 
  i = 0; 
  while (1) { 
    buf[i] = (char*) malloc (SIZE_STR); 
    if (!fgets (str_rab, SIZE_STR-1, fp))  /* !!  buf[i] != NULL not anyware */ 
      break; 
    if ((i == 0) && (strncmp(str_rab, "#!/bin/sh", 9)==0)) { 
      is_shell = TRUE; 
      continue; 
    } 
    if (is_shell && (str_rab[0] == A_SHELL))  
      strcpy (buf[i], str_rab+1); 
    else  
      strcpy (buf[i], str_rab); 
 
    if (i == SIZE_BUF-1) {  
      YWarning("SIZE_BUF");  
      break;  
    } 
    i++; 
  } 
  buf[i] = NULL;  
 
  YAlgReadAll (buf); 
   
  return; 
 
#undef SIZE_BUF 
#undef SIZE_STR 
} 
/*-------------------------------YAlgParse----------------------------------*/ 
YT_BOOL 
YAlgParse (int argc, char **argv)  
{ 
  int   index;  
 /*  int   act;  */ 
 /*  static char *adir_name;  */ 
  
  for (index = 1; index < argc; index++) { 
      YSWITCH (argv[index]) { 
      YCASE ("-file")  YAlgReadFile (argv[++index]); 
      YCASE ("-open")  YAlgSetStart (YOPEN, argv[++index]); 
      YCASE ("-calc")  YAlgSetStart (YCALC, argv[++index]); 
      YDEFAULT          continue;  
      } 
  } 
 
  return (FALSE); 
} 
/*-------------------------------YMainParse---------------------------------*/ 
YT_BOOL 
YMainParse (int argc, char **argv)  
{ 
  int   index;  
  
  for (index = 1; index < argc; index++) { 
 
      YSWITCH (argv[index]) { 
      YCASE ("-font")   
	/* YSet ("font", (long)(argv[++index])); */ 
	Y_FONT = argv[++index]; 
      YDEFAULT   
	continue;  
      } 
 
  } 
 
  return (FALSE); 
} 
/*-------------------------------YAlgMapByName------------------------------*/ 
long  YAlgMapByName(char *map_name) 
{ 
  AT_MAP **pmap; 
  AT_MAP *map; 
 
  for (pmap=(AT_MAP**)(ALGO_S->allmaps); *pmap != NULL; pmap++) { 
    map = *pmap; 
    if (map->name == NULL) continue; 
    if (YStrCmp(map->name, map_name)) return ((long)map); 
  } 
 
  /* YWarningS ("YAlgMapByName", map_name); */ 
 
  return (YNULL); 
} 
/*---------------------------------YAlgCall---------------------------------------*/ 
void YAlgCall (int id, int how, int message, int mes1, int mes2, long mes3, long mes4) 
{ 
 
  
  if      (how == YSEND2FACE)  YSendFrom (id, ID_BACK, message, mes1, mes2, mes3, mes4); 
  else if (how == YSEND2BACK)  YSendFrom (id, ID_FACE, message, mes1, mes2, mes3, mes4); 
 
  else if (how == YPOST2FACE)  YPostFrom (id, ID_BACK, message, mes1, mes2, mes3, mes4);  
  else if (how == YPOST2BACK)  YPostFrom (id, ID_FACE, message, mes1, mes2, mes3, mes4); 
 
  else    YError ("YAlgCall"); 
  
} 
/*-------------------------------YAdirRootSet---------------------------*/ 
int 
YAdirRootSet (char *name_init) 
{ 
  int   mod; 
  long  map; 
 
  map = YAlgMapByName(name_init); 
  if (!map)  
    YErrorS ("YAdirRootSet", name_init); 
 
  YWndCreate (&mod, MAP, NULL, map, 0, 0, 0); 
 
  WNDI(mod)->parent_c = ID_NULL;  
  ALGO_S->adir_root_name = name_init; 
  ALGO_S->adir_root_mod  = mod; 
 
  return (mod); 
} 
/*-------------------------------YAdirRootDel---------------------------*/ 
void 
YAdirRootDel () 
{ 
 
  YModClean (ALGO_S->adir_root_mod); 
 
  return; 
} 
/*-------------------------------YAdirTo-------------------------------*/ 
int 
YAdirTo (char *name_to) 
{ 
  int  mod; 
 
  if (!name_to) return (ALGO_S->adir_root_mod); 
 
  mod = YFindModByName (name_to); 
  if (mod == ID_NULL) { 
    YWarning ("YAdirTo"); 
    mod = ALGO_S->adir_root_mod; 
  } 
 
  ALGO_S->adir_cur_mod = mod; 
 
  return (mod); 
} 
/*-------------------------------YParseStartName------------------------*/ 
YT_BOOL 
YParseStartName (char *start_name, char **root_name, char **cur_name) 
{ 
  char *r_name, *c_name;  
  char *razd = "*"; 
 
  r_name = strtok (start_name, razd); 
  c_name = strtok (NULL, razd); 
 
  if (!c_name) c_name = r_name; 
 
  *root_name = r_name; 
  *cur_name  = c_name; 
 
  return (TRUE); 
} 
/*-------------------------------YAlgCalc-------------------------------*/ 
void 
YAlgCalc (char *start_name) 
{ 
  char  *root_name, *cur_name; 
  static int mod; 
 
  /* root_name = cur_name = start_name; */ 
  YParseStartName (start_name, &root_name, &cur_name); 
 
  YAdirRootSet (root_name); 
  mod = YAdirTo (cur_name); 
 
  YAlgGo (mod);  
 
  return; 
} 
/*------------------------------YAlgGo---------------------------------------*/ 
void 
YAlgGo (int mid) 
{ 
  int  how = YSEND2FACE /* YPOST2FACE */; 
 
  YAlgCall  (mid, how, MM_BEGIN,  0, 0, 0, 0);  
  YAlgCall  (mid, how, MM_APPLY,  0, 0, 0, 0);  
  YAlgCall  (mid, how, MM_END,    0,   0, 0, 0);  
 
  return; 
} 
/*--------------------------------YAlgOut-------------------------------------*/ 
void 
YAlgOut (int how, int message, int mes1, int mes2, long mes3, long mes4) 
{ 
  int   from; 
  AT_OUTPUT ot; 
  int  parent_c; 
 
 /*  mes1 = 0; */ /*!!!!!!!!!!!!!!!!!!!*/ 
/*   from = YGet ("idlast"); */ 
  from = Y_IDLAST; 
 
  if (ALGO->stop_flag) { 
    ALGO->stop_flag = FALSE; 
    return; 
  } 
 
  ot.id_from = from; 
  ot.how = how; 
  ot.message = message; 
  ot.mes1 = mes1; 
  ot.mes2 = mes2; 
  ot.mes3 = mes3; 
  ot.mes4 = mes4; 
 
  parent_c = WNDI(from)->parent_c; 
 
  if (parent_c != ID_NULL) 
    YSend (parent_c, YOUTPUT, 0, 0, LP(ot), 0);  
  else  
    fprintf (Y_STDERR, "YAlgOut: (%d)->parent_c == ID_NULL \n", from); 
 
 
  return; 
} 
/*-------------------------------YAlgPlanering------------------------------------*/ 
YT_BOOL 
YAlgPlanering (AT_PLANER *pl, int id_from, int how, int message,  
	       int mes1, int mes2, long mes3, long mes4) 
{ 
  int     i, j, mid; 
  AT_PLANER *pi, *pi_from; 
 
 /*  message = mes1; */ 
   
  for (pi = pl; pi->mod_id != mid_END; pi++) { 
    /* if (pi->mod_id == mid_TXT) continue; */ 
    if (pi->id_new == id_from) { 
      pi_from = pi; 
      id_from = pi->mod_id; 
      break; 
    } 
  } 
  if (pi->mod_id == mid_END)  YError ("Planering"); 
 
  if (how == YSEND2FACE || how == YPOST2FACE) { 
    for (i = 0; i < NUM_MID; i++) { 
      mid = pi_from->mid[i]; 
      if (!mid) continue; 
      if (mid == mid_OUT) return(FALSE); 
      for (pi = pl; pi->mod_id != mid_END; pi++) 
	if (pi->mod_id == mid) 
	  break; 
      if (pi->mod_id == mid_END)  YError ("Planering"); 
 
      YAlgCall (pi->id_new, how,  message, mes1, mes2, mes3, mes4);    /***/ 
 
    } 
  } else { 
    for (pi = pl; pi->mod_id != mid_END; pi++)  
    for (j = 0; j < NUM_MID; j++) { 
      mid = pi->mid[j]; 
      if (mid == id_from) { 
 
	YAlgCall (pi->id_new, how,  message, mes1, mes2, mes3, mes4);  /***/ 
 
      } 
    } 
  } 
 
  return (TRUE); 
} 
/*-------------------------------YAlgPlanId------------------------------------*/ 
int 
YAlgPlanId (AT_PLANER *plan, int mod_id) 
{ 
  AT_PLANER *p; 
 
  for (p = plan; p->mod_id != mid_END; p++) 
    if (p->mod_id == mod_id) 
      break; 
 
  if (p->mod_id == mid_END)  YError ("YAlgPlanId"); 
 
  return (p->id_new); 
} 
/*-------------------------------begin_end----------------------------------*/ 
void  begin_end (int *mdata, /* AT_TDATA *tdata,  */int *beg) 
{ 
 
  switch (*mdata) { 
  case MM_BEGIN: 
    if ((*beg) != 0) *mdata = MM_PUSTO; 
    (*beg)++; 
    break; 
  case MM_END: 
    (*beg)--; 
    if ((*beg) != 0) *mdata = MM_PUSTO; 
    break; 
  default: ;;  
  } 
 
  return; 
} 
/*--------------------------------MAP------------------------------------*/ 
long 
MAP (PFUNC_VAR) 
{ 
#define MEP ((AT_MAP*)(U->long1)) 
 
  typedef struct { 
    long  long1; 
    YT_BOOL begin; 
    int   beg; 
    int  id_call; 
  } YT_USR; 
 
  AT_PLANER *pl; 
  int   j; 
  static YT_RECT  *r; 
 
  begin_end ((int*)&MDATA, &(U->beg)); 
 
  switch (message) { 
  case YCREATE: 
    U_MALLOC; 
    U->long1 = YGet("wlong1"); 
 
   /*  OUTS (MEP->name); */ 
    WND->name = MEP->name; 
     
    for (pl = MEP->plan; pl->mod_id != mid_END; pl++) { 
      /*  if (!YStrCmp(pl->proc_name, ""))  */ 
      if (pl->type == YMAP) 
	pl->proc = MAP; 
      else 
	pl->proc = YProcByName (pl->proc_name); 
      YWndCreate (&(pl->id_new), pl->proc, pl->name, pl->long1, 0, 0, 0);  /*!!!!!*/ 
    } 
    U->beg   = 0; 
    U->begin = FALSE; 
    break; 
 
  case YGETSIZE: 
    MYSIZE_IS (W_MOD, H_MOD); 
    break; 
  case YOPEN: 
  case YDRAW: 
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color); 
    YAlgDrawMap (id, (void*)(U->long1)); 
    break; 
/*   case YLMOUSEDOWN: */ 
/*     OUTS("YLMOUSEDOWN-MAP"); */ 
/*     break; */ 
  case YKEYWORD0: 
    YDrawString ((char*)mes3, mes1, mes2, YColor("black")); 
    break; 
  case YKEYWORD1: 
    YDrawLine (mes1, mes2, mes3, mes4, YColor("black")); 
    break; 
  case YKEYWORD2: 
    r = (YT_RECT*) mes3; 
    YWnd (Ph(), MODPUSH, (char*)mes4, r->x,r->y, r->w,r->h, mes1,0,0,0, CLR_DEF); 
    break; 
  case YCLOSE: 
    YWndClean (id); 
    break; 
 
  case YOUTPUT: 
    { 
    AT_OUTPUT *pot = (AT_OUTPUT *) mes3; 
    AT_MAP *map = MEP; 
 
    if (!YAlgPlanering(map->plan, pot->id_from, pot->how, pot->message,    
		       pot->mes1, pot->mes2, pot->mes3, pot->mes4)) { 
      pot->id_from = id; 
      YSend (WND->parent_c, message, mes1, mes2, mes3, mes4);  
    } 
    break; 
    } 
  case MM_BEGIN: 
    U->begin = TRUE; 
    break; 
  case MM_END: 
    YAlgCall (U->id_call, YPOST2FACE, MM_END,  0, 0, 0, (long)PDATA); 
    break; 
  default: 
   /*  if (from != ID_BACK) break; */ 
    MM_ONLY; 
 
    for (pl=MEP->plan; pl->mod_id!=mid_END; pl++)  
    for (j=0; j<NUM_FORMES; j++) { 
      if (YStrCmp(pl->forphr[j], "")) continue; 
      if ( YGet (pl->forphr[j]) == MDATA ) { 
 
	U->id_call = YAlgPlanId (MEP->plan, pl->mod_id); 
	 
	if (U->begin) { 
	  YAlgCall (U->id_call, YPOST2FACE, MM_BEGIN,  0, 0, 0, (long)PDATA); 
	  U->begin = FALSE; 
	} 
 
	if  (MM_FORWARD) YAlgCall (U->id_call, YPOST2FACE,  message, mes1, mes2, mes3, mes4);  
	else             YAlgCall (U->id_call, YPOST2BACK,  message, mes1, mes2, mes3, mes4); 
 
	break; 
      } 
    } 
 
    if  (MM_FORWARD) YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);  
    else             YAlgOut (YSEND2BACK, message,  mes1, mes2, mes3, mes4);  
    break; 
  } 
 
  RETURN_TRUE; 
#undef MEP 
} 
/*------------------------------VParSetOne----------------------------------*/ 
YT_BOOL 
VParSetOne (char *type, char *value, void *pdata) 
{ 
 int     decimal; 
 
 if      (YStrCmp (type,"int"))      *((int*)pdata)      = atoi (value); 
 else if (YStrCmp (type,"float"))    *((float*)pdata)    = atof (value); 
 else if (YStrCmp (type,"double"))   *((double*)pdata)   = atof (value); 
 else if (YStrCmp (type,"space"))    *((YT_SPACE*)pdata) = atof (value); 
 else if (YStrCmp (type,"bool")) { 
   if      (YStrCmp (value, "TRUE"))   decimal = 1; 
   else if (YStrCmp (value, "FALSE"))  decimal = 0; 
   else    { 
     YWarning ("VParSet-bool"); 
     return (FALSE); 
   } 
   *((int *) pdata) = decimal; 
 } 
 else if (YStrCmp(type,"string"))   strcpy ((char*)pdata,value); 
  
 return (TRUE); 
} 
/*------------------------------VParSetNew------------------------------------*/ 
YT_BOOL 
VParSetNew (VT_PARS *pars, char *name_set, void *pdata) 
{ 
 VT_PARS  *par; 
 
 for (par=pars; (par->type!=NULL); par++) { 
   if (YStrCmp(par->name, name_set)) break; 
 } 
 if (par->type == NULL)  
   return (FALSE); 
 
 VParSetOne (par->type, par->value, pdata); 
  
 return (TRUE); 
} 
/*---------------------------YAlgDrawMap------------------------------------*/ 
void 
YAlgDrawMap (int id_map, void *map) 
{ 
  int     x1, y1, x2, y2; 
  int     mid, i, j, k; 
  int     x0 = 0, y0 = 0; 
  AT_PLANER *p = ((AT_MAP*)map)->plan; 
  AT_PLANER *pl; 
  static YT_RECT  rect; 
  AT_TEXT  *tt; 
 
  for (i = 0; (p + i)->mod_id != mid_END; i++) { 
    x1 = x0 + (p + i)->cx; 
    y1 = y0 + (p + i)->cy; 
    for (k = 0; k < NUM_MID; k++) { 
      mid = (p + i)->mid[k]; 
      if (mid == mid_OUT) continue; 
      if (mid) { 
	for (j = 0; (p + j)->mod_id != mid; j++) ;; 
 
	x2 = x0 + (p + j)->cx; 
	y2 = y0 + (p + j)->cy; 
 
	YSend (id_map, YKEYWORD1, x1, y1, x2, y2); 
      } 
    } 
  } 
 
  x0 = 0; 
  y0 = 0; 
  for (pl = p; pl->mod_id != mid_END; pl++) { 
    rect.w = pl->w; 
    rect.h = pl->h; 
    rect.x = x0 + pl->cx - rect.w / 2; 
    rect.y = y0 + pl->cy - rect.h / 2; 
    YSend (id_map, YKEYWORD2, pl->id_new, 0, LP(rect), (long)(pl->name)); 
  } 
 
  for (tt = ((AT_MAP*)map)->text; tt->txt != NULL ; tt++)  
    YSend (id_map, YKEYWORD0, tt->x, tt->y, (long)(tt->txt), 0); 
   
  return; 
} 
/*-----------------------------------MODLIST---------------------------------*/ 
long 
MODLIST (PFUNC_VAR) 
{ 
#define NUM_ITEM 10 
  static int horz, x0, w_push, w_text, h_all; 
 
  static int  hText, hPush1, hPush2, hPush3, hPush4, hPush5; 
  static char str[100]; 
  static int  cur_item, new_item; 
  static int  mItem[NUM_ITEM]; 
  static int  hItem; 
  static char start_name[100]; 
 
  int     first; 
  YT_COLOR color = YColor ("teal");  
 
  char *root_name, *cur_name; 
 
  switch (message) { 
  case YGETSIZE: 
    MYSIZE_IS (W_MOD, H_MOD + 20); 
    break; 
  case YOPEN: 
    YSet ("modlist", id); 
 
    cur_item = new_item = 0; 
    first = ID_NULL; 
    hItem = ID_NULL; 
    strcpy (str, ""); 
 
    strcpy (start_name, (char*) YGet("wlong1")); 
    YParseStartName (start_name, &root_name, &cur_name); 
    /* fprintf (Y_STDERR, "%s %s %s \n", start_name, root_name, cur_name); */ 
 
    first = YAdirRootSet (root_name); 
    mItem[cur_item] = first; 
 
    new_item = cur_item + 1; 
    mItem[new_item] = YAdirTo (cur_name); 
 
  case YDRAW: 
    horz   = H_CAPTION; 
    h_all  = horz - 1; 
    w_text = 95; 
    w_push = (WND->w - w_text-5) / 5; 
    x0 = 1; 
 
    YWnd (&hPush4, PUSH, /* "Menu" */"Exit",  x0,1, w_push,h_all, 0,0,0,0, CLR_DEF); 
    x0 += (w_push + 1); 
    YWnd (&hPush3, PUSH, "Begin", x0,1, w_push,h_all, 0,0,0,0, CLR_DEF); 
    x0 += (w_push + 1); 
    YWnd (&hPush1, PUSH, "..",    x0,1, w_push,h_all, 0,0,0,0, CLR_DEF); 
    x0 += (w_push + 1); 
    YWnd (&hText, YTEXT, "",      x0,1, w_text,h_all, (long)str,0,0,0, color); 
    x0 += (w_text); 
    YWnd (&hPush5, PUSH, "Stop",  x0,1, w_push,h_all, 0,0,0,0, CLR_DEF); 
    x0 += (w_push + 1); 
    YWnd (&hPush2, PUSH, "Go",    x0,1, WND->w-x0-1,h_all, 0,0,0,0, CLR_DEF); 
 
    YDrawRectB (0, 0, WND->w, WND->h, YColor("black")); 
    YDrawLine  (0, horz, WND->w, horz,   YColor("black")); 
 
    YGoto (YDRAWITEM, 0, 0, 0, 0); 
    break; 
  case YDRAWITEM: 
/*     if (!YGet("second_draw")) { */ 
    if (!SECOND_DRAW) { 
      /* OUTD(hItem); */ 
      YWndClose (hItem);  
    } 
 
    cur_item = new_item; 
    hItem = mItem[cur_item]; 
 
    YWndOpen (hItem, 1,horz+1, WND->w-2,WND->h-horz-2, color); 
 
    strcpy (str, WNDI(hItem)->name); 
    YWndUpdate (hText); 
    break; 
  case YADD: 
    new_item = cur_item + 1; 
    if (new_item >= NUM_ITEM) 
      YError ("NUM_ITEM"); 
    mItem[new_item] = mes3; 
    YGoto (YDRAWITEM, 0, 0, 0, 0); 
    break; 
  case YPUSH: 
    if      (mes1 == hPush4)  YExit (FALSE); /* YBeep(); */ 
    else if (mes1 == hPush3)  YGoto (YBEGIN, 0, 0, 0, 0); 
    else if (mes1 == hPush1)  YGoto (YBACK, 0, 0, 0, 0); 
    else if (mes1 == hPush5)  ALGO->stop_flag = TRUE; 
    else if (mes1 == hPush2)  YGoto (YGO, 0, 0, 0, 0); 
    break; 
  case YBEGIN: 
    new_item = 0; 
    YGoto (YDRAWITEM, 0, 0, 0, 0); 
    break; 
  case YBACK: 
    if (cur_item == 0) 
      break; 
    new_item = cur_item - 1; 
    YGoto (YDRAWITEM, 0, 0, 0, 0); 
    break; 
  case YGO: 
    YAlgGo (mItem[cur_item]); 
    break; 
  case YCLOSE: 
    YAdirRootDel (); 
    YWndClean (id); 
    break; 
  default:;;; 
  } 
 
  RETURN_TRUE; 
} 
/*-----------------------------MODPUSH--------------------------------------*/ 
long 
MODPUSH (PFUNC_VAR) 
{ 
  typedef struct { 
    int   mid; 
  } YT_USR; 
 
  switch (message) { 
  case YOPEN: 
    U_MALLOC; 
    U->mid = (int) YGet("wlong1"); 
  case YDRAW: 
    YDrawRectB (0, 0, WND->w, WND->h, YColor("black")); 
    YWnd (Ph(), PUSH, WNDI(U->mid)->name, 1,1, WND->w-2,WND->h-2, 0,0,0,0, CLR_DEF); 
    break; 
  case YPUSH: 
    YSend (YGet ("modlist"), YADD, 0, 0, U->mid, 0);  
    break; 
  case YRPUSH: 
    YAlgGo (U->mid); 
    break; 
  case YCLOSE: 
    YWndClean (id); 
    break; 
  default:;; 
  } 
 
  RETURN_TRUE; 
} 
/*----------------------------mKran-----------------------------------------*/ 
long 
mKran (PFUNC_VAR) 
{ 
  typedef struct { 
    ABCD; 
  } YT_USR; 
 
  char   *text[] = 
  { 
    "The module 'Kran' passes all messages ", 
    "in both parties, anything not doing.",  
    "The basic assignment - design.",  
    NULL 
  }; 
 
  switch (message) { 
  case YCREATE: 
    U_MALLOC; 
    WND->name = ""; 
    break; 
  case YGETSIZE: 
    MYSIZE_IS (W_MOD, H_MOD); 
    break; 
  case YOPEN: 
  case YDRAW: 
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color); 
    YDrawStrings (text, 20, 40); 
    YDrawLogo ("Ylib_sv",70, 100, 140, 100); 
    break; 
  case YCLOSE: 
    YWndClean (id); 
    break; 
  default: 
    if      (from == ID_BACK) { 
      YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4); 
    }  
    else if (from == ID_FACE) { 
      YAlgOut (YSEND2BACK, message,  mes1, mes2, mes3, mes4); 
    } 
  } 
 
  RETURN_TRUE; 
} 
/*----------------------------mStop-----------------------------------------*/ 
long 
mStop (PFUNC_VAR) 
{ 
  typedef struct { 
    ABCD; 
  } YT_USR; 
 
  static YT_BOOL flag = TRUE; 
 
  switch (message) { 
  case YCREATE: 
    U_MALLOC; 
    WND->name = ""; 
    break; 
  case YOPEN: 
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color); 
    YDrawString ("This is Stop:", 10, 20, YColor("black")); 
    break; 
  case YCLOSE: 
    YWndClean (id); 
    break; 
  default: 
    if      (MM_FORWARD) { 
      if   (flag) YAlgOut (YSEND2FACE, message,  MM_NONE, 0, 0, 0); 
      else        YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4); 
    } 
    else if (MM_BACKWARD) { 
      if   (flag) YAlgOut (YSEND2BACK, message,  MM_NONE, 0, 0, 0); 
      else        YAlgOut (YSEND2BACK, message,  mes1, mes2, mes3, mes4); 
    } 
  } 
 
  RETURN_TRUE; 
} 
/*-----------------------------mControl---------------------------------------*/ 
long 
mControl (PFUNC_VAR) 
{ 
  char   *text[] = 
  { 
    "-----------------------------------", 
    "-----------------------------------", 
    NULL 
  }; 
  typedef struct { 
    int   rest, done, jump_w, b_point; 
    int   hRest, hDone, hJump, hJump_w;  
    long  pdata; 
  } YT_USR; 
 
  switch (message) { 
  case YCREATE: 
    U_MALLOC; 
    WND->name = "Contrl"; 
    U->rest    = 100; 
    U->done    =  0; 
    U->jump_w  =  1;  
    U->b_point = -1; 
    U->hRest = U->hDone = U->hJump = U->hJump_w = ID_NULL;  
    U->pdata = YNULL; 
    break; 
/*   case MM_FORWARD: */ 
/*     break; */ 
  case MM_DATA: 
    U->pdata = PDATA; 
    YGoto (YMAKE, 0, 0, 0, 0); 
    break; 
  case MM_APPLY: 
    YGoto (YMAKE, 0, 0, 0, 0); 
    break; 
  case YMAKE: 
    if (!U->pdata)    break; 
    if (U->rest <= 0) break; 
    if (U->done >= U->b_point && U->b_point != -1) { 
      U->b_point = -1; 
      break; 
    } 
    U->rest--; 
    YWndUpdate (U->hRest); 
    U->done++; 
    YWndUpdate (U->hDone); 
    YAlgOut (YSEND2FACE, MM_DATA,  /* MM_DATA */0, 0, 0, U->pdata); 
    break; 
  case YPUSH: 
    if (mes1==U->hJump)  
      U->b_point = U->done + U->jump_w; 
    
    YGoto (YMAKE, 0, 0, 0, 0); 
    break; 
  case YDECIMAL: 
    if  (mes1==U->hRest)   
      YGoto (YMAKE, 0, 0, 0, 0); 
    break; 
  case YGETSIZE: 
    MYSIZE_IS (W_MOD, H_MOD); 
    break; 
  case YOPEN: 
  case YDRAW: 
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color); 
    YDrawStrings (text, 30, 30); 
 
    YBeginGroup("Info", 10,80, 140,80, YColor("")); 
    YWnd (&U->hRest,  DECIMAL, "rest = ",  70,15, 50,20, 0,0,10000,LP(U->rest), CLR_DEF); 
    YWnd (&U->hDone,  DECIMAL, "done = ",  70,40, 50,20, 0,0,10000,LP(U->done), CLR_DEF); 
    YEndGroup(); 
 
    YBeginGroup("Jump", 160,80, 150,80, YColor("")); 
    YWnd (&U->hJump_w, DECIMAL, "W = ",      60,15,  50,20, 0,0,10000,LP(U->jump_w), CLR_DEF); 
    YWnd (&U->hJump,   PUSH,    "Jump by W", 20,40, 110,20, 0,0,0,0, CLR_DEF); 
    YEndGroup(); 
 
    break; 
  case YCLOSE: 
    YWndClean (id); 
    break; 
  default: ;;; 
  } 
 
  RETURN_TRUE; 
} 
/*------------------------------mDitto---------------------------------------*/ 
long 
mDitto (PFUNC_VAR) 
{ 
  typedef struct { 
    ABCD; 
  } YT_USR; 
  char   *text[] = 
  { 
    "DITTO  DITTO  DITTO  DITTO  DITTO", 
    "DITTO  DITTO  DITTO  DITTO  DITTO", 
    "DITTO  DITTO  DITTO  DITTO  DITTO", 
    "DITTO  DITTO  DITTO  DITTO  DITTO", 
    "DITTO  DITTO  DITTO  DITTO  DITTO", 
    "DITTO  DITTO  DITTO  DITTO  DITTO", 
    NULL 
  }; 
 
  switch (message) { 
  case YCREATE: 
    U_MALLOC; 
    WND->name = "Ditto"; 
    break; 
/*   case MM_FORWARD: */ 
/*     break; */ 
  case MM_APPLY: 
    break; 
  case YOPEN: 
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color); 
    YDrawStrings (text, 50, 80); 
    break; 
  case YCLOSE: 
    YWndClean (id); 
    break; 
  default: ;;; 
  } 
 
  RETURN_TRUE; 
} 
/*-----------------------------mTest-----------------------------------*/ 
long 
mTest (PFUNC_VAR) 
{ 
  enum words { 
    YMAKE = YKEY_LOCALS 
  }; 
 
  typedef struct { 
    char numer[15]; 
    char name[80]; 
    /* char name2[80]; */ 
  } YT_USR; 
 
  static VT_PARS pars[] = { 
    {"string",  "name",  "inModule"},  
/*     {"string",  "name2",  "name2_var1:"}, */ 
    {NULL}}; 
 
  long  i, j; 
  static long jj;  
  char  rab_string[80]; 
 
  static int num=0; 
 
  switch (message) { 
  case YCREATE: 
    U_MALLOC; 
    WND->name = "mTest"; 
 
    PAR_INIT ("name", U->name); 
    /* PAR_INIT ("name2", U->name2); */ 
 
    jj = 50000; 
    num++; 
    if (num == 1) strcpy (U->numer, "one"); 
    if (num == 2) strcpy (U->numer, "two"); 
    if (num == 3) strcpy (U->numer, "three"); 
    if (num == 4) strcpy (U->numer, "four"); 
    if (num == 5) strcpy (U->numer, "five"); 
    break; 
  case MM_APPLY:  
  case MM_DATA:  
    YGoto (YMAKE, 0,0,0, 0); 
    YAlgOut (YSEND2FACE, MM_DATA,  0, 0, 0, 0); 
    break; 
  case MM_BEGIN:  
    fprintf (Y_STDERR, "\n -------------BEGIN-------------- \n"); 
    break; 
  case MM_END:  
    fprintf (Y_STDERR, "\n -------------FINAL-------------- \n"); 
    break; 
  case YMAKE: 
    fprintf (Y_STDERR, "%s %s  ", U->name, WND->name); 
    for (i = 1; i <= 10; i++) {  
      fprintf (Y_STDERR, "."); 
      for (j = 1; j <= jj; j++) { 
	sqrt (1.1 * 5.5);  
      } 
    } 
    fprintf (Y_STDERR, "\n"); 
    break; 
  case YGETSIZE: 
    MYSIZE_IS (W_MOD, H_MOD); 
    break; 
  case YOPEN: 
  case YDRAW: 
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color); 
 
    sprintf (rab_string, "This is module mTest, numer = %s", U->numer); 
    YDrawString (rab_string, 40, 50, YColor("white")); 
 
    YDrawLogo ("[ALGO]",  100, 80, 120,120); 
    break; 
  case YCLOSE: 
    YWndClean (id); 
    break; 
  default: ;;;  
  } 
 
  RETURN_TRUE; 
} 
/*-------------------------------YAlgLoadTest-----------------------------*/ 
void   
YAlgLoadTest () 
{ 
  AT_PNAME1 pnames[] = { 
    { "mTest",    mTest},  
    { NULL } 
  };  
 
  char *all[] = { 
    "@PARS pars_test", 
    "string  name  inPkg:",  
    "@MAP  D_kernel", 
    "40 40 | ..................................", 
    "40 55 | ..................................", 
    "40 70 | ..................................", 
 
    "@MAP_plan   ", 
    " 10 YMOD mTest NULL       80 130 WFU HFU  1 | 20 |  MM_APPLY", 
    " 20 YMOD mTest NULL      160 130 WFU HFU  2 | 30 |          ", 
     "#----comment----------", 
   " 30 YMOD mTest pars_test  240 130 WFU HFU  3 |    |          ", 
 
    "@OPEN  D_kernel", 
    NULL}; 
 
 
  YSetPnames (pnames); 
  YAlgReadAll (all); 
 
  return; 
} 
/*------------------------------------------------------------------------*/ 
 
#endif 
 
/*******************************************************************************/ 
/*=============================================================================*/
/*      sgames.c                                                               */
/*                                                                             */
/*      SciGames SciGames SciGames SciGames SciGames SciGames SciGames         */
/*                                                                             */
/*                         All Rights Reserved                                 */
/*                                                                             */
/*=============================================================================*/

/* #ifdef  D_SGAMES_NEW */
/* #define D_SGAMES_OLD */
/* #endif */

/* #if defined(D_SGAMES_OLD) */
#if defined(D_SGAMES)
/*******************************************************************************/

#include "dia-y_zone.h" 
#include "dia-algols.h" 

/*******************************************************************************/

enum ykeys_secret {
  SECRET_BEGIN = YKEY_LEVEL5, 
    
  MM_CELLS_SIZE, MM_CELLS_INIT, MM_CELLS_DRAW_BEGIN, MM_CELLS_DRAW_ONE, 
  MM_CELLS_DRAW_END, MM_HCONSOLE,

  SECRET_END 
};                                                                              

typedef struct {
  int  ii, jj;
  int  *cells;
} VT_CELLS;

long     mCells(PFUNC_PAR);
long     mConsole (PFUNC_PAR);

/* typedef struct { */
/*   int  i, j; */
/*   int  cell; */
/*   int  min, max; */
/* } YT_CELLES; */

/* It's part must bu move to library Svisor for common use !!!!!! */

/****************************************************************************/

int  hConsole;

long     info_proc (PFUNC_PAR);
long     console_proc (PFUNC_PAR);
long     scigames_proc (PFUNC_PAR);

long     mMbrot (PFUNC_PAR);
long     mLife   (PFUNC_PAR);
long     mGoldex (PFUNC_PAR);
long     mDemon (PFUNC_PAR);
long     mRects (PFUNC_PAR);
long     mBiomor (PFUNC_PAR);

long     mSelect (PFUNC_PAR);

/*=========================================================================*/



/*=========================================================================*/
enum keys {
  YDECART, YPOLAR, YCONST, YRAND 
};

typedef struct {
  int   type;
  float v1;
  float v2;
} YT_COMPL;

YT_COMPL *YComplSet (YT_COMPL *c, int type, float v1, float v2);
YT_COMPL *YComplEqv (YT_COMPL *left, YT_COMPL *right);
YT_COMPL *YComplAB (YT_COMPL *c);
YT_COMPL *YComplRF (YT_COMPL *c);
float     YComplMod (YT_COMPL *c);
YT_COMPL *YComplSum (YT_COMPL *c1, YT_COMPL *c2);
YT_COMPL *YComplSub (YT_COMPL *c1, YT_COMPL *c2);
YT_COMPL *YComplMult (YT_COMPL *c1, YT_COMPL *c2);
YT_COMPL *YComplDev (YT_COMPL *c1, YT_COMPL *c2);
YT_COMPL *YComplPowN (YT_COMPL *c, int n);
YT_COMPL *YComplPowZ (YT_COMPL *c, YT_COMPL *z);
YT_COMPL *YComplSin (YT_COMPL *c);
YT_COMPL *YComplCos (YT_COMPL *c);
YT_COMPL *YComplExp (YT_COMPL *c);
YT_COMPL *YComplLog (YT_COMPL *c);


/*-------------------------------YComplSet---------------------------------*/
YT_COMPL *
YComplSet (YT_COMPL *c, int type, float v1, float v2)
{

  c->type = type;
  c->v1   = v1;
  c->v2   = v2;

  return (c);
}
/*-------------------------------YComplEqv---------------------------------*/
YT_COMPL *
YComplEqv (YT_COMPL *left, YT_COMPL *right)
{

  left->type = right->type;
  left->v1   = right->v1;
  left->v2   = right->v2;

  return (left);
}
/*-------------------------------YComplAB----------------------------------*/
YT_COMPL *
YComplAB (YT_COMPL *c)
{
  float  a, b, r, f;

  if (c->type == YDECART) return (c);

  r = c->v1;
  f = c->v2;
  a = r * cos (f);
  b = r * sin (f);

  c->type = YDECART;
  c->v1   = a;
  c->v2   = b;

  return (c);
}
/*-------------------------------YComplRF----------------------------------*/
YT_COMPL *
YComplRF (YT_COMPL *c)
{
  float  a, b, r, f;

  if (c->type == YPOLAR) return (c);

  a = c->v1;
  b = c->v2;
  r = sqrt (a*a + b*b);
  f = atan (b/a);

  c->type = YPOLAR;
  c->v1   = r;
  c->v2   = f;

  return (c);
}
/*-------------------------------YComplMod---------------------------------*/
float
YComplMod (YT_COMPL *c)
{
  
  YComplRF (c);

  return (c->v1);
}
/*-------------------------------YComplSum---------------------------------*/
YT_COMPL *
YComplSum (YT_COMPL *c1, YT_COMPL *c2)
{
  static YT_COMPL sum; 

  YComplAB (c1);
  YComplAB (c2);

  YComplSet (&sum, YDECART, c1->v1 + c2->v1, c1->v2 + c2->v2); 

  return (&sum);
}
/*-------------------------------YComplSub---------------------------------*/
YT_COMPL *
YComplSub (YT_COMPL *c1, YT_COMPL *c2)
{
  static YT_COMPL sub; 

  YComplAB (c1);
  YComplAB (c2);

  YComplSet (&sub, YDECART, c1->v1 - c2->v1, c1->v2 - c2->v2); 

  return (&sub);
}
/*-------------------------------YComplMult--------------------------------*/
YT_COMPL *
YComplMult (YT_COMPL *c1, YT_COMPL *c2)
{
  static YT_COMPL  mult; 
  float a1, b1, a2, b2;

  YComplAB (c1);
  YComplAB (c2);

  a1 = c1->v1;
  b1 = c1->v2;
  a2 = c2->v1;
  b2 = c2->v2;

  YComplSet (&mult, YDECART, a1*a2-b1*b2, b1*a2+a1*b2); 

  return (&mult);
}
/*-------------------------------YComplDev----------------------------------*/
YT_COMPL *
YComplDev (YT_COMPL *c1, YT_COMPL *c2)
{
  static YT_COMPL  dev; 
  float r1, f1, r2, f2;

  YComplRF (c1);
  YComplRF (c2);

  r1 = c1->v1;
  f1 = c1->v2;
  r2 = c2->v1;
  f2 = c2->v2;

  YComplSet (&dev, YPOLAR, r1/r2, f1-f2); 

  return (&dev);
}
/*-------------------------------YComplPowN--------------------------------*/
YT_COMPL *
YComplPowN (YT_COMPL *c, int n)
{
  static YT_COMPL  rez; 

  YComplRF (c);

  /* YComplSet (&rez, YPOLAR, powf (c->v1, (float)n), n * (c->v2));  */
  YComplSet (&rez, YPOLAR, pow (c->v1, (float)n), n * (c->v2)); 

  return (&rez);
}
/*-------------------------------YComplPowZ--------------------------------*/
YT_COMPL *
YComplPowZ (YT_COMPL *c, YT_COMPL *z)
{

  return (YComplExp (YComplMult (z, YComplLog(c) ) ) );

}
/*-------------------------------YComplCos---------------------------------*/
YT_COMPL *
YComplCos (YT_COMPL *c)
{
  static YT_COMPL  rez; 
  float  x, y, ey;

  YComplAB (c);
  x = c->v1;
  y = c->v2;
  
  ey = exp(y);

  YComplSet (&rez, YDECART, 0.5*cos(x)*(ey-1/ey), 0.5*sin(x)*(1/ey-ey)); 

  return (&rez);
}
/*-------------------------------YComplSin---------------------------------*/
YT_COMPL *
YComplSin (YT_COMPL *c)
{
  static YT_COMPL  rez; 
  float  x, y, ey;

  YComplAB (c);
  x = c->v1;
  y = c->v2;
  
  ey = exp(y);

  YComplSet (&rez, YDECART, 0.5*sin(x)*(1/ey+ey), -0.5*cos(x)*(1/ey-ey)); 

  return (&rez);
}
/*--------------------------------YComplExp--------------------------------*/
YT_COMPL *
YComplExp (YT_COMPL *c)
{
  static YT_COMPL  rez; 

  YComplAB (c);

  YComplSet (&rez, YPOLAR, exp(c->v1), c->v2); 

  return (&rez);
}
/*-------------------------------YComplLog---------------------------------*/
YT_COMPL *
YComplLog (YT_COMPL *c)
{
  static YT_COMPL  rez; 

  YComplRF (c);

  YComplSet (&rez, YDECART, log(c->v1), c->v2); 

  return (&rez);
}
/****************************************************************************/



/*-------------------------------SetPkgSgames------------------------------*/
void  
SetPkgSgames ()
{  

  AT_PNAME1 pnames[] = {
    { "mConsole",  mConsole },   
    { "mMbrot",    mMbrot   },   
    { "mCells",    mCells   },   
    { "mLife",     mLife    },   
    { "mBiomor",   mBiomor  },   
    { "mGoldex",   mGoldex  },   
    { "mDemon",    mDemon   },   
    { "mRects",    mRects   },   

    { "mSelect",   mSelect  }, 
    { NULL }
  }; 


  static AT_TEXT txt_newmap[] = {
   {".......NewMap....NewMap........", 25, 20},
   {".......NewMap....NewMap........", 25, 40}, 
   {".......NewMap....NewMap........", 25, 60}, 
   {NULL}};
  static AT_PLANER pln_newmap[] = {
    { 1, YMAP, "Popular",     NULL,   60, 140, 80, 100,  NULL, {0} },
    { 2, YMAP, "Scienty",     NULL,  160, 140, 80, 100,  NULL, {0} },
    { 3, YMAP, "Godesty",     NULL,  260, 140, 80, 100,  NULL, {0} },
    {mid_END}};
  static AT_MAP newmap = {"NewMap", &pln_newmap[0], &txt_newmap[0]};


  static AT_TEXT txt_popmap[] = {
   {".......f.............", 25, 20},
   {".....d...............", 25, 40}, 
   {NULL}};
  static AT_PLANER pln_popmap[] = {
    { 1, YMOD, "mMbrot",   NULL,  70,  80, WFU,HFU, NULL, {88}, },
    { 2, YMOD, "mBiomor",  NULL,  70, 110, WFU,HFU, NULL, {88}, {"MM_APPLY"}},
    { 3, YMOD, "mDemon",   NULL,  70, 140, WFU,HFU, NULL, {88}, },
    { 4, YMOD, "mLife",    NULL,  70, 170, WFU,HFU, NULL, {88}, },

    {88, YMOD, "mCells",   NULL, 135, 140,  50,  50,  NULL, {99} },
    {99, YMOD, "mConsole", NULL, 205, 140,  50,  90,  NULL, {0}  },

    { 5, YMOD, "mRects",   NULL,  275, 110, WFU,HFU, NULL, {99}, },
    { 6, YMOD, "mGoldex",  NULL,  275, 140, WFU,HFU, NULL, {99}, },
    {mid_END}};
  static AT_MAP popmap = {"Popular", &pln_popmap[0], &txt_popmap[0]};

  static AT_TEXT txt_scimap[] = {
   {".......f.............", 25, 20},
   {".....d...............", 25, 40}, 
   {NULL}};
  static AT_PLANER pln_scimap[] = {
    { 1, YMOD, "mSelect",  NULL,  70, 140, WFU,HFU, NULL, {88}, },

    {88, YMOD, "mCells",   NULL, 135, 140,  50,  50,  NULL, {99} },
    {99, YMOD, "mConsole", NULL, 205, 140,  50,  90,  NULL, {0}  },

    {mid_END}};
  static AT_MAP scimap = {"Scienty", &pln_scimap[0], &txt_scimap[0]};

  static AT_TEXT txt_godmap[] = {
   {".........Godesty...........", 25, 20},
   {".........Godesty...........", 25, 40}, 
   {NULL}};
  static AT_PLANER pln_godmap[] = {
    {mid_END}};
  static AT_MAP godmap = {"Godesty", &pln_godmap[0], &txt_godmap[0]};


  YSetPnames (pnames);
  YSet ("MM_HCONSOLE", MM_HCONSOLE);

  YAlgSetNewMap (&popmap);
  YAlgSetNewMap (&scimap);
  YAlgSetNewMap (&godmap);
  YAlgSetNewMap (&newmap);

  return;
}
/*-------------------------------MAIN---------------------------------------*/
long
MAIN (PFUNC_VAR)
{
  /* char  *adir_name = "Main map"; */
  char  *adir_name = "NewMap";

  switch (message) {
  case YCREATE:  
    /* YInitDRAW (); */
    YInitWIND ();    
    YInitALGO ();    

    SetPkgSgames ();
    YAlgResolve ();

    YBigWindow (NULL, scigames_proc, "Sci-Games (Recreational and Educational Computing)", 
		0,0, 0,0, (long)adir_name, 0, 0,0, CLR_DEF); 
    break;  
  case YFINAL:
    YFinalYlib ();
    break; 
  default:  ;;
  }

  id++;
  RETURN_TRUE;
}
/*---------------------------------scigames_proc---------------------------------*/
long
scigames_proc (PFUNC_VAR)
{
  static long  adir_name;
  static int  W, H;
  static int  info_x, info_y, info_w, info_h;
  static int  cons_x, cons_y, cons_w, cons_h;
  static int  modl_x, modl_y, modl_w, modl_h;
  static int  marg;

  switch (message) {
  case YGET:
    if (id == 1) return (      YLINER (YGet("wdisplay"), 640, 640, 1280, 800));
    if (id == 2) return (0.8 * YLINER (YGet("hdisplay"), 480, 480, 1024, 650));
  case YCREATE:
    break;
  case YOPEN:
    adir_name  = YGet("wlong1");
    marg = 10;
    W = WND->w;
    H = WND->h;
/*     modl_h = 1.3 * (H_MOD+20); */
/*     modl_w = 1.2 * (W_MOD); */
    modl_w = (W - 3*marg) / 2;
    modl_h = modl_w * (1.3*(H_MOD+20)/(1.2*W_MOD));

  case YDRAW:
    W = WND->w;
    H = WND->h;
  
    modl_x = marg;
    modl_y = (H - modl_h) - marg; 

    info_x = modl_x;
    info_y = marg;
    info_w = modl_w;
    info_h = H - modl_h - 3*marg;

    cons_x = marg + modl_w + marg;   
    cons_y = 10;   
    cons_w = W - cons_x - marg;
    cons_h = H - 2*marg;

    YDrawRectF (0, 0, W, H, YColor("yellow"));

    YWnd (Ph(), info_proc, "",  info_x, info_y, info_w, info_h,  adir_name, 0, 0, 0, CLR_DEF);

    YDrawRectB (cons_x, cons_y, cons_w, cons_h, YColor("black"));
    YWnd (&hConsole, console_proc, "",   cons_x+1, cons_y+1, cons_w-2, cons_h-2, 0, 0, 0, 0, CLR_DEF);

    YWnd (Ph(), MODLIST,   "",  modl_x, modl_y, modl_w, modl_h,  adir_name, 0, 0, 0, CLR_DEF);

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;;
  }

  RETURN_TRUE;
}
/*-------------------------------about_proc--------------------------------------*/
long
about_proc (PFUNC_VAR)
{

  char *str1 = "    Program Sci-Games     ";
  char *str2 = "       version 0.0        ";

  char *str3 = "    Copyright (c) 2000    ";
  char *str4 = "       Life Software.     ";
  char *str5 = "    All rights reserved.  ";
  int x, y;
  YT_COLOR clr_text = YColor("black");
  YT_COLOR clr_line = YColor("white");
  YT_COLOR clr_fill = YColor("lime");
  YT_COLOR clr_push = YColor("yellow");
  static int hPush;

  switch (message) {  
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, clr_fill);
    x = (WND->w - YStringW(str1))/2;  
    y = 30;
    YDrawString(str1, x, y,     clr_text);
    YDrawString(str2, x, y+=20, clr_text);
    YDrawRectF (30, y+=15, WND->w-60, 3, clr_line);
    YDrawString(str3, x, y+=20, clr_text);
    YDrawString(str4, x, y+=20, clr_text);
    YDrawString(str5, x, y+=20, clr_text);
    YDrawRectF (30, y+=15, WND->w-60, 3, clr_line);

    YWnd (&hPush, PUSH, "OK", WND->w/2-30,WND->h-40, 60, 20, 0,0,0,0, clr_push);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  case YPUSH:
    YDlgEnd (0);
    break;
  }

  RETURN_TRUE;
}
/*-----------------------------------logo_proc----------------------------------*/
long
logo_proc (PFUNC_VAR)
{

  switch (message) {
  case YCREATE:
    break;
  case YOPEN:
   /*  YSetTimer (id, 100); */
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, YColor("white"));
    YGoto (YDRAWITEM, 0, 0, 0, 0);
    break;
  case YTIMER:
  case YDRAWITEM:
    YDrawRectText ("SCI-GAMES", 0, 0, WND->w, WND->h, YColor("black"));
    break;
  case YLMOUSEDOWN:
    break;
  case YCLOSE:
    YKillTimer ();
    YWndClean (id);
    break;
  default: ;;;;
  }

  RETURN_TRUE;
}
/*-----------------------------------info_proc----------------------------------*/
long
info_proc (PFUNC_VAR)
{
  int  marg, push_w, push_h, push_y, lpush_x, rpush_x;
  static int hAbout, hHelp;

  switch (message) {
  case YCREATE:
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectFB (0, 0, WND->w, WND->h, YColor("white"), YColor("black"));

    marg   = 5;
    push_w = 80;
    push_y = marg;
    push_h = WND->h - 2*push_y;
    lpush_x = marg;
    rpush_x = WND->w-marg-push_w;

    YWnd (Ph(), logo_proc, "",  2*marg+push_w, push_y, WND->w-2*push_w-4*marg, push_h,  
	  0, 0, 0, 0, CLR_DEF);
    YWnd (&hAbout, PUSH, "ABOUT",   lpush_x, push_y, push_w, push_h, 0,0,0,0, CLR_DEF);
    YWnd (&hHelp,  PUSH, "HELP",    rpush_x, push_y, push_w, push_h, 0,0,0,0, CLR_DEF);
    break;
  case YPUSH:
    if      (FALSE) YBeep();
    else if (mes1 == hHelp)    YMessageBox ("Do you like beer?", "Yes_No");
    else if (mes1 == hAbout)   YDlg (about_proc, "ABOUT", 0,0,0,0, 0,0,0,0, CLR_DEF, TRUE); 
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;;
  }

  RETURN_TRUE;
}
/*---------------------------------console_proc-------------------------------*/
long
console_proc (PFUNC_VAR)
{

  switch (message) {
  case YCREATE:
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, YColor("green"));
    break;
  case YGETITEM:
    return (id);
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;;
  }

  RETURN_TRUE;
}
/*------------------------------mConsole---------------------------------------*/
long
mConsole (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;


  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Console";
    /* OUTD (hConsole); */
    YAlgOut (YPOST2BACK, MM_HCONSOLE,  hConsole, 0, 0, 0);
    break;
/*   case MM_HCONSOLE: */
/*     YAlgOut (YSEND2BACK, MM_HCONSOLE,  hConsole, 0, 0, 0); */
/*     break; */
  case MM_APPLY:
    break;
  case YOPEN:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*--------------------------------mCells-------------------------------------*/
long
mCells (PFUNC_VAR)
{
#define  DRAW_PIXS  0   
#define  DRAW_CMAP  1  
#define  MAKE_META  0
  typedef struct {
    ABCD;
  } YT_USR;

  enum keys {
    AAA = YKEY_LOCALS+1, DRAW_META  
  };

  static void *cmap;
  static void *meta;
  int  i, j/* , ii, jj */;
  int  cell;
  YT_COLOR color;
  int *p_ii, *p_jj;

  static int celles_ii, celles_jj; 

  static int hConsole;
  int  cellh;
  static int  cmin=0, cmax=10;
  static int mult  = 1;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Cells";
    if (!(cmap = YColmapCreate ())) YError ("Cells");
    meta = YMetaCreate (20);
    break;
  case MM_HCONSOLE:
    hConsole = mes1;
    break;
  case MM_APPLY:
  case MM_CELLS_INIT:
    if ((mes1 <= 0) || (mes2 <= 0)) YError ("CELLS_INIT");

    celles_ii = mes1;
    celles_jj = mes2;
    cmin = mes3;
    cmax = mes4;
    YColmapInit (cmap, celles_ii, celles_jj);
    break;
  case MM_CELLS_SIZE:
    p_ii = (int*)mes3;
    p_jj = (int*)mes4;
    *p_ii = WNDI(hConsole)->w;
    *p_jj = WNDI(hConsole)->h;
    return (TRUE);
  case MM_CELLS_DRAW_BEGIN:
    YMouseForm ("wait");
    break;
  case MM_CELLS_DRAW_ONE:
    i = mes1;  
    j = mes2;  
    cell = mes3;

    if ((cell < cmin) || (cell > cmax))  color = YColor ("black");
    else {
      cellh = YLINER (cell, cmin, 1, cmax, YGet("size_scale"));
      color = YScale (cellh - 1);
    }
    
    YColmapPut (cmap, i, j, color);
               
    if (DRAW_PIXS) {
      YDrawContext (TRUE, hConsole);
      YDrawPixel (i, j, color);
      YDrawContext (FALSE, ID_NULL);
    }
    break;
  case MM_CELLS_DRAW_END:
    if      (DRAW_CMAP) {
      YDrawContext (TRUE, hConsole);
      YDrawColmapB (cmap, 0, 0, mult*celles_ii, mult*celles_jj, YColor("black")); 
      YDrawContext (FALSE, ID_NULL);
    }
    else if (MAKE_META) {
      YMetaInit  (meta, 0, 0, celles_ii, celles_jj);
      YMetaBegin (meta, "");
      YDrawColmapB (cmap, 0, 0, celles_ii, celles_jj, YColor ("black"));
      YMetaEnd ();

      YDrawContext (TRUE, hConsole);
      YMetaToScr (meta,  0, 0, celles_ii, celles_jj, TRUE, YColor ("white"));
      YDrawContext (FALSE, ID_NULL);
    }
    YMouseForm ("arrow");
    break;
  case YOPEN:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
#undef  DRAW_PIXS 
#undef  DRAW_CMAP  
#undef  MAKE_META  
}
/*------------------------------mMbrot---------------------------------------*/
long
mMbrot (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  static int ii, jj, nn;
  static float  width, height;

  float a, b, x, y, x_old, y_old, x_step, y_step, x_min, y_min;
  int  i, j, n;

  static int h_cx, h_cy;
  static int hII, hJJ;

  static int pic, k_mult;
  static float  cx, cy;
  static char *name; 


  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Mbrot";
    pic = 1;

    if (pic == 1) { cx = -0.748;      cy = 0.1;        k_mult = 357;   name = "pavlin"; }
    if (pic == 2) { cx = -0.235125;   cy = 0.82722;    k_mult = 24800; name = "love chanal"; }
    if (pic == 3) { cx = -1.26446153; cy = 0.04396696; k_mult = 54000; name = ""; }  
    if (pic == 4) { cx =  0.31322;    cy = 0.75458;    k_mult = 368;   name = "ornament spiralej"; }

    ii = 100;
    jj = 100;
    nn = 100;
    
    break;
  case MM_APPLY:
  case YMAKE:
    width  = 1.0 / k_mult;
    height = 1.0 / k_mult;

    x_step = width / ii;
    y_step = height / jj;
/*     YGetData (h_cx); */
/*     YGetData (h_cy); */
    x_min = cx - width / 2;
    y_min = cy - height / 2;

    YAlgOut (YSEND2FACE, MM_CELLS_INIT,  ii, jj, 0, nn-1);
    name++;

    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_BEGIN,  0, 0, 0, 0);
    
    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      a = x_min + i * x_step;
      b = y_min + j * y_step;
      x_old = 0;
      y_old = 0;

      for (n = 0; n < nn; n++) {
	x = x_old*x_old - y_old*y_old + a;
	y = 2*x_old*y_old + b;
	if (x > 2 || x < -2 || y > 2 || y < -2) break;
	x_old = x;
	y_old = y;
      }

      YAlgOut (YSEND2FACE, MM_CELLS_DRAW_ONE,  i, j, n, 0);
    }
	
    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_END,  0, 0, 0, 0);

    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);

    YBeginGroup ("int_param", 10, 30, 140, 120, YColor(""));
    YWnd (Ph(), PUSH, "Full Size",    30, 15,  80, 20, 0, 0, 0, 0, CLR_DEF);
    YWnd (&hII, DECIMAL, "II : ",  70, 40, 40, 20,  0, 5, 1000, LP(ii), CLR_DEF);
    YWnd (&hJJ, DECIMAL, "JJ : ",  70, 65, 40, 20,  0, 5, 1000, LP(jj), CLR_DEF);
    YWnd (Ph(), DECIMAL, "NN : ",  70, 90, 40, 20,  0, 1,  10, LP(nn), CLR_DEF);
    YEndGroup ();

    YBeginGroup ("flo_param", 160, 30, 160, 100, YColor(""));
    YWnd (&h_cx, FLOATS, "cx  = ",    70, 15, 60, 20,  LP(cx), YFLOAT, 0, 0, CLR_DEF);
    YWnd (&h_cy, FLOATS, "cy  = ",    70, 40, 60, 20,  LP(cy), YFLOAT, 0, 0, CLR_DEF);
    YWnd (Ph(), DECIMAL, "k_mult: ",  70, 65, 60, 20,  0, 1, 1000, LP(k_mult), CLR_DEF);
    YEndGroup ();

    break;
  case YPUSH:
    YGoto (YGETITEM, 0, 0, 0, 0);
    YWndUpdate (hII);
    YWndUpdate (hJJ);
    break;
  case YGETITEM:
    YAlgOut (YSEND2FACE, MM_CELLS_SIZE,  0, 0, LP(ii), LP(jj));
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*---------------------------------mLife--------------------------------------*/
long
mLife (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  enum keys {
    MAKE_CELLS = YKEY_LOCALS+1
  };


  static int  *cells;
  static int  *cells_rab;
 /*  static int i_step = 0; */
  int     *ppp;
  int      i, j, r, sum;
  int      cell, new_cell;
  int      left, right, top, bottom;
  char    *text[] =
  {
    "Famous game  'Artificial Life'",
    "(play with more common rules):",
    NULL
  };
/*   static int nsteps, nsteps_min = 1, nsteps_max = 30000; */
  static int hII, hJJ;
  static int ii, ii_min = 5, ii_max = 1000;
  static int jj, jj_min = 5, jj_max = 1000;
  static YT_BOOL tabl[2][9] =
  {
    {0, 0, 0, 1, 0, 0, 0, 0, 0},  /* 0->1 */
    {1, 1, 0, 0, 1, 1, 1, 1, 1}	  /* 1->0 */
  };
  int  i0 = 30, j0 = 40;


  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Life";

    ii = 100;
    jj = 100;

    cells = cells_rab = NULL;
    break;
  case PROCESS_BEGIN:

    YAlgOut (YSEND2FACE, MM_CELLS_INIT,  ii, jj, 0, 1);


    if (!(YT_BOOL) YGoto (MAKE_CELLS, 0, 0, 0, 0))
      break;
    cells = cells;

    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_BEGIN,  0, 0, 0, 0);

    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      r = YRAND (0, 1000);
      if (r < 100) cell = 1;
      else         cell = 0;
      ARR2(cells, ii,jj, i,j) = cell;

      YAlgOut (YSEND2FACE, MM_CELLS_DRAW_ONE,  i, j, cell, 0);
    }

    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_END,  0, 0, 0, 0);

    break;
  case PROCESS_STEP:
    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_BEGIN,  0, 0, 0, 0);

    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      cell = ARR2(cells, ii,jj, i,j);
      left = j - 1;
      right = j + 1;
      top = i - 1;
      bottom = i + 1;
      if (left < 0)        left = jj - 1;
      if (right > jj - 1)  right = 0;
      if (top < 0)         top = ii - 1;
      if (bottom > ii - 1) bottom = 0;
      sum = ARR2(cells, ii,jj, top,left) +
	ARR2 (cells, ii,jj, top, j) +
	ARR2 (cells, ii,jj, top, right) +
	ARR2 (cells, ii,jj, i, left) +
	ARR2 (cells, ii,jj, i, right) +
	ARR2 (cells, ii,jj, bottom, left) +
	ARR2 (cells, ii,jj, bottom, j) +
	ARR2 (cells, ii,jj, bottom, right);
      
      if (tabl[cell][sum]) {
	new_cell = !cell;
	ARR2 (cells_rab, ii,jj, i,j) = new_cell;
	YAlgOut (YSEND2FACE, MM_CELLS_DRAW_ONE,  i, j, new_cell, 0);
      }
      else 
	ARR2 (cells_rab, ii,jj, i,j) = cell;

    }
    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_END,  0, 0, 0, 0);

    ppp = cells;
    cells = cells_rab;
    cells_rab = ppp;

    break;
  case PROCESS_END:
    free (cells);
    free (cells_rab);
    break;
  case MAKE_CELLS:
    if (YOVERFLOW ((ii) * (jj) * sizeof (int))) {
      YMessageBox ("Overflow!", "OK");
      return (FALSE);
    }
    if (!(cells = (int *) malloc ((ii) * (jj) * sizeof (int)))) {
      YMessageBox ("Not memory!", "OK");
      return (FALSE);
    }
    if (!(cells_rab = (int *) malloc ((ii) * (jj) * sizeof (int)))) {
      YMessageBox ("Not memory!", "OK");
      return (FALSE);
    }
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);
    YWnd (Ph(), PROCESS, "Process", 20, 55, 280, 50, id,0,0,0, CLR_DEF);

    YBeginGroup ("Params", 5,120, 100,90, YColor(""));
    YWnd (Ph(), PUSH, "Full Size",    10,i=10,  80,20, 0,0,0,0, CLR_DEF);
    YWnd (&hII, DECIMAL, "II : ",  50,i+=25, 40,20, 0,ii_min,ii_max,LP(ii), CLR_DEF);
    YWnd (&hJJ, DECIMAL, "JJ : ",  50,i+=25, 40,20, 0,jj_min,jj_max,LP(jj), CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Rules", 110,120, 205,75, YColor("")); 
    YDrawString ("Sum =", 5, i0 - 9, YColor("black"));
    YDrawString ("0->1",  5, i0 + 9, YColor("black"));
    YDrawString ("1->0", 5, i0 + 18 + 9, YColor("black"));
    for (j = 0; j <= 8; j++) {
      sprintf (Y_STR, "%d", j);
      YDrawString (Y_STR, j0 + 18 * j + 5, i0 - 9, YColor("black"));
      YWndGroupBegin (); 
      YWnd (Ph(), CHECK, "", j0+18*j,i0,    15,15, 0,LP(tabl[0][j]),0,0, CLR_DEF);
      YWnd (Ph(), CHECK, "", j0+18*j,i0+18, 15,15, 0,LP(tabl[1][j]),0,0, CLR_DEF);
      YWndGroupEnd ();
    }
    YEndGroup ();
    break;
  case YPUSH:
    YGoto (YGETITEM, 0, 0, 0, 0);
    YWndUpdate (hII);
    YWndUpdate (hJJ);
    break;
  case YGETITEM:
    YAlgOut (YSEND2FACE, MM_CELLS_SIZE,  0, 0, LP(ii), LP(jj));
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*------------------------------mBiomor---------------------------------------*/
long
mBiomor (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  static int ii, jj, nn, n_pow;
  int  i, j, n, cell;

  static float z_max, a_min, a_max, b_min, b_max, c_a, c_b;
  float        a_step, b_step, a, b, a_old, b_old, z_mod;

  static int h_z_max, h_a_min, h_a_max, h_b_min, h_b_max, h_c_a, h_c_b;

  static YT_BOOL form1, form2, form3, form4, form5;

  YT_COMPL  z, z_old, consta, /* zadd,  */test, rez;


  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Biomor";
    form1 = FALSE;
    form2 = TRUE;
    form3 = FALSE;
    form4 = FALSE;
    form5 = TRUE;
    n_pow = 3;
    ii = 100;
    jj = 100;
    nn = 10;
/*     a_min = -1.5; */
/*     a_max =  1.5; */
/*     b_min = -1.5; */
/*     b_max =  1.5; */
    a_min = -5;
    a_max =  5;
    b_min = -5;
    b_max =  5;
    z_max = 10;
    c_a = 0.1;
    c_b = 0.1;
    break;
  case MM_APPLY:
  case YMAKE:
    YComplSet (&test, YDECART, 2, 3);

    YComplEqv (&rez, YComplPowN(&test, 3));
    YComplAB  (&rez);

    OUTF (rez.v1);
    OUTF (rez.v2);

    /* ----------------------------------- */
    YGetData (h_a_min);
    YGetData (h_a_max);
    YGetData (h_b_min);
    YGetData (h_b_max);
    YGetData (h_z_max);
    YGetData (h_c_a);
    YGetData (h_c_b);
    YComplSet (&consta, YDECART, c_a, c_b);
    /* ----------------------------------- */

    YAlgOut (YSEND2FACE, MM_CELLS_INIT,  ii, jj, 0, 1);

    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_BEGIN,  0, 0, 0, 0);
    a_step = (a_max - a_min)/ii;
    b_step = (b_max - b_min)/jj;
    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      a_old = i * a_step + a_min;
      b_old = j * b_step + b_min;
      
      for (n = 0; n < nn; n++) {
	/*--------- calc new z ------------------*/

	YComplSet (&z_old,  YDECART, a_old, b_old);

	YComplSet (&z,  YDECART, 0, 0);
	if (form1) YComplEqv (&z, YComplSum(&z, YComplPowZ(&z_old, &z_old)));
	if (form2) YComplEqv (&z, YComplSum(&z, YComplPowN(&z_old, n_pow)));
	if (form3) YComplEqv (&z, YComplSum(&z, YComplSin (&z_old))); 
	if (form4) YComplEqv (&z, YComplSum(&z, YComplExp (&z_old))); 
	if (form5) YComplEqv (&z, YComplSum(&z, &consta));

	YComplAB (&z);
	a = z.v1;
	b = z.v2;

/* 	a = a_old*(a_old*a_old-3*b_old*b_old) + c_a; */
/* 	b = b_old*(3*a_old*a_old-b_old*b_old) + c_b; */

	/*----------------------------------------*/
	z_mod = sqrt (a*a + b*b);
	if (z_mod > z_max) break;
	
	a_old = a;
	b_old = b;
      }

      if (a < 10 || b < 10)  cell = 1;
      else                   cell = 0;
      
      YAlgOut (YSEND2FACE, MM_CELLS_DRAW_ONE,  i, j, cell, 0);
    }

    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_END,  0, 0, 0, 0);
    /* OUTD(222); */

    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    
    YBeginGroup ("int_param", 10, 30, 140, 100, YColor(""));
    YWnd (Ph(), DECIMAL, "II : ",  70, 15, 40, 20,  0, 5, 100, LP(ii), CLR_DEF);
    YWnd (Ph(), DECIMAL, "JJ : ",  70, 40, 40, 20,  0, 5, 100, LP(jj), CLR_DEF);
    YWnd (Ph(), DECIMAL, "NN : ",  70, 65, 40, 20,  0, 1,  10, LP(nn), CLR_DEF);
    YEndGroup ();

    YBeginGroup ("flo_param", 160, 30, 210, 100, YColor(""));
    YWnd (&h_a_min, FLOATS, "real : ",  70, 15, 60, 20,  LP(a_min), YFLOAT, 0, 0, CLR_DEF);
    YWnd (&h_a_max, FLOATS, "",        140, 15, 60, 20,  LP(a_max), YFLOAT, 0, 0, CLR_DEF);
    YWnd (&h_b_min, FLOATS, "imag : ",  70, 40, 60, 20,  LP(b_min), YFLOAT, 0, 0, CLR_DEF);
    YWnd (&h_b_max, FLOATS, "",        140, 40, 60, 20,  LP(b_max), YFLOAT, 0, 0, CLR_DEF);
    YWnd (&h_z_max, FLOATS, "zmax : ",  70, 65, 60, 20,  LP(z_max), YFLOAT, 0, 0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Formula", 40, 150, 180, 140, YColor(""));
    YWnd (Ph(), CHECK, "pow(z,z)",   15, 10, 20, 20,  0, LP(form1), 0, 0, CLR_DEF);
    YWnd (Ph(), CHECK, "pow(z,n) ,", 15, 35, 20, 20,  0, LP(form2), 0, 0, CLR_DEF);
    YWnd (Ph(), DECIMAL, "",        130, 35, 40, 20,  0, 1, 10, LP(n_pow), CLR_DEF);
    YWnd (Ph(), CHECK, "sin(z)",     15, 60, 20, 20,  0, LP(form3), 0, 0, CLR_DEF);
    YWnd (Ph(), CHECK, "exp(z)",     15, 85, 20, 20,  0, LP(form4), 0, 0, CLR_DEF);
    YWnd (Ph(), CHECK, "",           15,110, 20, 20,  0, LP(form5), 0, 0, CLR_DEF);
    YWnd (&h_c_a, FLOATS, "",          45,110, 45, 20,  LP(c_a), YFLOAT, 0, 0, CLR_DEF);
    YWnd (&h_c_b, FLOATS, "+i ",      120,110, 45, 20,  LP(c_b), YFLOAT, 0, 0, CLR_DEF);
    YEndGroup ();

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*-----------------------------mRects---------------------------------------*/
long
mRects (PFUNC_VAR)
{
  char   *text[] =
  {
    ".......................................",
    ".......................................",
    NULL
  };

  typedef struct {
    ABCD;
  } YT_USR;

  static int  X, Y, W, H, II, JJ;
  int i, j, w, h, x0, y0;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Rects";
    break;
  case MM_HCONSOLE: 
    hConsole = mes1;
    break;
  case MM_APPLY:
    X  = 20;
    Y  = 20;
    W  = 250;
    H  = 250;
    II = 6;
    JJ = 6;
    w = W / II; 
    h = H / JJ; 
    YDrawContext (TRUE, hConsole);
    YDrawRectF (X, Y, W, H, YColor ("white"));
    x0 = X;
    y0 = Y;
    for (i = 0; i < II; i++) {
      for (j = 0; j < JJ; j++) {
      if ((i+j)%2 == 0)  continue;
      YDrawRectF (x0 + j*w, y0, w, h, YColor ("black"));
      }
      y0 = y0 + h;
      YDrawLine (x0, y0, x0+W, y0, YColor ("aqua"));
      y0++;
    }
    YDrawContext (FALSE, ID_NULL);
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*-------------------------------goldex_proc--------------------------------------*/
long
goldex_proc (PFUNC_VAR)
{

  char *str1 = "    S_beg = 8 x 8  = 64   ";
  char *str2 = "    S_end = 5 x 13 = 65   ";

  char *str3 = "    You now make GOLD     ";
  char *str4 = "        from never !      ";
  char *str5 = "    It's fantastishion!   ";
  int x, y;
  YT_COLOR clr_text = YColor("black");
  YT_COLOR clr_line = YColor("white");
  YT_COLOR clr_fill = YColor("lime");
  YT_COLOR clr_push = YColor("yellow");
  static int hPush;

  switch (message) {  
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, clr_fill);
    x = (WND->w - YStringW(str1))/2;  
    y = 30;
    YDrawString(str1, x, y,     clr_text);
    YDrawString(str2, x, y+=20, clr_text);
    YDrawRectF (30, y+=15, WND->w-60, 3, clr_line);
    YDrawString(str3, x, y+=20, clr_text);
    YDrawString(str4, x, y+=20, clr_text);
    YDrawString(str5, x, y+=20, clr_text);
    YDrawRectF (30, y+=15, WND->w-60, 3, clr_line);

    YWnd (&hPush, PUSH, "OK", WND->w/2-30,WND->h-40, 60, 20, 0,0,0,0, clr_push);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  case YPUSH:
    YDlgEnd (0);
    break;
  }

  RETURN_TRUE;
}
/*-----------------------------mGoldex---------------------------------------*/
long
mGoldex (PFUNC_VAR)
{
  char   *text[] =
  {
    ".......................................",
    ".......................................",
    NULL
  };

  typedef struct {
    ABCD;
  } YT_USR;

  static int e = 15;
  int  x0, y0;
  static YT_COLOR black, white, yellow;
  static int h_p1, h_p2, h_p3, h_p4;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Goldex";
    black  = YColor ("black");
    white  = YColor ("white");
    yellow = YColor ("yellow");
    break;
  case MM_HCONSOLE: 
    hConsole = mes1;
    break;
  case MM_APPLY:
    YDrawContext (TRUE, hConsole);

    x0 = 5*e;
    y0 = 4*e;
    YDrawRectFB (x0, y0, 8*e, 8*e,  white, black);

    YDrawTriFB  (x0, y0, x0, y0+3*e, x0+8*e, y0+3*e,  yellow, black);
    YDrawTriFB  (x0, y0, x0+8*e, y0+3*e, x0+8*e, y0,  yellow, black);
    YDrawFourFB (x0, y0+3*e, x0, y0+8*e, x0+3*e, y0+8*e, x0+5*e, y0+3*e, yellow, black);
    YDrawFourFB (x0+5*e, y0+3*e, x0+3*e, y0+8*e, x0+8*e, y0+8*e, x0+8*e, y0+3*e, yellow, black);

    x0 = 3*e;
    y0 = 15*e;
    YDrawRectFB (x0, y0, 13*e, 5*e, white, black);

    YDrawTriFB  (x0, y0, x0+8*e, y0+3*e, x0+8*e, y0,  yellow, black);
    YDrawTriFB  (x0+5*e, y0+2*e, x0+5*e, y0+5*e, x0+13*e, y0+5*e,  yellow, black);
    YDrawFourFB (x0, y0, x0, y0+5*e, x0+5*e, y0+5*e, x0+5*e, y0+2*e, yellow, black);
    YDrawFourFB (x0+8*e, y0, x0+8*e, y0+3*e, x0+13*e, y0+5*e, x0+13*e, y0, yellow, black);

    YDrawContext (FALSE, ID_NULL);
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);

    YBeginGroup ("All steps", 50, 70, 200, 130, YColor(""));
    YWnd (&h_p1, PUSH, "1. Start",       20,  10, 160, 20, 0,0,0,0, CLR_DEF);
    YWnd (&h_p2, PUSH, "2. Cuting gold", 20,  40, 160, 20, 0,0,0,0, CLR_DEF);
    YWnd (&h_p3, PUSH, "3. Moved pices", 20,  70, 160, 20, 0,0,0,0, CLR_DEF);
    YWnd (&h_p4, PUSH, "4. Calculate",   20, 100, 160, 20, 0,0,0,0, CLR_DEF);
    YEndGroup ();
    break;
  case YITEM1:
    break;
  case YITEM2:
    break;
  case YITEM3:
    break;
  case YITEM4:
    YDlg (goldex_proc, "Attenshion!", 0,0,0,0, 0,0,0,0, CLR_DEF, TRUE); 
    break;
  case YPUSH:
    if      (mes1 == h_p1)  YGoto (YITEM1, 0, 0, 0, 0);
    else if (mes1 == h_p2)  YGoto (YITEM2, 0, 0, 0, 0); 
    else if (mes1 == h_p3)  YGoto (YITEM3, 0, 0, 0, 0); 
    else if (mes1 == h_p4)  YGoto (YITEM4, 0, 0, 0, 0); 
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*---------------------------------mDemon--------------------------------------*/
long
mDemon (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  enum keys {
    MAKE_CELLS = YKEY_LOCALS+1
  };


  static int  *cells;
  static int  *cells_rab;
 /*  static int i_step = 0; */
  int     *ppp;
  int      i, j/* , r, sum */;
  int      cell, new_cell;
  int      left, right, top, bottom;
  char    *text[] =
  {
    "..............................",
    "..............................",
    NULL
  };
/*   static int nsteps, nsteps_min = 1, nsteps_max = 30000; */
  static int hII, hJJ;
  static int ii, ii_min = 5, ii_max = 1000;
  static int jj, jj_min = 5, jj_max = 1000;
/*   int  i0 = 30, j0 = 40; */
  int  top_val;

  static int razm = 5; /* 10 */


  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Demon";

    ii = 50;
    jj = 50;

    cells = cells_rab = NULL;
    break;
  case PROCESS_BEGIN:

    YAlgOut (YSEND2FACE, MM_CELLS_INIT,  ii, jj, 0, razm-1);

    if (!(YT_BOOL) YGoto (MAKE_CELLS, 0, 0, 0, 0))
      break;
    cells = cells;

    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_BEGIN,  0, 0, 0, 0);
    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      cell = YRAND (0, razm-1);
      OUTD (cell);
      ARR2 (cells, ii,jj, i,j) = cell;

      YAlgOut (YSEND2FACE, MM_CELLS_DRAW_ONE,  i, j, cell, 0);
    }
    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_END,  0, 0, 0, 0);

    break;
  case PROCESS_STEP:
    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_BEGIN,  0, 0, 0, 0);
    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      cell = ARR2 (cells, ii,jj, i,j);

      left = j - 1;
      right = j + 1;
      top = i - 1;
      bottom = i + 1;
      if (left < 0)        left = jj - 1;
      if (right > jj - 1)  right = 0;
      if (top < 0)         top = ii - 1;
      if (bottom > ii - 1) bottom = 0;

      top_val = cell+1;
      if (top_val == razm) top_val = 0; 
      if      (ARR2 (cells, ii,jj, top, j)    == top_val) new_cell = top_val;
      else if (ARR2 (cells, ii,jj, i, left)   == top_val) new_cell = top_val;
      else if (ARR2 (cells, ii,jj, i, right)  == top_val) new_cell = top_val; 
      else if (ARR2 (cells, ii,jj, bottom, j) == top_val) new_cell = top_val; 
      
      ARR2 (cells_rab, ii,jj, i,j) = new_cell;
      YAlgOut (YSEND2FACE, MM_CELLS_DRAW_ONE,  i, j, new_cell, 0);

    }
    YAlgOut (YSEND2FACE, MM_CELLS_DRAW_END,  0, 0, 0, 0);

    ppp   = cells;
    cells = cells_rab;
    cells_rab = ppp;

    break;
  case PROCESS_END:
    free (cells);
    free (cells_rab);
    break;
  case MAKE_CELLS:
    if (YOVERFLOW ((ii) * (jj) * sizeof (int))) {
      YMessageBox ("Overflow!", "OK");
      return (FALSE);
    }
    if (!(cells = (int *) malloc ((ii) * (jj) * sizeof (int)))) {
      YMessageBox ("Not memory!", "OK");
      return (FALSE);
    }
    if (!(cells_rab = (int *) malloc ((ii) * (jj) * sizeof (int)))) {
      YMessageBox ("Not memory!", "OK");
      return (FALSE);
    }
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);
    YWnd (Ph(), PROCESS, "Process", 20, 55, 280, 50, id,0,0,0, CLR_DEF);

    YBeginGroup ("Params", 5,120, 100,90, YColor(""));
    YWnd (Ph(), PUSH, "Full Size",    10,i=10,  80,20, 0,0,0,0, CLR_DEF);
    YWnd (&hII, DECIMAL, "II : ",  50,i+=25, 40,20, 0,ii_min,ii_max,LP(ii), CLR_DEF);
    YWnd (&hJJ, DECIMAL, "JJ : ",  50,i+=25, 40,20, 0,jj_min,jj_max,LP(jj), CLR_DEF);
    YEndGroup ();

    break;
  case YPUSH:
    YGoto (YGETITEM, 0, 0, 0, 0);
    YWndUpdate (hII);
    YWndUpdate (hJJ);
    break;
  case YGETITEM:
    YAlgOut (YSEND2FACE, MM_CELLS_SIZE,  0, 0, LP(ii), LP(jj));
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*=========================================================================*/

/*--------------------------------mSelect-------------------------------------*/
long
mSelect (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  enum keys {
    MAKE_CELLS = YKEY_LOCALS + 1, CELLS2CMAP
  };

#define SIZE_MEMO 10
  typedef struct {
    int     count;
    int     sum;
    int     direct;
  } TT_MELEM;
  typedef struct {
    TT_MELEM elem[SIZE_MEMO];
  } TT_MCELL;

  static int ii, jj;
  static TT_MCELL **cells;
  static TT_MCELL **cells_rab;
  

  TT_MCELL **ppp;
  TT_MCELL **ppcell, **ppcell_rab;
  TT_MCELL *pcell;
  int     i, j, i_new, j_new, r, sum, m, k;
  int     left, right, top, bottom;
  char   *text[] =
  {
    "-------------------------------------",
    "-------------------------------------",
    "-------------------------------------",
    NULL
  };

  static void *cmap;
  static int old_cmap = TRUE;
  YT_COLOR color;


  switch (message) {
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YCREATE:
    U_MALLOC;
    WND->name = "Select";
    if (old_cmap)
    if (!(cmap = YColmapCreate ())) YError ("Memo-YColmapCreate");

    ii = 30;
    jj = 30;

    cells = NULL;
    cells_rab = NULL;
    break;
  case PROCESS_BEGIN:
    if (!old_cmap) {
    YAlgOut (YSEND2FACE, MM_CELLS_INIT,  ii, jj, 0, 1);
    }

    if (!(YT_BOOL) YGoto (MAKE_CELLS, 0, 0, 0, 0))
      break;
    ppcell = cells;

    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      r = YRAND (0, 1000);
      if (r < 200) {
	pcell = (TT_MCELL *) malloc (sizeof (TT_MCELL));
	if (!pcell) YError ("PROCESS_BEGIN");
	*(ppcell) = pcell;
	for (m = 0; m < SIZE_MEMO; m++) {
	  (pcell->elem[m]).count = 0;
	  (pcell->elem[m]).sum = YRAND (0, 8);
	  (pcell->elem[m]).direct = YRAND (0, 8);
	}
      }
      ppcell++;
    }

    if (old_cmap) YColmapInit (cmap, ii, jj);
    break;
  case PROCESS_STEP:
    cells = cells;
    cells_rab = cells_rab;
    ppcell_rab = cells_rab;

    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      *(ppcell_rab) = NULL;
      ppcell_rab++;
    }

    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      ppcell = PARR2 (cells, ii,jj, i, j);
      pcell = *ppcell;
      if (pcell == NULL) continue;
      left = j - 1;
      right = j + 1;
      top = i - 1;
      bottom = i + 1;
      if (left < 0)        left = jj - 1;
      if (right > jj - 1)  right = 0;
      if (top < 0)         top = ii - 1;
      if (bottom > ii - 1) bottom = 0;
      sum = 0;
      if (*(PARR2 (cells, ii,jj, top, left)))     sum++;
      if (*(PARR2 (cells, ii,jj, top, j)))        sum++;
      if (*(PARR2 (cells, ii,jj, top, right)))    sum++;
      if (*(PARR2 (cells, ii,jj, i, left)))       sum++;
      if (*(PARR2 (cells, ii,jj, i, right)))      sum++;
      if (*(PARR2 (cells, ii,jj, bottom, left)))  sum++;
      if (*(PARR2 (cells, ii,jj, bottom, j)))     sum++;
      if (*(PARR2 (cells, ii,jj, bottom, right))) sum++;
      /*r=YRAND(0,8); */
      for (k = 1; k <= 4; k++) {
	sum = YRAND (0, 8);
	if      (sum == 0)  { i_new = i;      j_new = j;     } 
	else if (sum == 1)  { i_new = i;      j_new = j - 1; } 
	else if (sum == 2)  { i_new = i - 1;  j_new = j - 1; } 
	else if (sum == 3)  { i_new = i - 1;  j_new = j;     } 
	else if (sum == 4)  { i_new = i - 1;  j_new = j + 1; } 
	else if (sum == 5)  { i_new = i;      j_new = j + 1; } 
	else if (sum == 6)  { i_new = i + 1;  j_new = j + 1; } 
	else if (sum == 7)  { i_new = i + 1;  j_new = j;     } 
	else if (sum == 8)  { i_new = i + 1;  j_new = j + 1; }
	
	if      (i_new < 0)      i_new = ii - 1;
	else if (i_new > ii - 1) i_new = 0;
	
	if      (j_new < 0)      j_new = jj - 1;
	else if (j_new > jj - 1) j_new = 0;
	
	ppcell_rab = PARR2 (cells_rab, ii,jj, i_new, j_new);
	if (*ppcell_rab == NULL) {
	  *ppcell_rab = pcell;
	  ppcell = NULL;
	  break;
	}
      }
    }
    ppp = cells;
    cells = cells_rab;
    cells_rab = ppp;

    YGoto (CELLS2CMAP, 0, 0, 0, 0);

    if (old_cmap) YDrawColmapB (cmap, 0, 0, 100, 100, YColor("black"));

    break;
  case PROCESS_END:
    ppcell = cells;
    ppcell_rab = cells_rab;
    if (!ppcell || !ppcell_rab)
      break;

    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      if (*ppcell) {
	free (*ppcell);
	*ppcell = NULL;
      }
      if (*ppcell_rab) {
	free (*ppcell_rab);
	*ppcell_rab = NULL;
      }
      ppcell++;
      ppcell_rab++;
    }
    free (cells);
    free (cells_rab);
    break;
  case MAKE_CELLS:
    if (YOVERFLOW ((ii) * (jj) * sizeof (TT_MCELL *))) {
      YMessageBox ("Overflow!", "OK");
      return (FALSE);
    }
    if (!(cells = (TT_MCELL **) malloc ((ii) * (jj) * sizeof (TT_MCELL *)))) {
      YMessageBox ("Not memory!", "OK");
      return (FALSE);
    }
    if (!(cells_rab = (TT_MCELL **) malloc (
				      (ii) * (jj) * sizeof (TT_MCELL *)))) {
      YMessageBox ("Not memory!", "OK");
      return (FALSE);
    }
    ppcell = cells;
    ppcell_rab = cells_rab;
    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      *(ppcell) = NULL;
      *(ppcell_rab) = NULL;
      ppcell++;
      ppcell_rab++;
    }
    break;
  case CELLS2CMAP:
    if (!old_cmap) YAlgOut (YSEND2FACE, MM_CELLS_DRAW_BEGIN,  0, 0, 0, 0);

    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      pcell = ARR2 (cells_rab, ii,jj, i,j);

      if (old_cmap) {
	if (pcell) color = YColor("blue");
	else       color = YColor("yellow");
	YColmapPut (cmap, i, j, color);
      } else {
	YAlgOut (YSEND2FACE, MM_CELLS_DRAW_ONE,  i, j, pcell?1:0, 0);
      }
    }

    if (!old_cmap) YAlgOut (YSEND2FACE, MM_CELLS_DRAW_END,  0, 0, 0, 0);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);
    YWnd (Ph(), PROCESS, "Process", 20,65, 280,45, id, 0, 0, 0, CLR_DEF);

    YBeginGroup ("", 5,120, 100,110, YColor(""));
    YWnd (Ph(), CHECK, "old_cmap", 20,20, 20,20,  0, LP(old_cmap), 0, 0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("", 110,120, 205,75, YColor(""));
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*=======endif=======endif=======endif======endif=======endif=====endif=======*/
#endif
/*=======endif=======endif=======endif======endif=======endif=====endif=======*/
