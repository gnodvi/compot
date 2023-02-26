// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************
 *                                                                          *
 *                                                                          *
 ****************************************************************************
 */   
                                                                            
#include  <stdio.h>
#include  <stdlib.h>   
#include  <string.h>
#include  <math.h>
#include  <time.h>  
#include  <unistd.h> 
#include  <ctype.h>  
#include  <dirent.h> 
#include  <sys/time.h> 
#include  <sys/param.h>
                                                                             
#include "a-comm.h"

/*******************************************************************************/

//int bsize;
//int   isize, jsize; //!!!!!???

FILE *LOG;
FILE *input;


/*--------------------------------YInt--------------------------------------*/ 
int 
YInt (float f) 
{ 
  int     i; 
  float   o; 
 
  i = (int) f; 
  o = f - i; 
  if      (o > 0.5)   i++; 
  else if (o < -0.5)  i--; 
 
  return (i); 
} 
/*----------------------------------------------------------------------------*/
void
Error (const char *msg)      
{

  fprintf (stderr, "Error: %s\n", msg);

  exit (0);
}
/*----------------------------------------------------------------------------*/
void
MyError (const char *msg)      
{

  if (is_pri) 
    fprintf (STDERR, "MyError: %s\n", msg);

  exit (0);
}
/*******************************************************************************/
/*******************************************************************************/

/*=============================== Z-LIBRARY ==============================*/
/*                                                                        */
/*                                                                        */
/*                                                                        */
/*-------------------------------ZRand123---------------------------------*/
int
ZRand123 (float p1, float p2, float p3)
{
	int ret, yrand;

	yrand = ZRAND (1,100);

  if      (yrand < p1) return (1);
	else if (yrand > p3) return (3);
	else                 return (2);

}
/*--------------------------------ZRandYes--------------------------------*/
ZT_BOOL
ZRandYes (float procent)
{

	if (ZRand123(procent, 0, 100-procent)==1) 
		return (TRUE);
	else             
		return (FALSE);

}
/*----------------------------------ZWarning------------------------------*/
void
ZWarning (char *string)
{

  fprintf (LOG, "ZWarning: %s \n", string);

}
/*----------------------------------ZError--------------------------------*/
void
ZError (char *string)
{

  fprintf (LOG, "ZError: %s \n", string);
  exit (EXIT_FAILURE);

}
/*-------------------------------ZStrCmp----------------------------------*/ 
ZT_BOOL 
ZStrCmp (char *str1, char *str2) 
{ 
  if (!str1 || !str2) return (FALSE);   

   
  return (!(strcmp(str1, str2))); 
} 
/*-------------------------------ZValueSet--------------------------------*/ 
ZT_BOOL 
ZValueSet (char *type, char *value, void *pdata) 
{ 
 int     decimal; 
 
 if      (ZStrCmp (type,"int"))      *((int*)pdata)      = atoi (value); 
 else if (ZStrCmp (type,"float"))    *((float*)pdata)    = atof (value); 
 else if (ZStrCmp (type,"double"))   *((double*)pdata)   = atof (value); 
 else if (ZStrCmp (type,"bool")) { 
   if      (ZStrCmp (value, "true"))   decimal = 1; 
   else if (ZStrCmp (value, "false"))  decimal = 0; 
   else    { 
     ZWarning ("bool"); 
     return (FALSE); 
   } 
   *((int *) pdata) = decimal; 
 } 
 else if (ZStrCmp(type,"string"))   strcpy ((char*)pdata,value); 
  
 return (TRUE); 
} 
/*-----------------------------ZValueRead---------------------------------*/
void
ZValueRead (FILE *input, void *pdata,  char *type, char *name/* , char *value_def */)
{
/* 	char *value; */
#define SIZE_STR 100 
  char  str_rab[SIZE_STR], *str; 
	char stype[80], sname[80], svalue[80];
	ZT_BOOL is_find_value;

  fseek (input, 0, SEEK_SET);
	/* value = value_def; */
	is_find_value = FALSE;

  while (1) { 
    if (!fgets (str_rab, SIZE_STR-1, input))  
      break; 
    if (str_rab[0] == '#') continue; 
		if (str_rab[0] == ';') {
			str = strchr(str_rab+1,';')+1;
		} else {
			str = str_rab;
		}

		/* printf ("str = %s \n", str); */
    sscanf (str, "%s %s %s", stype, sname, svalue); 
    sscanf (str, "%s %s", sname, svalue); 
		if (ZStrCmp(sname, name)) {
			/* value = svalue; */
			is_find_value = TRUE;
			break;
		}
  } 

	if (!is_find_value) {
		fprintf (LOG, "Don't find value: %s \n\n", name);
		exit (1);
	}

	ZValueSet (type, svalue, pdata); 

	return;
}
/*-------------------------------ZPause------------------------------------*/
void
ZPause (char *message)
{

	printf ("%s \n", message);
	getchar ();

	return;
}
/*************************************************************************/
/*******************************************************************************/
/*******************************************************************************/
