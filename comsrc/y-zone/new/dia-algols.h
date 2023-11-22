// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************
 *                                                                          *
 *  algols.h  -- declarations for "Library ALGOLS";                         *  
 *                                                                          *
 *  Copyright (c) 2000, Life Software.                                      *
 *                                                                          *
 ****************************************************************************
 */                                                                          
           
#ifndef _ALGOLS_H
#define _ALGOLS_H
 
#ifdef __cplusplus
extern "C" {
#endif

/****************************************************************************/

#include  <stdio.h>
#include  <stdlib.h>  
#include  <string.h>

#include  <math.h>
#include  <time.h>  
#include  <ctype.h>  
  

/****************************************************************************
 *                                                                          *
 *                 Declarations for section [ALGO]                          *  
 *                                                                          *
 ****************************************************************************
 */                                                                          

enum keys_y_zalg {
  YALGO_BEGIN = YWIND_END, 

  YCALC, YGO, YMOD, YMAP, YSEND2FACE, YSEND2BACK, 
  YPOST2FACE, YPOST2BACK, YOUTPUT, YINPUT, 
  MM_DATA, MM_PUSTO, MM_APPLY, MM_BEGIN, MM_END, MM_DITTO, MM_NONE,
  MM_STRING,

  YALGO_END 
}; 

#define  ID_BACK   ID_NULL+1 
#define  ID_FACE   ID_NULL+2 
#define  ABCD      int  ditto

typedef long  AT_PDATA; 

#define  MDATA  (message)
#define  PDATA  (mes4)

#define  PAR_NEW (YGet("wlong1")) 
#define  PAR_DEF (&pars[0])

typedef struct {
  char  *type;
  char  *name;
  char  *value;
  char   stype[50], sname[50], svalue[50];
} VT_PARS; 

void     YAlgParam (VT_PARS*, char*, void*, long);
#define  PAR_INIT(v1,v2) YAlgParam(PAR_DEF, v1, v2, PAR_NEW)

#define  WFU 55
#define  HFU 20 
#define  WMI 10
#define  HMI 10
   
#define  MM_ONLY {if ((from != ID_BACK) && (from != ID_FACE)) break;}
#define  MM_FORWARD  (from == ID_BACK)
#define  MM_BACKWARD (from == ID_FACE)

void     YInitALGO (void);
long     mKran   (PFUNC_PAR);
long     mStop   (PFUNC_PAR);
long     mControl(PFUNC_PAR);
long     mDitto  (PFUNC_PAR);

#define  W_MOD  320
#define  H_MOD  240 
long     MAP     (PFUNC_PAR); 
long     MODPUSH (PFUNC_PAR);
long     MODLIST (PFUNC_PAR);

#define  NUM_MID 3
#define  NUM_FORMES 3

typedef struct {
  int      mod_id;
  int      type;
  char    *proc_name;
  char    *pars_name;
  int      cx, cy;
  int      w, h;
  char    *name;
  int      mid[NUM_MID];
  char    *forphr[NUM_FORMES];

  int      id_new;  
  YT_PFUNC proc;
  long     long1;
} AT_PLANER;

typedef struct {
  char   *txt;
  int     x,y;
} AT_TEXT;

#define SIZE_MAPTEXT 20

typedef struct {
  char      *name;
  AT_PLANER *plan;
  AT_TEXT   *text;
} AT_MAP;

#define  mid_END -9999
#define  mid_OUT 999
  
typedef struct {
  char   *name;
  VT_PARS pars[40];
} AT_PAR;

void     YAlgSetStart (int start_act, char *start_name);
YT_BOOL  YAlgParse (int argc, char **argv); 
void     YAlgGo (int mid);
void     begin_end (int *, int *beg);
void     YAlgCalc (char *name);
void     YAlgOut (int, int message, int mes1, int mes2, long mes3, long mes4);
void     YAlgResolve (void);
void     YAlgReadAll (char **pstr);
void     YAlgCall (int id, int how, int message, int mes1, int mes2, long mes3, long mes4);
YT_BOOL  YAlgSetNewPars (AT_PAR *new_pars);
YT_BOOL  YAlgSetNewMap (AT_MAP *map_new);

typedef struct {
  void     *zalg_s;
  YT_BOOL   stop_flag;
  char      start_name[100];
  int       start_act;
} YT_ALGO;

extern   YT_ALGO *zalg;
#define  ALGO (zalg) 

#define  START_NAME  (ALGO->start_name)
#define  START_ACT   (ALGO->start_act)

long     mTest   (PFUNC_PAR);
void     YAlgLoadTest (void);
void     YAlgLoadUser (void);

#define  A_COMMAND '@'
#define  A_COMMENT '#'
#define  A_SHELL   '#'

/****************************************************************************/
                                                                               
#ifdef __cplusplus
}
#endif
#endif /* _ALGOLS_H */

/****************************************************************************/ 
