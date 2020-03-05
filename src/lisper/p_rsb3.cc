/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: v_rsb_.h                                                  *
 *                                                                             *
 *******************************************************************************
 */  

/****************************************************************************/                    
#ifdef __cplusplus                                                                
extern "C" {                                                                     
#endif                                                                                       
/****************************************************************************/   

#define FALSE 0
#define TRUE  1
#define NULL  0
#include <stdio.h>
#include <stdlib.h>   
#include <string.h>
#include <math.h> 
#include <time.h>  
#include <unistd.h> 
#include <ctype.h>  
#include <dirent.h> 
#include <sys/time.h> 
#include <sys/param.h>
#include <sys/timeb.h>
#include <assert.h>
#include <stdarg.h>

void c_history_create_init (/* int **p1hist, int **p2hist */);
void c_set_history_for_player_1 ();
void c_set_history_for_player_2 ();
void c_set_last_history(int p1, int p2);


/******************************************************************************/                    
#ifdef __cplusplus                                                                
extern "C" {                                                                     
#endif                                                                                       
/******************************************************************************/   

// по возрастанию силы, т.е.  "0 < 1 < 2"  и дальше по кругу
#define rock      0
#define paper     1
#define scissors  2

#define TRIALS    1000      // кол-во ходов (испытаний) в матче

#define maxrandom 2147483648.0 /* 2^31, ratio range is 0 <= r < 1 */

/******************************************************************************/   

  //extern int trials;   // кол-во ходов (испытаний) в матче
  //#define TRIALS    1000      // кол-во ходов (испытаний) в матче

  //extern int my_history [TRIALS+1];
  //extern int opp_history[TRIALS+1];

extern int *m_history, *o_history;
extern int *p1hist,    *p2hist;

/******************************************************************************/   

/******************************************************************************/   

int  flip_biased_coin (double prob);
int  biased_roshambo (double prob_rock, double prob_paper);

/******************************************************************************/   

#define T_RSB_RETURN int

/*============================================================================*/
// Random (Optimal) : generate action uniformly at random (optimal strategy)
/*============================================================================*/

T_RSB_RETURN  randbot ();          // ужe eсть в Лисп
T_RSB_RETURN  rockbot ();          // ужe eсть в Лисп
T_RSB_RETURN  r226bot ();          // ужe eсть в Лисп
T_RSB_RETURN  rotatebot ();        // ужe eсть в Лисп
T_RSB_RETURN  copybot ();          // ужe eсть в Лисп
T_RSB_RETURN  switchbot ();        // ужe eсть в Лисп
T_RSB_RETURN  freqbot ();          // -
T_RSB_RETURN  freqbot2 ();         // ужe eсть в Лисп
T_RSB_RETURN  pibot ();            // -
T_RSB_RETURN  switchalot ();       // ужe eсть в Лисп
T_RSB_RETURN  flatbot3 ();         // ужe eсть в Лисп
T_RSB_RETURN  antiflatbot ();      // - (и нe был в турнирах)
T_RSB_RETURN  foxtrotbot ();       // ужe eсть в Лисп
T_RSB_RETURN  debruijn81 ();       // -
T_RSB_RETURN  textbot ();          // -
T_RSB_RETURN  antirotnbot ();      // -
T_RSB_RETURN  driftbot ();         // ужe eсть в Лисп
T_RSB_RETURN  addshiftbot3 ();     // -
T_RSB_RETURN  adddriftbot2 ();     // ужe eсть в Лисп

/*============================================================================*/
// End of Simple  Players Algorithms  
/*============================================================================*/

T_RSB_RETURN  predbot (void);
T_RSB_RETURN  robertot (void);
T_RSB_RETURN  boom (void); 
T_RSB_RETURN  naivete (void);  // - (и нe был в турнирах)
T_RSB_RETURN  markov5 ();      // -
T_RSB_RETURN  markovbails ();  // -
T_RSB_RETURN  granite();       // -
T_RSB_RETURN  marble ();       // -
T_RSB_RETURN  zq_move ();      // -
T_RSB_RETURN  sweetrock ();      // -
T_RSB_RETURN  piedra ();         // -
T_RSB_RETURN  mixed_strategy (); // -
T_RSB_RETURN  multibot ();       // -
T_RSB_RETURN  inocencio () ;     // -
T_RSB_RETURN  peterbot ();       // -

/******************************************************************************/   

T_RSB_RETURN  iocainebot (void);
T_RSB_RETURN  phasenbott ();
T_RSB_RETURN  russrocker4 ();
T_RSB_RETURN  halbot (void);
T_RSB_RETURN  mod1bot ();  /* Don Beal (UK) simple model builder */
T_RSB_RETURN  shofar (void);
T_RSB_RETURN  biopic ();
T_RSB_RETURN  actr_lag2_decay (void);
T_RSB_RETURN  sunNervebot ();
T_RSB_RETURN  sunCrazybot (); // -

/******************************************************************************/   

/* T_RSB_RETURN my_super_bot (); */

/* void rsb_bigtest (int tourneys, int seed);  */
/* void rsb_mintest (int tourneys, int seed);  */

/* void rsb_newtest (int tourneys, int seed);  */


/****************************************************************************/   
#ifdef __cplusplus                                                               
}                                                                                
#endif                                                                           
/****************************************************************************/   





/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: v_rsb_.c                                                  *
 *                                                                             *
  ******************************************************************************
 */ 
                                                                                              

  //#include "v-rsb-.h"

/******************************************************************************/   

int *m_history, *o_history; // тeкущиe указатeли (т.e. зависит от игрока)
int *p1hist,    *p2hist;    // а здeсь рeальныe массивы историй

//int p1hist[TRIALS+1], p2hist[TRIALS+1]; // реальные списки ходов 
//int *p1hist, *p2hist;


/*----------------------------------------------------------------------------*/
void
c_history_create_init (/* int **p1hist, int **p2hist */)
{
  //int i;

  p1hist = calloc ((TRIALS+1), sizeof(int));
  p2hist = calloc ((TRIALS+1), sizeof(int));

/*   *p1hist = calloc ((TRIALS+1), sizeof(int)); */
/*   *p2hist = calloc ((TRIALS+1), sizeof(int)); */

  /* Full History Structure
    element 0 - число уже сыгранных попыток к текущему времени (т.е. размер массива)
    element i - действие, бывшее на i-ом ходе  (1 <= i <= trials) 
  */

  // обнуляем массивы историй
/*   for (i = 0; i <= TRIALS; i++) { */
/*     *p1hist[i] = 0;  */
/*     *p2hist[i] = 0; */
/*   } */

}
/*----------------------------------------------------------------------------*/
void
c_set_history_for_player_1 ()
{

  m_history = p1hist;
  o_history = p2hist;

}
/*----------------------------------------------------------------------------*/
void
c_set_history_for_player_2 ()
{

  m_history = p2hist;
  o_history = p1hist;

}
/*----------------------------------------------------------------------------*/
void
c_set_last_history(int p1, int p2)
{

  p1hist[0]++;            // номер последнего хода 
  p1hist[p1hist[0]] = p1; // и история 1-го игрока

  p2hist[0]++;            // номер последнего хода   
  p2hist[p2hist[0]] = p2; // и история 2-го игрока

}
/******************************************************************************/   

/*----------------------------------------------------------------------------*/
int 
flip_biased_coin (double prob)
{
  /* flip an unfair coin (bit) with given probability of getting a 1 */

  if ( (random() / maxrandom) >= prob )
    return(0);
  else 
    return(1);
}
/*----------------------------------------------------------------------------*/
int 
biased_roshambo (double prob_rock, double prob_paper)
{
  /* roshambo with given probabilities of rock, paper, or scissors */
  double throw;

  throw = random() / maxrandom;

   if      ( throw < prob_rock )              return (rock);
   else if ( throw < prob_rock + prob_paper ) return (paper);
   else /* throw >= prob_rock + prob_paper */ return (scissors);
}
/*----------------------------------------------------------------------------*/


/******************************************************************************/   
/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: v_rsb1.c                                                  *
 *                                                                             *
  ******************************************************************************
 */ 
                                                                            
//#include "v-rsb-.h"

/******************************************************************************/



/******************************************************************************/
//==============================================================================
/*  Dummy Bots  (written by Darse Billings)  */
//==============================================================================


/*============================================================================*/
// Switch A Lot : seldom repeat the previous pick
/*============================================================================*/
int 
switchalot ()
{
  if      (m_history[m_history[0]] == rock)  return (biased_roshambo (0.12, 0.44)); 

  else if (m_history[m_history[0]] == paper) return (biased_roshambo (0.44, 0.12));

  else                                         return (biased_roshambo (0.44, 0.44));
}
/*============================================================================*/
// Flat bot : flat distribution, 20% chance of most frequent actions 
/*============================================================================*/
int 
flatbot3 ()  
{
  static int rc, pc, sc;
  int        mylm, choice;

  choice = 0;

  if (m_history[0] == 0) {
    rc = 0; 
    pc = 0; 
    sc = 0; 
  }
  else {
    mylm = m_history[m_history[0]];
    if      (mylm == rock)        rc++;
    else if (mylm == paper)       pc++;
    else  /* mylm == scissors */  sc++;
  }

  if ((rc <  pc) && (rc  < sc))  choice = biased_roshambo (0.8,  0.1); 
  if ((pc <  rc) && (pc  < sc))  choice = biased_roshambo (0.1,  0.8); 
  if ((sc <  rc) && (sc  < pc))  choice = biased_roshambo (0.1,  0.1); 
  if ((rc == pc) && (rc  < sc))  choice = biased_roshambo (0.45, 0.45); 
  if ((rc == sc) && (rc  < pc))  choice = biased_roshambo (0.45, 0.1); 
  if ((pc == sc) && (pc  < rc))  choice = biased_roshambo (0.1,  0.45); 
  if ((rc == pc) && (rc == sc))  choice = random () % 3; 

  /* printf("[%d %d %d: %d]", rc, pc, sc, choice); */

  return (choice);
}
/*============================================================================*/
// Foxtrot bot : set pattern: rand prev+2 rand prev+1 rand prev+0, repeat 
/*============================================================================*/
int 
foxtrotbot ()
{
  int turn;
  int ret; // для отладки

  turn = m_history[0] + 1;

/*   if  (turn % 2)  return (random() % 3);  */
/*   else            return ((m_history[turn-1] + turn) % 3);  */

  if  (turn % 2)  ret = (random() % 3); 
  else            ret = ((m_history[turn-1] + turn) % 3); 

  //fprintf (stderr, "turn= %4d    ret= %d \n", turn, ret); 

  return (ret);
}
/*============================================================================*/
// Copy-drift bot : 
// bias decision by opponent's last move, but drift over time
// max -EV = -0.50 ppt 
/*============================================================================*/
int 
driftbot ()
{
  static int gear;
  int        mv, throw;

  mv = m_history[0];

  if (mv == 0) { 
    gear  = 0;
    throw = random() % 3; 
  }

  else {
    if (flip_biased_coin(0.5))    throw = o_history[mv];
    else                          throw = random() % 3;

    if (mv % 111 == 0)
      gear += 2;
  }

  return ((throw + gear) % 3);
}
/*============================================================================*/
// Add-drift bot : 
// base on sum of previous pair (my & opp), drift over time
// deterministic 50% of the time, thus max -EV = -0.500 ppt
/*============================================================================*/
int 
adddriftbot2 ()
{

  static int gear;
  int        mv;

  mv = m_history[0];

  if (mv == 0) {
    gear = 0;
    return (random() % 3);
  }
  else if (mv % 200 == 0) 
    gear += 2;

  if (flip_biased_coin (0.5)) 
    return (random() % 3 ); 
  else 
    return ((m_history[mv] + o_history[mv] + gear) % 3);
 
}
/*============================================================================*/
/*  End of Simple (rsb-99.c)  Players Algorithms  */
/*============================================================================*/








//==============================================================================
/*
 * MD5 transform algorithm, taken from code written by Colin Plumb,
 * and put into the public domain
 */

/* The four core functions */

/*----------------------------------------------------------------------------*/
#define F1(x, y, z) (z ^ (x & (y ^ z)))
#define F2(x, y, z) F1(z, x, y)
#define F3(x, y, z) (x ^ y ^ z)
#define F4(x, y, z) (y ^ (x | ~z))

/* This is the central step in the MD5 algorithm. */
#define MD5STEP(f, w, x, y, z, data, s) ( w += f(x, y, z) + data,  w = w<<s | w>>(32-s),  w += x )

/*----------------------------------------------------------------------------*/
/*
 * The core of the MD5 algorithm, this alters an existing MD5 hash to
 * reflect the addition of 16 longwords of new data.  MD5Update blocks
 * the data and converts bytes into longwords for this routine.
 */
/*----------------------------------------------------------------------------*/
static void MD5Transform (unsigned int buf[4],
                         unsigned int const in[16])
{
  unsigned int a, b, c, d;

  a = buf[0];
  b = buf[1];
  c = buf[2];
  d = buf[3];

  MD5STEP(F1, a, b, c, d, in[ 0]+0xd76aa478,  7);
  MD5STEP(F1, d, a, b, c, in[ 1]+0xe8c7b756, 12);
  MD5STEP(F1, c, d, a, b, in[ 2]+0x242070db, 17);
  MD5STEP(F1, b, c, d, a, in[ 3]+0xc1bdceee, 22);
  MD5STEP(F1, a, b, c, d, in[ 4]+0xf57c0faf,  7);
  MD5STEP(F1, d, a, b, c, in[ 5]+0x4787c62a, 12);
  MD5STEP(F1, c, d, a, b, in[ 6]+0xa8304613, 17);
  MD5STEP(F1, b, c, d, a, in[ 7]+0xfd469501, 22);
  MD5STEP(F1, a, b, c, d, in[ 8]+0x698098d8,  7);
  MD5STEP(F1, d, a, b, c, in[ 9]+0x8b44f7af, 12);
  MD5STEP(F1, c, d, a, b, in[10]+0xffff5bb1, 17);
  MD5STEP(F1, b, c, d, a, in[11]+0x895cd7be, 22);
  MD5STEP(F1, a, b, c, d, in[12]+0x6b901122,  7);
  MD5STEP(F1, d, a, b, c, in[13]+0xfd987193, 12);
  MD5STEP(F1, c, d, a, b, in[14]+0xa679438e, 17);
  MD5STEP(F1, b, c, d, a, in[15]+0x49b40821, 22);

  MD5STEP(F2, a, b, c, d, in[ 1]+0xf61e2562,  5);
  MD5STEP(F2, d, a, b, c, in[ 6]+0xc040b340,  9);
  MD5STEP(F2, c, d, a, b, in[11]+0x265e5a51, 14);
  MD5STEP(F2, b, c, d, a, in[ 0]+0xe9b6c7aa, 20);
  MD5STEP(F2, a, b, c, d, in[ 5]+0xd62f105d,  5);
  MD5STEP(F2, d, a, b, c, in[10]+0x02441453,  9);
  MD5STEP(F2, c, d, a, b, in[15]+0xd8a1e681, 14);
  MD5STEP(F2, b, c, d, a, in[ 4]+0xe7d3fbc8, 20);
  MD5STEP(F2, a, b, c, d, in[ 9]+0x21e1cde6,  5);
  MD5STEP(F2, d, a, b, c, in[14]+0xc33707d6,  9);
  MD5STEP(F2, c, d, a, b, in[ 3]+0xf4d50d87, 14);
  MD5STEP(F2, b, c, d, a, in[ 8]+0x455a14ed, 20);
  MD5STEP(F2, a, b, c, d, in[13]+0xa9e3e905,  5);
  MD5STEP(F2, d, a, b, c, in[ 2]+0xfcefa3f8,  9);
  MD5STEP(F2, c, d, a, b, in[ 7]+0x676f02d9, 14);
  MD5STEP(F2, b, c, d, a, in[12]+0x8d2a4c8a, 20);

  MD5STEP(F3, a, b, c, d, in[ 5]+0xfffa3942,  4);
  MD5STEP(F3, d, a, b, c, in[ 8]+0x8771f681, 11);
  MD5STEP(F3, c, d, a, b, in[11]+0x6d9d6122, 16);
  MD5STEP(F3, b, c, d, a, in[14]+0xfde5380c, 23);
  MD5STEP(F3, a, b, c, d, in[ 1]+0xa4beea44,  4);
  MD5STEP(F3, d, a, b, c, in[ 4]+0x4bdecfa9, 11);
  MD5STEP(F3, c, d, a, b, in[ 7]+0xf6bb4b60, 16);
  MD5STEP(F3, b, c, d, a, in[10]+0xbebfbc70, 23);
  MD5STEP(F3, a, b, c, d, in[13]+0x289b7ec6,  4);
  MD5STEP(F3, d, a, b, c, in[ 0]+0xeaa127fa, 11);
  MD5STEP(F3, c, d, a, b, in[ 3]+0xd4ef3085, 16);
  MD5STEP(F3, b, c, d, a, in[ 6]+0x04881d05, 23);
  MD5STEP(F3, a, b, c, d, in[ 9]+0xd9d4d039,  4);
  MD5STEP(F3, d, a, b, c, in[12]+0xe6db99e5, 11);
  MD5STEP(F3, c, d, a, b, in[15]+0x1fa27cf8, 16);
  MD5STEP(F3, b, c, d, a, in[ 2]+0xc4ac5665, 23);

  MD5STEP(F4, a, b, c, d, in[ 0]+0xf4292244,  6);
  MD5STEP(F4, d, a, b, c, in[ 7]+0x432aff97, 10);
  MD5STEP(F4, c, d, a, b, in[14]+0xab9423a7, 15);
  MD5STEP(F4, b, c, d, a, in[ 5]+0xfc93a039, 21);
  MD5STEP(F4, a, b, c, d, in[12]+0x655b59c3,  6);
  MD5STEP(F4, d, a, b, c, in[ 3]+0x8f0ccc92, 10);
  MD5STEP(F4, c, d, a, b, in[10]+0xffeff47d, 15);
  MD5STEP(F4, b, c, d, a, in[ 1]+0x85845dd1, 21);
  MD5STEP(F4, a, b, c, d, in[ 8]+0x6fa87e4f,  6);
  MD5STEP(F4, d, a, b, c, in[15]+0xfe2ce6e0, 10);
  MD5STEP(F4, c, d, a, b, in[ 6]+0xa3014314, 15);
  MD5STEP(F4, b, c, d, a, in[13]+0x4e0811a1, 21);
  MD5STEP(F4, a, b, c, d, in[ 4]+0xf7537e82,  6);
  MD5STEP(F4, d, a, b, c, in[11]+0xbd3af235, 10);
  MD5STEP(F4, c, d, a, b, in[ 2]+0x2ad7d2bb, 15);
  MD5STEP(F4, b, c, d, a, in[ 9]+0xeb86d391, 21);

  buf[0] += a;
  buf[1] += b;
  buf[2] += c;
  buf[3] += d;
}

#undef F1
#undef F2
#undef F3
#undef F4
#undef MD5STEP


int MD5Buf[4];
int MD5In[16];

int MD5BufInit [] =
{
  0x67452301,
  0xefcdab89,
  0x98badcfe,
  0x10325476
};
/*----------------------------------------------------------------------------*/
void
MD5Init ()
{
  int i;

  for (i = 0; i < 4; i++)
  {
    MD5Buf[i] = MD5BufInit[i];
  }

  for (i = 0; i < 16; i++)
  {
    MD5In[i] = MD5Buf[i % 4] + MD5Buf[i / 4];
  }

}
/*----------------------------------------------------------------------------*/
unsigned int
MD5Random ()
{
  int i;

  MD5Transform ( MD5Buf, MD5In );

  for (i = 0; i < 16; i++)
  {
    MD5In[i] = MD5Buf[i % 4] + MD5Buf[i / 4];
  }

  return MD5Buf[0];
}
/*----------------------------------------------------------------------------*/
int 
asterious ()  /* Kastellanos Nikos (36 lines) */
{
 /* ASTERIOUS v1.01 */
 /* Program by Kastellanos Nikos  */
 /* datacrime@freemail.gr   */

 int res;
 int trial=0;

 int static base=0;
 int static weirdo=1;

 /*  Get a random result */
 res=random()%3;

 /*  Handle base and weirdo */
 trial=m_history[0];
 if(trial>0  &&  m_history[trial]==rock      &&  o_history[trial]==paper)
   base+=2;
 if(trial>0  &&  m_history[trial]==paper     &&
    o_history[trial]==scissors) base+=2;
 if(trial>0  &&  m_history[trial]==scissors  &&  o_history[trial]==rock)
   base+=2;
 if(trial>0  &&  m_history[trial]==o_history[trial])     base+=1;
 if(base<0) base=0;
 if(base>9) {base=0;weirdo=(weirdo+1%3);} /*  6,9,12,15 are good BASE numbers. */

 /*  do the AI stuff... */
 if(trial>0) res=o_history[trial];

 /*  Schisophrenic Behavior. */
 res=res+weirdo;

 return ( res%3 );
}
/*----------------------------------------------------------------------------*/
/******************************************************************************/



/*----------------------------------------------------------------------------*/
/*  End of RoShamBo Player Algorithms  */
/*----------------------------------------------------------------------------*/


/******************************************************************************/
/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: v_rsb2.c                                                  *
 *                                                                             *
  ******************************************************************************
 */ 

                                                                             
//#include "v-rsb-.h"

/******************************************************************************/

//#define fw        4         /* field width for printed numbers */
//#define verbose1  0         /* print result of each trial      */
//#define verbose2  0         /* print match histories           */
//#define verbose3  1         /* print result of each match      */

/*----------------------------------------------------------------------------*/
/*  Entrant:  Robertot (8)   Andreas Junghanns (Ger)  */
/*----------------------------------------------------------------------------*/
int 
robertot ()
{
#define NHIST           10
#define NPREDICTS       2
#define STEPS           200     /* grains for the freq count % */
#define MAXVOTE         256     /* maximal vote for 0/100% */
#define ZERO            11.1    /* zero point for the distribution */

#define FUNC(x) ((x)*(x)*(x)*(x)*(x))
#define MAXR(x,y) ((x)>(y)?(x):(y))
#define MINR(x,y) ((x)<(y)?(x):(y))

  /* gather stats for counts of related events, NHIST back */
  static int hitsd[NHIST][3][3][3];   /* NHIST counts, for each combination */
  static int countd[NHIST][3][3];     /* history was seen how many times */
  int p,h,pos,rsb,h_rsb,o_rsb;
  int vote[3];
  static int incvote[STEPS+1];
  float index;

  if (o_history[0] == 0) {
    memset(hitsd,0,sizeof(int)*NHIST*3*3*3);
    memset(countd,0,sizeof(int)*NHIST*3*3);

    for (index=((float)MAXVOTE)/FUNC(ZERO), p=0, h=ZERO; h>0; h--)
      incvote[p++] = -((int)((((float)FUNC(h))*index)+0.5));
    for (index=((float)MAXVOTE)/FUNC(STEPS-ZERO), h=ZERO; h<=STEPS; h++)
      incvote[p++] = ((int)((((float)FUNC(h-ZERO))*index)+0.5));
  }

  if (o_history[0] >= NPREDICTS) {
    /* Only with enough data try to predict! */
    pos = o_history[0];
    rsb = o_history[pos];

    for (h=0; h<NHIST && (pos-(h+1))>0; h++) {
      countd[h][o_history[pos-(h+1)]][m_history[pos-(h+1)]]++;
      hitsd [h][rsb][o_history[pos-(h+1)]][m_history[pos-(h+1)]]++;
    }

    for (rsb=0; rsb<3; rsb++) vote[rsb]=0;
    /* Now, each history entry will vote for which move to play */
    for (rsb=0; rsb<3; rsb++) {
      for (h=0; h<NHIST && (pos-h)>0; h++) {
        o_rsb = o_history[pos-h];
        h_rsb =  m_history[pos-h];
        if (countd[h][o_rsb][h_rsb]) {
          index=((float)STEPS)*
            hitsd[h][rsb][o_rsb][h_rsb]/countd[h][o_rsb][h_rsb];
          vote[rsb] += incvote[(int)index];
        }
      }
    }

    h = MINR(vote[rock],vote[paper]);
    h = MINR(h,vote[scissors]);
    vote[rock] -= h; vote[paper] -= h; vote[scissors] -= h;
    h = MAXR(vote[rock],vote[paper]);
    h = MAXR(h,vote[scissors]);
    h = (h*3)/4;

    if (h==0) h++;

    vote[rock] /= h; vote[paper] /= h; vote[scissors] /= h;

    //if (verbose1)
    //  printf("%i %i %i\n", vote[rock], vote[paper], vote[scissors]);

    if (vote[rock] > vote[scissors] && vote[rock] > vote[paper])
      return(paper);
    else if (vote[scissors] > vote[paper] && vote[scissors] > vote[rock])
      return(rock);
    else if (vote[paper] > vote[rock] && vote[paper] > vote[scissors])
      return(scissors);
    else if (vote[rock] == vote[paper] && vote[paper] == vote[scissors])
      return( random() % 3);
    else if (vote[rock] == vote[paper])
      return(paper);
    else if (vote[paper] == vote[scissors])
      return(scissors);
    else if (vote[scissors] == vote[rock])
      return(rock);
    else return( random() % 3); /* should never happen */
  } else {
    return( random() % 3);
  }

}
/*----------------------------------------------------------------------------*/
/******************************************************************************/



/*----------------------------------------------------------------------------*/
/*  Entrant:  Boom (10)   Jack van Rijswijk (Net)  */
/*----------------------------------------------------------------------------*/
float 
boom_getrelevance (int r, int p, int s) 
{
  float best;

  best = s-p;
  if (r-s > best) best = r-s;
  if (p-r > best) best = p-r;

  return (best/(r+p+s+5));
}
/*----------------------------------------------------------------------------*/
int 
boom_rotate (int rps, int increment) 
{
  rps = (rps+increment) % 3;
  if (rps < 0) rps += 3;

  return (rps);
}
/*----------------------------------------------------------------------------*/
int 
boom_rps_result (int action1, int action2) 
{
  if (action1 == action2) return(0);
  if (boom_rotate(action1,1) == action2) return(-1);

  return(1);
}
/*----------------------------------------------------------------------------*/
int 
boom () 
{
  int boom_history = 27;
  float lambda = 0.95;

  static int boom_stats[28][4][4][3];
  int boom_secondary_stats[28][4][4][3];
  static int boom_overall;
  static int boom_gear;
  static float boom_gear_success[3];
  static float boom_recent_success;

  float bail_min,bail_max,bail;
  float bail_l_min,bail_l_max,bail_l_diff;

  int turn, action;
  int i,j;
  int opp_earlier,my_earlier,opp_last,my_last;
  float best,pred_r,pred_p,pred_s;

  int filter_opp, filter_me, filter_lag;
  
  pred_r = 0; pred_p = 0; pred_s = 0;
  filter_opp = 0; filter_me = 0; filter_lag = -1;
  turn = o_history[0];

  bail_l_min = sqrt((1-lambda)/3);
  bail_l_max = sqrt(2*(1-lambda));
  bail_l_diff = bail_l_min - bail_l_max;

  if (turn == 0) { /* initialize arrays */
    int k,l;
    for (i=0; i<boom_history; i++) for (j=0; j<4; j++) for (k=0; k<4; k++)
      for (l=0; l<3; l++) boom_stats[i][j][k][l] = 0;
    boom_overall = 0;
    boom_gear = 0;
    for (i=0; i<3; i++) boom_gear_success[i] = 0;
    boom_recent_success = 0;
  }

  else { /* update statistics */

    opp_last = o_history[turn];
    my_last = m_history[turn];

    for (i=0; i<boom_history; i++) {
      if (turn-i-1 > 0) {
        opp_earlier = o_history[turn-i-1];
        my_earlier = m_history[turn-i-1];

        boom_stats[i][opp_earlier][my_earlier][opp_last]++;
        boom_stats[i][3][my_earlier][opp_last]++;
        boom_stats[i][opp_earlier][3][opp_last]++;
        boom_stats[i][3][3][opp_last]++;
      }
    }

    for (i=0; i<3; i++) boom_gear_success[i] *= lambda;
    boom_recent_success *= lambda;

    j = boom_rps_result(my_last,opp_last); /* win/tie/loss previous turn */
    if (j == -1) {
      boom_overall--;
      boom_recent_success -= 1-lambda;
      boom_gear_success[boom_gear] -= 1-lambda;
      boom_gear_success[boom_rotate(boom_gear,-1)] += 1-lambda;
    }
    else if (j == 1) {
      boom_overall++;
      boom_recent_success += 1-lambda;
      boom_gear_success[boom_gear] += 1-lambda;
      boom_gear_success[boom_rotate(boom_gear,+1)] -= 1-lambda;
    }
    else { 
      boom_gear_success[boom_rotate(boom_gear,+1)] += 1-lambda;
      boom_gear_success[boom_rotate(boom_gear,-1)] -= 1-lambda;
    }
  }

  /* check current context */
  best = 0;

  for (i=0; i<boom_history; i++) if (i<=turn) {
    int r,p,s,t;
    float w;

    opp_earlier = o_history[turn-i]; my_earlier = m_history[turn-i];

    r = boom_stats[i][opp_earlier][my_earlier][0];
    p = boom_stats[i][opp_earlier][my_earlier][1];
    s = boom_stats[i][opp_earlier][my_earlier][2];
    w = boom_getrelevance(r,p,s);
    if (w>best) {
      best = w; t = r+p+s;
      pred_r = (float) r/t; pred_p = (float) p/t; pred_s = (float) s/t;
      filter_opp = opp_earlier; filter_me = my_earlier; filter_lag = i;
    }

    r = boom_stats[i][3][my_earlier][0];
    p = boom_stats[i][3][my_earlier][1];
    s = boom_stats[i][3][my_earlier][2];
    w = boom_getrelevance(r,p,s);
    if (w>best) {
      best = w; t = r+p+s;
      pred_r = (float) r/t; pred_p = (float) p/t; pred_s = (float) s/t;
      filter_opp = 3; filter_me = my_earlier; filter_lag = i;
    }

    r = boom_stats[i][opp_earlier][3][0];
    p = boom_stats[i][opp_earlier][3][1];
    s = boom_stats[i][opp_earlier][3][2];
    w = boom_getrelevance(r,p,s);
    if (w>best) {
      best = w; t = r+p+s;
      pred_r = (float) r/t; pred_p = (float) p/t; pred_s = (float) s/t;
      filter_opp = opp_earlier; filter_me = 3; filter_lag = i;
    }

    r = boom_stats[i][3][3][0];
    p = boom_stats[i][3][3][1];
    s = boom_stats[i][3][3][2];
    w = boom_getrelevance(r,p,s);
    if (w>best) {
      best = w; t = r+p+s;
      pred_r = (float) r/t; pred_p = (float) p/t; pred_s = (float) s/t;
      filter_opp = 3; filter_me = 3; filter_lag = i;
    }
  }
  
  /* filter statistics, get second-order stats */
  /*    only if we're less than 95% sure so far */

  if ((best < 0.95) && (filter_lag >= 0)) { 
    int k,l,r,p,s,t;
    float w;

    /* reset 2nd order stats */
    for (i=0; i<boom_history; i++) for (j=0; j<4; j++) for (k=0; k<4; k++)
      for (l=0; l<3; l++) boom_secondary_stats[i][j][k][l] = 0;

    /* get 2nd order stats */
    for (i=filter_lag+2; i<=turn; i++) {
      opp_earlier = o_history[i-filter_lag-1];
      my_earlier = m_history[i-filter_lag-1];
      if (((filter_opp == 3) || (filter_opp == opp_earlier)) &&
          ((filter_me == 3) || (filter_me == my_earlier))) {
        opp_last = o_history[i];
        for (j=0; j<boom_history; j++) {
          if (i-j-1 > 0) {
            opp_earlier = o_history[i-j-1];
            my_earlier = m_history[i-j-1];
            boom_secondary_stats[j][opp_earlier][my_earlier][opp_last]++;
            boom_secondary_stats[j][3][my_earlier][opp_last]++;
            boom_secondary_stats[j][opp_earlier][3][opp_last]++;
            boom_secondary_stats[j][3][3][opp_last]++;
          }
        }
      }
    }

    /* any better information in there? */
    for (i=0; i<boom_history; i++) if (i<turn) {
      opp_earlier = o_history[turn-i]; my_earlier = m_history[turn-i];

      r = boom_secondary_stats[i][opp_earlier][my_earlier][0];
      p = boom_secondary_stats[i][opp_earlier][my_earlier][1];
      s = boom_secondary_stats[i][opp_earlier][my_earlier][2];
      w = boom_getrelevance(r,p,s);
      if (w>best) {
          best = w; t = r+p+s; 
          pred_r = (float) r/t; pred_p = (float) p/t; pred_s = (float) s/t;
      }

      r = boom_secondary_stats[i][3][my_earlier][0];
      p = boom_secondary_stats[i][3][my_earlier][1];
      s = boom_secondary_stats[i][3][my_earlier][2];
      w = boom_getrelevance(r,p,s);
      if (w>best) {
        best = w; t = r+p+s;
        pred_r = (float) r/t; pred_p = (float) p/t; pred_s = (float) s/t;
      }

      r = boom_secondary_stats[i][opp_earlier][3][0];
      p = boom_secondary_stats[i][opp_earlier][3][1];
      s = boom_secondary_stats[i][opp_earlier][3][2];
      w = boom_getrelevance(r,p,s);
      if (w>best) {
        best = w; t = r+p+s;
        pred_r = (float) r/t; pred_p = (float) p/t; pred_s = (float) s/t;
      }
    }
  }

  /* got the predicted probabilities of r-p-s -- determine suggested action */
  best = pred_s - pred_p; action = rock;
  if ((pred_r - pred_s) > best) {best = pred_r - pred_s; action = paper;}
  if ((pred_p - pred_r) > best) action = scissors;

  /* modify the action according to the gears */
  best = boom_gear_success[0]; boom_gear = 0;
  if (boom_gear_success[1] > best) {
    best = boom_gear_success[1]; boom_gear = 1;
  }
  if (boom_gear_success[2] > best) {
    best = boom_gear_success[2]; boom_gear = 2;
  }
  action = (action + boom_gear)%3;

  /* ignore the action altogether if we're losing */
  /* global bailout */
  bail_min = (float) sqrt(turn) / sqrt(3.0);
  bail_max = (float) sqrt(turn) * sqrt(2.0);
  if (bail_min < bail_max)
    bail = (float) (bail_min + boom_overall) / (bail_min - bail_max);
  else bail = 0;

  /* local bailout */
  if ((boom_recent_success + bail_l_min) / bail_l_diff > bail)
    bail = (boom_recent_success + bail_l_min) / bail_l_diff;

  if (bail < 0) bail = 0;
  if (bail > 1) bail = 1;

  /* final decision: going random this turn? */
  if (flip_biased_coin(bail))
    action = biased_roshambo((float) 1/3,(float) 1/3);

  return (action);
}
/******************************************************************************/






/*============================================================================*/
//  BEGIN OF                      B I O P I C                    
/*============================================================================*/
/*----------------------------------------------------------------------------*/
/*  Entrant:  Biopic (5)   Jonathan Schaeffer (Can)  */

/* RoShamBo -- Biopic version that switches between using opponent's and */
/* our history to decide on a strategy.                                  */
/*                                                                       */
/* Jonathan Schaeffer                                                    */
/* September 27, 1999    (debugged version, after the official event)    */

/* Shortcuts, because I am lazy */
/*----------------------------------------------------------------------------*/

#define ME           m_history
#define YOU          o_history
#define TRIAL        ME [ 0 ]
#define MY_PLAY      ME [ TRIAL ]
#define YOU_PLAY     YOU[ TRIAL ]
#define JRANDOM_MOVE return( random() % 3 );
#define INFINITY     (1<<30)

/* Application dependent parameters */
#define WSIZE        25      /* Size of a losing margin? */
#define CSIZE        10      /* Storage inefficient */
#define EV_SCALE     5       /* Used to determine a "small" value */
#define WEIGHTED             /* Bias towards more rather than less context */

extern void bzero();

static int mult[ CSIZE ];

/* Support routines */

#define EV_TTL  ttl = ev[ rock ] + ev[ paper ] + ev[ scissors ];

/*----------------------------------------------------------------------------*/
int 
BiopicMove (int * wt)
{
  int ev[ 3 ], ttl, i;

  ev[ paper    ] = wt[ rock     ] - wt[ scissors ];
  ev[ rock     ] = wt[ scissors ] - wt[ paper    ];
  ev[ scissors ] = wt[ paper    ] - wt[ rock     ];

  /* Decide */

  /* Make small values 0 */
  EV_TTL
    for( i = 0; i < 3; i++ )
      if( ev[ i ] * EV_SCALE < ttl )
        ev[ i ] = 0;

  /* Make large values big */
  EV_TTL
    for( i = 0; i < 3; i++ )
      if( ev[ i ] * 5 / 3 >= ttl )
        ev[ i ] = 99999;

  /* Decide */
  EV_TTL
    if( ttl <= 0 )
      return( biased_roshambo( (double) 1.0/3, (double) 1.0/3 ) );
    else    return( biased_roshambo( (double) ev[ rock  ] / ttl,
                                    (double) ev[ paper ] / ttl ) );

}
/*----------------------------------------------------------------------------*/
void 
BiopicWeight (int wt[], short int * context[], int * history)
{
  int i, j, ptr[ CSIZE ];

  /* Get indices into context */
  for( j = i = 0; i < CSIZE && TRIAL - i > 0; i++ )
    ptr[ i ] = ( j += history[ TRIAL - i ] * mult[ i ] ) * 3;

  /* Process context */
  wt[ rock ] = wt[ paper ] = wt[ scissors ] = 0;
  for( i = 0; i < CSIZE; i++ )
  {
    if( TRIAL - i <= 0 )
      continue;
    for( j = 0; j < 3; j++ )
      wt[ j ] += context[ i ][ ptr[ i ] + j ]
#ifdef WEIGHTED
        * mult[ i ]
#endif
        ;
  }
}
/* This is it! */
/*----------------------------------------------------------------------------*/
int 
biopic ()
{
  static int score = -INFINITY;
  static int gorandom, move[ 4 ], sc[ 4 ], freq[ 2 ][ 3 ];
  /* Short int limits matches to 32K */
  static short int * myh[ CSIZE ], * oph[ CSIZE ];

  int i, j, ix, wt[3];

  /*
    *
    * Initialize
    *
    */

  /* (1) First time the bot is run */
  if( score == -INFINITY )
  {
    for( i = 1, ix = 3; i < CSIZE; i++, ix *= 3 )
      mult[ i ] = ix;
    mult[ 0 ] = 1;
    for( i = 0, ix = 3; i < CSIZE; i++, ix *= 3 )
    {
      myh[ i ] = malloc( ix * sizeof(short int) * 3 );
      oph[ i ] = malloc( ix * sizeof(short int) * 3 );
    }
  }

  /* (2) First hand of a match */
  if( TRIAL == 0 )
  {
    score = gorandom = 0;
    for( i = 0; i < 4; sc[ i++ ] = 0 );
    for( i = 0; i < 3; i++ )
      freq[ 0 ][ i ] = freq[ 1 ][ i ] = 0;
    for( i = 0, ix = 3; i < CSIZE; i++, ix *= 3 )
    {
      bzero( myh[ i ], ix * sizeof(short int) * 3 );
      bzero( oph[ i ], ix * sizeof(short int) * 3 );
    }
  }

  /* (3) Last hand of the match */

  /* Statistics -- deleted */


  /* First hand - make a random move */
  if( TRIAL <= 0 )
    JRANDOM_MOVE



      /*
        *
        * Process previous game
        *
        */

      /* (1) How is the match going? */
      if( ( MY_PLAY - YOU_PLAY ==  1 ) ||
         ( MY_PLAY - YOU_PLAY == -2 ) )
        score += 1;
      else if( ( YOU_PLAY - MY_PLAY ==  1 ) ||
              ( YOU_PLAY - MY_PLAY == -2 ) )
        score += -1;

  /* (2) Save context */
  freq[ 0 ][ ME [ TRIAL ] ]++;
  freq[ 1 ][ YOU[ TRIAL ] ]++;

  /* (3) How good are our predictions? */
  if( TRIAL > 1 )
  {
    for( i = 0; i < 4; i++ )
      if( ( ( move[ i ] + 2 ) % 3 ) == YOU_PLAY )
        sc[ i ]++;
  }

  /* (4) Update context strings */
  for( j = YOU[TRIAL], i = 1; i <= CSIZE && TRIAL-i > 0; i++ )
    oph[ i-1 ][ j += YOU[ TRIAL-i ] * 3 * mult[ i-1 ] ]++;
  for( j = YOU[TRIAL], i = 1; i <= CSIZE && TRIAL-i > 0; i++ )
    myh[ i-1 ][ j += ME [ TRIAL-i ] * 3 * mult[ i-1 ] ]++;

  /* Periodically scale back results so that the program can */
  /* switch strategies.                      */
  if( ( TRIAL % 32 ) == 0 )
  {
    for( i = 0; i < 3; i++ )
    {
      freq[ 0 ][ i ] >>= 1;
      freq[ 1 ][ i ] >>= 1;
    }
    for( i = 0; i < 4; sc[ i++ ] >>= 1 );
  }



    /*
     *
     * Use 4 special cases and 4  prediction models
     *
     *
     */

    /* (1) First move */
    /* Taken care of above */

    /* (2) If down too far, go random */
  if( score < -WSIZE )
    JRANDOM_MOVE

    /* (3) Make a random move to confuse the opponent */
    if( gorandom )
    {
        if( (--gorandom) >= 8 )
            JRANDOM_MOVE
    }

    /* (4) If things not going well with our predicitons, make */
    /* random moves for a while to confuse the opponent        */
    if( score <= -10 && gorandom == 0 )
    {
        gorandom = 16;
        JRANDOM_MOVE
    }

    /* (5) Use tables to predict next move using opponent info */
    /* Prediction 1                                            */
    BiopicWeight( wt, oph, YOU );
    move[ 0 ] = BiopicMove( wt );

    /* (6) Use tables to predict next move using our info   */
    /* Prediction 2                                         */
    BiopicWeight( wt, myh, ME );
    move[ 1 ] = BiopicMove( wt );

    /* (7) Check the frequency of the opponent's actions    */
    /* Prediction 3                                         */
    move[ 2 ] = BiopicMove( &freq[ 0 ][ 0 ] );

    /* (8) Check the frequency of the opponent's actions    */
    /* Prediction 4                                         */
    move[ 3 ] = BiopicMove( &freq[ 1 ][ 0 ] );

    /* Finally, we decide which strategy to use             */
    /* Use maximum sc for the move                          */
    for( j = 0, i = 1; i < 4; i++ )
      if( sc[ i ] > sc[ j ] )
        j = i;
    /* Ta da */
    return( move[ j ] );
}
/*----------------------------------------------------------------------------*/
/*============================================================================*/
//  END OF                        B I O P I C                    
/*============================================================================*/






/*============================================================================*/
//  BEGIN OF               S I M P L E   M O D E L L E R         
/*============================================================================*/
/*----------------------------------------------------------------------------*/

/*  Entrant:  Simple Modeller (7)   Don Beal (UK)

 The simple predictor counts the number of times r/p/s occurred
 after each of the possible move events.  In addition to the 9
 possible r/p/s combinations for the two players, counts are kept
 ignoring the player move, ignoring the opponent move, or both,
 leading to 16 sets of counts.  The predictor then selects the
 count set that has the most extreme distribution, and plays
 against that.  The play against a given distribution is obtained
 by calculating the expected return of each play, and selecting the
 play with the best return.
 
 The idea to select the most extreme distribution (instead of the
 distribution in which we have the greatest confidence) was an
 experiment - I thought it might promote information gathering
 plays, and aggressively exploit easily-predictable opponents
 earlier than cautious approaches would.  It had the accidental
 advantage of being harder to predict!
 
 The simple modeller keeps the same information as the simple
 predictor, but for both players.  It can therefore counter an
 opponent using a similar counting technique.  To choose the count
 set to play against, the simple modeller keeps track of past
 performance (the score we would have if we had used that count set
 for all the moves so far).  The simple modeller then plays against
 the count set with the highest score.  If no count set shows a
 positive score, it plays at random.
 
 Both programs exponentially decay their memory of past plays to
 improve performance against opponents who change their strategy
 over time.
 
 [Both programs were written hastily and not very readably - sorry
 about that!]
  --
  Don Beal
*/
/*----------------------------------------------------------------------------*/

static double c0,c1,c2,u0,u1,u2,b;  int bm;

#define SETC(x)  c0=c[x];  c1=c[x+1]; c2=c[x+2];
#define SETD(x)  c0=d[x];  c1=d[x+1]; c2=d[x+2];
#define SETU     u0=c2-c1; u1=c0-c2;  u2=c1-c0;
#define SETBM    b=u0; bm=0; if (u1>b) {b=u1;bm=1;}; if (u2>b) {b=u2;bm=2;}
#define BEATBM   bm=(bm+1)%3;
#define SCORE(m,o) (m==o?0:(((o+1)%3)==m?1:-1))

#define SET_ARR(arr, x)  c0=arr[x];  c1=arr[x+1]; c2=arr[x+2];

/*----------------------------------------------------------------------------*/
void 
set_values (int is_D, double arr[], int ind, int o) 
{

  if (arr[ind+3] > 0) { 

    SET_ARR(arr, ind); SETU; SETBM; 
    if (is_D) BEATBM; 
    arr[ind+4]+=SCORE(bm,o); arr[ind+5]+=1; 
  }

  return;
}
/*----------------------------------------------------------------------------*/
void 
sets_proc (int history_length, int is_D, double c[], int i, int j, int k, int l, int o) 
{

  if (history_length > 2) { 

    set_values (is_D, c, i, o); 

    set_values (is_D, c, j, o); 

    set_values (is_D, c, k, o); 

    set_values (is_D, c, l, o); 
  }

}
/*----------------------------------------------------------------------------*/
int 
mod1bot ()  /* Don Beal (UK) simple model builder */
{   
  static double c[96], d[96], fade=0.98;
  /* c[i+4]+=score(bplay(&c[i]),o); */
  /* md=bplay(&d[i]); d[i+4]+=score((md+1)%3,o); */

  int i, j, k, l, m, m1, o, o1, s, id;
  double q, qi, qj, qk, ql, qd;
  int history_length = m_history[0];
  m = 0; m1 = 0; o = 0; o1 = 0; /* -db */

  //fprintf (stderr, "1........ \n");

  if (history_length > 0) { 
    o = o_history[history_length];
    m = m_history[history_length];
  }

  if (history_length > 1) { 
    o1 = o_history[history_length-1];
    m1 = m_history[history_length-1];
  }

  if (history_length == 0) { 
    for (i=0; i<96; i++) 
      c[i] = d[i] = 0;   
  }

  if (history_length > 1) { 

    //----------------------------------------
    i = o1*24 + m1*6; 
    j = o1*24 +  3*6; 
    k =  3*24 + m1*6; 
    l =  3*24 +  3*6;

    sets_proc (history_length, FALSE, c, i, j, k, l, o); 

    c[i+o]+=1;  c[j+o]+=1;  c[k+o]+=1; c[l+o]+=1;
    c[i+3]+=1;  c[j+3]+=1;  c[k+3]+=1; c[l+3]+=1;
    //----------------------------------------


    //----------------------------------------
    i = m1*24 + o1*6; 
    j = m1*24 +  3*6; 
    k =  3*24 + o1*6; 
    l =  3*24 +  3*6;

    sets_proc (history_length, TRUE, d, i, j, k, l, o); 

    d[i+m]+=1;  d[j+m]+=1;  d[k+m]+=1; d[l+m]+=1;
    d[i+3]+=1;  d[j+3]+=1;  d[k+3]+=1; d[l+3]+=1;
    //----------------------------------------

  }

  if (history_length > 50)
    for (i=0; i<96; i++) { 
      c[i] = c[i]*fade;  
      d[i] = d[i]*fade; 
    }

  if      (history_length==0)   return (random() % 3);
  else if (history_length==1)   return ((o+1) % 3);
  else
  { 
    id=m*24+o*6;  SETD(id); SETU; SETBM; BEATBM;
    qd= d[id+5]>0? d[id+4]/d[id+5]:0;

    i=o*24+m*6; j=o*24+3*6; k=3*24+m*6; l=3*24+3*6;

    // скорee всeго тут дeлeниe на нуль ?

    qi= c[i+5]>0? c[i+4]/c[i+5] : 0;
    qj= c[j+5]>0? c[j+4]/c[j+5] : 0;
    qk= c[k+5]>0? c[k+4]/c[k+5] : 0;
    ql= c[l+5]>0? c[l+4]/c[l+5] : 0;

    //fprintf (stderr, "2........ \n");

    q=qi; s=i;

    if (qj > q) { q=qj; s=j; }
    if (qk > q) { q=qk; s=k; }
    if (ql > q) { q=ql; s=l; }
    if (qd > q && qd > 0) 
      return (bm);

    SETC(s); SETU; SETBM;
    if (q > 0) 
      return (bm);

    return (random() % 3);
  }

#undef SETC
#undef SETD
#undef SETU
#undef SETBM
#undef BEATBM
#undef SCORE
}
/*----------------------------------------------------------------------------*/
/*============================================================================*/
//  END OF                 S I M P L E   M O D E L L E R                
/*============================================================================*/





/*============================================================================*/
//  BEGIN OF              S I M P L E   P R E D I C T O R
/*============================================================================*/
/*----------------------------------------------------------------------------*/
/*  Entrant:  Simple Predictor (14)   Don Beal (UK)  */
/*----------------------------------------------------------------------------*/
void 
gena_devide_null (double *qindex, double *c, int index)
{

    //fprintf (stderr, "qi=%f  c[i+3]=%50.40f \n", qi, c[i+3]);
    // идeт дeлeниe на 0, котороe "нe замeчают" Си и CLISP, однако
    // даeт прeрываниe SBCL..
    // 
    // попробуeм вставить провeрку?

    if (c[index + 3] == 0) {
      //fprintf (stderr, "c[index+3] == 0  *qindex= %f \n", *qindex);
      //*qindex = 0;
      *qindex = 99999999999; // попробуeм смодeлировать nan
      // всe получилось, т.e. повторили вeтку алгоритма, однако вопрос остался
    }
    else 

    *qindex = *qindex / c[index + 3];

    //if (c[index + 3] == 0) {
    //  fprintf (stderr, "*qindex= %f \n", *qindex); // посмотрим что получаeтся
      // *qindex= nan - и куда это потом идeт?
    //}
}
/*----------------------------------------------------------------------------*/

int 
predbot ()
{
  static double c[64]; 
 
  int history_length = m_history[0];
  int i, j, k, l, m, m1, o, o1, s, mr, mp, ms, mb;
  double q, qi, qj, qk, ql;
  
  //fprintf (stderr, "predbot BEG \n");

  if (history_length==0)
  { 
    for (i=0; i<64; i++) c[i]=0; // почeму 64 ??
    return (random() % 3);
  }
  else {
    o = o_history[history_length];
    m = m_history[history_length];

    if (history_length>1)
    { 
      o1 = o_history[history_length-1];
      m1 = m_history[history_length-1];

      i=o1*16+m1*4+o; j=o1*16+3*4+o; k=3*16+m1*4+o; l=3*16+3*4+o;

      c[i]    +=1;  c[j]    +=1;  c[k]    +=1; c[l]    +=1;
      c[i+3-o]+=1;  c[j+3-o]+=1;  c[k+3-o]+=1; c[l+3-o]+=1;
    }

    for (i=0; i<64; i++) c[i] = c[i] * 0.98;
    i = o*16 + m*4; 
    j = o*16 + 3*4; 
    k = 3*16 + m*4; 
    l = 3*16 + 3*4;

    for (qi=c[i], m=1; m<3; m++) if (c[i+m] > qi) qi=c[i+m];  
    //qi=qi/c[i+3];
    gena_devide_null (&qi, c, i);

    for (qj=c[j], m=1; m<3; m++) if (c[j+m] > qj) qj=c[j+m];  
    //qj=qj/c[j+3];
    gena_devide_null (&qj, c, j);

    for (qk=c[k], m=1; m<3; m++) if (c[k+m] > qk) qk=c[k+m];  
    //qk=qk/c[k+3];
    gena_devide_null (&qk, c, k);

    for (ql=c[l], m=1; m<3; m++) if (c[l+m] > ql) ql=c[l+m];  
    //ql=ql/c[l+3];
    gena_devide_null (&ql, c, l);

    q = qi;  s = i;

    if (qj > q) { q=qj; s=j; }
    if (qk > q) { q=qk; s=k; }
    if (ql > q) { s=l; }

    mr= c[s+2]-c[s+1];
    mp= c[s]  -c[s+2];
    ms= c[s+1]-c[s];

    mb = mr;  m = rock;

    if (mp > mb) { mb=mp;  m=paper; }
    if (ms > mb) m = scissors;

    //fprintf (stderr, "predbot END \n");

    return (m);
  }
}
/*============================================================================*/
//  END OF              S I M P L E   P R E D I C T O R
/*============================================================================*/
/*----------------------------------------------------------------------------*/







/*============================================================================*/
//  BEGIN OF                    B U G B R A I N                       
/*============================================================================*/
/*----------------------------------------------------------------------------*/
/*  Entrant:  Bugbrain (12) and Knucklehead (52)   Sunir Shah (Can)

 I released the source code to Bugbrain and Crazybot in comp.ai.games.
 I hereby donate the code to the the tournament to be used for any purpose
 it wishes except for a) allowing someone else to enter the bot under their
 name, b) allowing distribution of the code without a byline that reads
 
 Sunir Shah's Roshambo bots [Sept'99].
 
 There are no guarantees these bots will do anything positive or
 negative.
 
 You may distribute this code as long as this comment exists in the source
 file. You may NOT enter any of these bots in any competition under any
 name but mine or without my permission.
 
 I can be contacted at sshah@intranet.ca.
 
 I suspect Bugbrain would be a better test to weed out weak bots than say
 Iocaine Powder! Bugbrain detects and exloits bots that have inheritantly
 static (and thus weak) strategies. cf. my post in comp.ai.games.
*/
/*----------------------------------------------------------------------------*/

/* -----------------------------------------------------------
**                     SUNIR'S ENTRIES
** -----------------------------------------------------------
*/

/* Uncomment to have the bots track information between 
** tournaments

#define sunPERSISTANT
*/

/* ----------------------------------------- Sunir's Utilities */

#define sunMYPREVTURN(x) (m_history[m_history[0] - (x) + 1])
#define sunOPPPREVTURN(x) (o_history[o_history[0] - (x) + 1])

#define sunMYLASTTURN sunMYPREVTURN(1)
#define sunOPPLASTTURN sunOPPPREVTURN(1)

#define sunNUMELEM(x) (sizeof (x) / sizeof *(x))

#define sunPI 3.141592654

/*----------------------------------------------------------------------------*/
/* Returns -1 on a loss, 0 on a tie, 1 on a win */
/*----------------------------------------------------------------------------*/
int 
sunRoshamboComparison ( int me, int opp )
{
  static int aiCompareTable[] = {
    paper, /* rock */
    scissors, /* paper */
    rock, /* scissors */
  };

  if( me == opp )
    return 0;

  return (aiCompareTable[me] == opp) ? -1 : 1;
}

typedef struct 
{
  int iCurrentPlayer;
} sunPLAYERTRACKER;

/*----------------------------------------------------------------------------*/
// здесь закомментировал, т.к. непонятно откуда брать "players"
// 
#ifdef Comment_Block 
/*----------------------------------------------------------------------------*/
/* Keeps track of which player I'm playing against */
/*----------------------------------------------------------------------------*/
int 
sunTrackPlayer ( sunPLAYERTRACKER *pTracker  )
{
  if( !pTracker )
    return 0;

  if( !m_history[0] )
  {
    pTracker->iCurrentPlayer = (pTracker->iCurrentPlayer + 1) % players;
    //!!!!!!!!!!! зачем тут знание колв-ва игроков в турнире ??!!
    //pTracker->iCurrentPlayer = (pTracker->iCurrentPlayer + 1) % /* players */PLAYERS;
  }

  return pTracker->iCurrentPlayer;
}
/* ------------------------------------------ Sunir's Crazybot */

typedef struct
{
    int bInitialized;
    int iLastTurn;
    int aiTransform[3];
    double dShuffleProbability;
} sunCRAZYBOT;

/*----------------------------------------------------------------------------*/
/* Sets the transform table to a new random ordered set */
/*----------------------------------------------------------------------------*/
void 
sunShuffleCrazybotPlayer ( sunCRAZYBOT *pPlayer )
{       
    int i = 3;
    while( i-- )
        pPlayer->aiTransform[i] = biased_roshambo(1.0/3,1.0/3);

    pPlayer->dShuffleProbability = 0.0;
}
/*----------------------------------------------------------------------------*/
void 
sunInitializeCrazybotPlayer ( sunCRAZYBOT *pPlayer )
{
    pPlayer->bInitialized = 1;
    sunShuffleCrazybotPlayer( pPlayer );
}
/*----------------------------------------------------------------------------*/

/* If it ain't winnin', it might just punch itself in the head
** outta shear crazyness.
*/
/*----------------------------------------------------------------------------*/
int sunCrazybot()
{
#if defined(sunPERSISTANT)
  static sunCRAZYBOT aPlayers[/* players */PLAYERS]; /* = {0}; */

  /* Created to get rid of GCC warning for above commented code */
  static int bPlayerArrayZeroed = 0;

  static sunPLAYERTRACKER Tracker = {0};

  sunCRAZYBOT *pPlayer = &aPlayers[sunTrackPlayer(&Tracker)];

  if( !bPlayerArrayZeroed )
  {
    bPlayerArrayZeroed = 1;
    memset( aPlayers, 0, sizeof aPlayers );
  }
#else
  static sunCRAZYBOT Player;
  sunCRAZYBOT *pPlayer = &Player;

  /* Reset the player data if we're on a new player */
  if( !m_history[0] )
    pPlayer->bInitialized = 0;
#endif

  if( !pPlayer->bInitialized )
    sunInitializeCrazybotPlayer( pPlayer );

  if( m_history[0] )
  {
    int iResult = sunRoshamboComparison( sunMYLASTTURN, sunOPPLASTTURN );

    if( iResult < 0 )
      pPlayer->dShuffleProbability += 0.1;
    else if( iResult == 0 )
      pPlayer->dShuffleProbability += 0.05;
  }

  if( flip_biased_coin( pPlayer->dShuffleProbability ) )
    sunShuffleCrazybotPlayer( pPlayer );

  return pPlayer->iLastTurn = pPlayer->aiTransform[pPlayer->iLastTurn];
}
/*----------------------------------------------------------------------------*/
// 
#endif //Comment_Block 
// 
/*----------------------------------------------------------------------------*/
/* ------------------------------------------ Sunir's Nervebot */

typedef struct 
{
    int bInitialized;

    /* [ways of arranging my last turn]
    ** [ways of arranging opponent's last turn]
    ** [ways of arranging my next turn]
    */
    double adProbabilities[3][3][3];    
} sunNERVEBOT;

/*----------------------------------------------------------------------------*/
/* Sets the player's matrix to initially random probabilities,
** taking care to ensure the probabilities sum to 1.0 for each
** input vector.
*/
/*----------------------------------------------------------------------------*/
void 
sunInitializeNervebotPlayer ( sunNERVEBOT *pPlayer )
{       
  int i, j;

  pPlayer->bInitialized = 1;

  for( i = 3; i--; )
  for( j = 3; j--; )
  {
    pPlayer->adProbabilities[i][j][0] = 
      (double)random() / (double)maxrandom;

    pPlayer->adProbabilities[i][j][1] =
      ((double)random() / (double)maxrandom)
      * (1.0 - pPlayer->adProbabilities[i][j][0]);

    pPlayer->adProbabilities[i][j][2] =
      1.0 
      - pPlayer->adProbabilities[i][j][0] 
      - pPlayer->adProbabilities[i][j][1];                     
  }
}
/*----------------------------------------------------------------------------*/
/* These are magic numbers */
double 
sunNerveAttenuateLoss ( double dValue )
{
  /* Pulls value towards 0.0 */
  return dValue * 0.8;
}
/*----------------------------------------------------------------------------*/
double 
sunNerveAttenuateTie ( double dValue )
{
  /* Pulls value towards 0.0 */
  return dValue * 0.9;
}
/*----------------------------------------------------------------------------*/
double 
sunNerveAttenuateWin ( double dValue )
{
  /* Pulls value towards 1.0 but never exceeds 1.0 */
  return (dValue - 1.0) * 0.8 + 1.0;
}
/*----------------------------------------------------------------------------*/
/* Uses a nervous network whose input vector is 
** (my last turn, opponents last turn)
*/
/*----------------------------------------------------------------------------*/
int 
sunNervebot ()
{
  /* Attenuate from last turn */
  int iResult = sunRoshamboComparison(sunMYLASTTURN, sunOPPLASTTURN);

  static double (*apfnAttenuations[])( double dValue) = {
    sunNerveAttenuateLoss,
    sunNerveAttenuateTie,
    sunNerveAttenuateWin,
  };

  double dDelta;
  int iNextProbability, iOtherProbability;
  double dNextProbability, dOtherProbability;

#if defined(sunPERSISTANT)      
  static sunNERVEBOT aPlayers[/* players */PLAYERS]; /* = {0}; */

  /* Created to get rid of GCC warning for above commented code */
  static int bPlayerArrayZeroed = 0;  

  static sunPLAYERTRACKER Tracker = {0};

  sunNERVEBOT *pPlayer = &aPlayers[sunTrackPlayer(&Tracker)];

  if( !bPlayerArrayZeroed )
  {
    bPlayerArrayZeroed = 1;
    memset( aPlayers, 0, sizeof aPlayers );
  }
#else
  static sunNERVEBOT Player;
  sunNERVEBOT *pPlayer = &Player;

  /* Reset the player data if we're on a new player */
  if( !m_history[0] )
    pPlayer->bInitialized = 0;
#endif

  if( !pPlayer->bInitialized )
    sunInitializeNervebotPlayer( pPlayer );

  /* First turn */
  if( !m_history[0] )
    return biased_roshambo(1.0/3,1.0/3);

  /* Reward/punish based on last turn's vector and result */
  dDelta = pPlayer->adProbabilities[sunMYPREVTURN(2)][sunOPPPREVTURN(2)][sunMYLASTTURN];

  pPlayer->adProbabilities[sunMYPREVTURN(2)][sunOPPPREVTURN(2)][sunMYLASTTURN]
    = apfnAttenuations[iResult+1](dDelta);

  dDelta -= pPlayer->adProbabilities[sunMYPREVTURN(2)][sunOPPPREVTURN(2)][sunMYLASTTURN];

  /* Propogate the delta throughout the remaining probabilities */
  iNextProbability = (sunMYLASTTURN + 1) % 3;
  iOtherProbability = (iNextProbability + 1) % 3;

  dNextProbability = pPlayer->adProbabilities[sunMYPREVTURN(2)][sunOPPPREVTURN(2)][iNextProbability];
  dOtherProbability = pPlayer->adProbabilities[sunMYPREVTURN(2)][sunOPPPREVTURN(2)][iOtherProbability];

  /* Distributes the delta weighted to the magnitude of the
    ** two other choices' respective probabilities
    */
  dDelta = dDelta * dNextProbability / (dNextProbability + dOtherProbability);

  pPlayer->adProbabilities[sunMYPREVTURN(2)][sunOPPPREVTURN(2)][iNextProbability]
    += dDelta;

  pPlayer->adProbabilities[sunMYPREVTURN(2)][sunOPPPREVTURN(2)][iOtherProbability] =
    1.0 
    - pPlayer->adProbabilities[sunMYPREVTURN(2)][sunOPPPREVTURN(2)][iNextProbability]
    - pPlayer->adProbabilities[sunMYPREVTURN(2)][sunOPPPREVTURN(2)][sunMYLASTTURN];

  /* React to new vector */
  return biased_roshambo( 
                         pPlayer->adProbabilities[sunMYLASTTURN][sunOPPLASTTURN][rock],
                         pPlayer->adProbabilities[sunMYLASTTURN][sunOPPLASTTURN][paper] );
}

/* ------------------------------------------- Sunir's #undefs */

#undef sunMYLASTTURN
#undef sunOPPLASTTURN 

#undef sunMYPREVTURN
#undef sunOPPPREVTURN 

#undef sunNUMELEM

#undef sunPI

#if defined(sunPERSISTANT)
#undef sunPERSISTANT
#endif

/*----------------------------------------------------------------------------*/
/*============================================================================*/
//  END OF                      B U G B R A I N                       
/*============================================================================*/





/*============================================================================*/
//  BEGIN OF                   M E G A H A L         
/*============================================================================*/
/*----------------------------------------------------------------------------*/

/*  Entrant:  MegaHAL (3)   Jason Hutchens (Aus)

 MegaHAL     (from: http://ciips.ee.uwa.edu.au/~hutch/puzzles/roshambo/)
 
 MegaHAL, named in honour of a conversation simulator of mine, was my entry
 into the First International RoShamBo Programming Competition, which was
 conducted by Darse Billings. MegaHAL came third in the competition, behind
 the excellent Iocaine Powder of Dan Egnor, and Phasenbott by Jakob
 Mandelson. This web page is a brief attempt to explain how the MegaHAL
 algorithm works.
 
 Source Code
 
 Please feel free to download the source code to the MegaHAL algorithm. To
 compile it with Darse's tournament program (available from the competition
 home page), I recommend that you modify the tournament program by adding an
 external declaration to the halbot() function, and then linking the code as
 follows:
 
 gcc -o roshambo roshambo.c megahal.c
 
 I have also written a simple program which allows a human being to play
 against a RoShamBo algorithm. You may compile that as follows:
 
 gcc -o shell shell.c megahallc -lcurses
 
    * megahal.c (18Kb)
    * shell.c (15Kb)
 
 Prediction
 
 My opinion, as I have stated on the comp.ai.games newsgroup often enough,
 is that Darse's competition provides an ideal test-bed for predictive
 algorithms, or predictors. I have worked with predictors for the last five
 years, applying them to various syntactic pattern recognition problems,
 speech recognition, text generation and data compression.
 
 A predictor is an algorithm which is able to predict the next symbol in a
 sequence of symbols as a probability distribution over the alphabet of
 symbols. The only information available to the predictor is the history of
 symbols seen so far. In order to turn a predictor into a RoShamBo algorithm,
 we need to decide what the history of symbols should be, and how to turn a
 prediction into a RoShamBo move.
 
 Determining the history
      Because we are trying to predict our opponent's next move, and because
      our opponent may be using our previous moves to decide what they're
      going to do, it seems reasonable to make the symbol sequence an
      interlacing of both our histories: x1,y1,x2,y2,..., xn-1,yn-1, where x
      represents our opponent's move, y represents our move, and our job is
      to predict the value of xn in order to determine what yn should be.
 Choosing our move
      Once we have a prediction for yn in the form of a probability
      distribution over all possible moves, we need to decide what our move
      is going to be. We do this by choosing the move which maximises the
      expected value of our score. For example, imagine that the prediction
      gives P(rock)=0.45, P(paper)=0.15, P(scissors)=0.40. The maximum
      likelihood move (paper) gives an expected score of 1*0.45-1*0.40=0.05,
      while the defensive move of rock gives an expected score of
      1*0.40-1*0.15=0.25, and is therefore chosen.
 
 With these two modifications, any predictor may play RoShamBo!
 
 The MegaHAL Predictor
 
 MegaHAL is a very simple "infinite-order" Markov model. It stores frequency
 information about the moves the opponent has made in the past for all
 possible contexts (from a context of no symbols at all right up to a context
 of the entire history). In practise, the context is limited to forty-two
 symbols so that the algorithm satisfies the time constraint of playing one
 game every millisecond on average.
 
 MegaHAL stores this information in a ternary trie. Each context is
 represented as a node in this trie. Every time MegaHAL is asked to make a
 move, many of these nodes may activate, and each of them is capable of
 providing us with a prediction about what's coming next. We need to select
 one of them. We do this by storing in each node the average score that that
 node would have if it had been used exclusively in the past. We select the
 node which has the highest average score. If more than one node qualifies,
 we choose the one which takes the longest context into account.
 
 In some situations, no nodes will be selected. In this situation, we make a
 move at random.
 
 MegaHAL also gathers statistics over a sliding window, which means that it
 "forgets" about events which occurred a long time ago. This process allows
 MegaHAL to adapt more rapidly to changes in its opponents strategy. In the
 competition version, a sliding window of four hundred symbols was used (a
 match consists of two thousand symbols).
 
 Conclusion
 
 I hope that brief explanation of the MegaHAL strategy has been enlightening.
 I apologise for any omissions or poor English, and blame that on the fact
 that it was written at 12:45pm on a Saturday night, following a night out
 with friends!
*/
/*----------------------------------------------------------------------------*/
/*
 *  Copyright (C) 1999 Jason Hutchens
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the Free
 *  Software Foundation; either version 2 of the license or (at your option)
 *  any later version.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the Gnu Public License for more
 *  details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  675 Mass Ave, Cambridge, MA 02139, USA.
 */
/*----------------------------------------------------------------------------*/
/*
 *      NB:      File displays best with tabstops set to three spaces.
 *
 *      Name:      MegaHAL (in honour of http://ciips.ee.uwa.edu.au/~hutch/hal/)
 *
 *      Author:   Jason Hutchens (hutch@amristar.com.au)
 *
 *      Purpose:   Play the game of Rock-Paper-Scissors.  Statistics about the
 *               game so far are recorded in a ternary trie, represnting an
 *               infinite-order Markov model.  The context which has performed
 *               best in the past is used to make the prediction, and we
 *               gradually fall-back through contexts which performed less well
 *               when the contexts haven't yet been observed.  One of the
 *               contexts is always guaranteed to make a move at random, so
 *               we never encounter a situation where we can't make a move.
 *               Statistics are gathered over a sliding window, allowing
 *               adaption if the opponent's strategies change.
 *
 *      $Id: megahal.c,v 1.8 1999/09/16 03:18:27 hutch Exp hutch $
 */
/*----------------------------------------------------------------------------*/


//int halbot (void);
static int halbot_compare (const void *, const void *);

/*----------------------------------------------------------------------------*/
/*
 *      Function:   halbot
 *
 *      Arguments:   void
 *
 *      Returns:      An integer between 0 and 2, representing the move that the
 *                  predictor makes in the game of Rock-Paper-Scissors.
 *
 *      Overview:   The program collects statistics about the game using an
 *                  infinite context Markov model, which is stored in a ternary
 *                  trie.  The procedure is to update the statistics of the
 *                  model with the latest moves, and remove the statistics of
 *                  moves outside a sliding window of defined length.  We build
 *                  an array of contexts which make valid predictions, including
 *                  the special context which always predicts at random, and we
 *                  sort this according to how well the contexts have performed
 *                  in the recent past (again with the sliding window).  The
 *                  best context is then used to make the prediction, and our
 *                  move is selected in order to maximise the expected value of
 *                  the score.  The bot monitors how much time it's been
 *                  spending, and emits a message when this time exceeds an
 *                  average of one millisecond per move (i.e. one second per
 *                  one thousand moves).
 *
 *      Comment:      Even though it's really messy, everything is done in this
 *                  one function to allow it to be added to the competition
 *                  source code easily.
 */
/*----------------------------------------------------------------------------*/
int 
halbot (void)
{
  /*
    *      Set this to a non-zero value to emit an warning message if the
    *      algorithm averages more than one millisecond per move.
    */
#define   ERROR      0
   /*
    *      These defines are the three heuristic parameters that can be modified
    *      to alter performance.  BELIEVE gives the number of times a context
    *      must be observed before being used for prediction, HISTORY gives the
    *      maximum context size to observe (we're limited by time, not memory),
    *      and WINDOW gives the size of the sliding window, 0 being infinite.
    *
    *      - BELIEVE>=1
    *      - HISTORY>=1
    *      - WINDOW>=HISTORY or 0 for infinite
    */
#define   BELIEVE   1
#define   HISTORY   21
#define   WINDOW   200
   /*
    *      This define just makes the code neater (huh, as if).
    */
#define   COUNT      trie[context[i].node].move
#define   SCOUNT   trie[sorted[i].node].move
   /*
    *      These macros returns the maximum/minimum values of two expressions.
    */
// gena: уже есть определения в Glib ...
// 
/* #define   MAX(a,b)   (((a)>(b))?(a):(b)) */
/* #define   MIN(a,b)   (((a)<(b))?(a):(b)) */
   /*
    *      Each node of the trie contains frequency information about the moves
    *      made at the context represented by the node, and where the sequent
    *      nodes are in the array.
    */
   typedef struct S_NODE {
      short int total;
      short int move[3];
      int next[3];
   } NODE;
   /*
    *      The context array contains information about contexts of various
    *      lengths, and this is used to select a context to make the prediction.
    */
   typedef struct S_CONTEXT {
      int worst;
      int best;
      int seen;
      int size;
      int node;
   } CONTEXT;
   /*
    *      This is the only external information we have about our opponent;
    *      it's a history of the game so far.
    */
   //extern int m_history[];
   //extern int o_history[];
   /*
    *      We declare all variables as statics because we want most of them to
    *      be persistent.
    */
   static int move=-1;
   static int last_move=-1;
   static int random_move=-1;
   static NODE *trie=NULL;
   static int trie_size=0;
   static int context_size=0;
   static CONTEXT *context=NULL;
   static CONTEXT *sorted=NULL;
   static int **memory=NULL;
   static int remember=0;
   static struct timeval start;
   static struct timeval end;
   static long think;
   static int node;
   static int expected[3];
   /*
    *      But you canny have static register variables!
    */
   register int i,j;
   /*
    *      Start the timer.
    */
   (void) gettimeofday (&start, NULL);
   /*
    *      If this is the beginning of the game, set some things up.
    */
   if (m_history[0]==0) {
     if (trie==NULL) {
       /*
         *      If this is the first game we've played, initialise the memory.
         *      On some Unices, realloc doesn't work with NULL arguments, so
         *      we're just making sure they're non-NULL.
         *
         *      NB: We must allocate two elements for the context!
         */
       context = (CONTEXT *) malloc (sizeof(CONTEXT)*(HISTORY+2));
       assert (context);
       sorted = (CONTEXT *) malloc (sizeof(CONTEXT)*(HISTORY+2));
       assert (sorted);
       if (WINDOW>0) {
         memory = (int **) malloc (sizeof(int *)*WINDOW);
         assert (memory);
         for(i=0; i<WINDOW; ++i) {
           memory[i] = (int *) malloc (sizeof(int)*(HISTORY+2));
           assert (memory[i]);
         }
       }
       trie = (NODE *) malloc (sizeof(NODE));
       assert (trie);
     }
     /*
       *      Clear the trie, by setting its size to unity, and clearing the
       *      statistics of the root node.
       */
     trie_size = 1;
     trie[0] = (NODE) {0, {0,0,0}, {-1,-1,-1}};
     /*
       *      Clear the memory matrix.
       */
     for (i=0; i<WINDOW; ++i)
       for (j=0; j<HISTORY+2; ++j)
         memory[i][j] =- 1;
     /*
       *      Clear the context array.
       */
     for (i=0; i<HISTORY+2; ++i) context[i] = (CONTEXT) {0,0,0,0,0};
     context[0] = (CONTEXT) {0,0,0,-1,-1};
     context[1] = (CONTEXT) {0,0,0,0,0};
     /*
       *      Clear the variable we use to keep track of how long MegaHAL
       *      spends thinking.
       */
     think = 0;
   }
   /*
     *      If we've already started playing, evaluate how well we went on our
     *      last turn, and update our list which decides which contexts give the
     *      best predictions.
     */
   if (m_history[0]>0) {
     /*
       *      We begin by forgetting which contexts performed well in the
       *      distant past.
       */
     if (WINDOW>0) for(i=1; i<context_size; ++i) {
       if (WINDOW-i>0) {
         if (memory[(remember+i-1)%WINDOW][i]>=0) {
           if (memory[(remember+i-1)%WINDOW][i]==
              ((o_history[m_history[0]-WINDOW+i-1]+1)%3))
             context[i].best-=1;
           if (memory[(remember+i-1)%WINDOW][i]==
              ((o_history[m_history[0]-WINDOW+i-1]+2)%3))
             context[i].worst-=1;
           context[i].seen-=1;
         }
       }
     }
     /*
       *      Clear our dimmest memory.
       */
     if (WINDOW>0) for(i=0; i<context_size; ++i)
       memory[remember][i] =- 1;
     /*
       *      We then remember the contexts which performed the best most
       *      recently.
       */
     for (i=0; i<context_size; ++i) {
       if (context[i].node>=trie_size) continue;
       if (context[i].node==-1) continue;
       if (trie[context[i].node].total>=BELIEVE) {
         for (j=0; j<3; ++j)
           expected[j]=COUNT[(j+2)%3]-COUNT[(j+1)%3];
         last_move=0;
         for (j=1; j<3; ++j)
           if (expected[j]>expected[last_move])
             last_move=j;
         if (last_move==(o_history[m_history[0]]+1)%3)
           context[i].best+=1;
         if (last_move==(o_history[m_history[0]]+2)%3)
           context[i].worst+=1;
         context[i].seen+=1;
         if (WINDOW>0) memory[remember][i]=last_move;
       }
     }
     if (WINDOW>0) remember=(remember+1)%WINDOW;
   }
   /*
     *      Clear the context to the node which always predicts at random, and
     *      the root node.
     */
   context_size = 2;
   /*
     *      We begin by forgetting the statistics we've previously gathered
     *      about the symbol which is now leaving the sliding window.
     */
   if ((WINDOW>0) && (m_history[0]-WINDOW>0))
     for (i=m_history[0]-WINDOW;
         i < MIN(m_history[0]-WINDOW+HISTORY, m_history[0]); ++i) {
       /*
         *      Find the node which corresponds to the context.
         */
       node = 0;
       for (j=MAX(m_history[0]-WINDOW,1); j<i; ++j) {
         node = trie[node].next[o_history[j]];
         node = trie[node].next[m_history[j]];
       }
       if ((node<0)||(node>=trie_size)) fprintf (stderr, "OUCH\n");
       /*
         *      Update the statistics of this node with the opponents move.
         */
       trie[node].total -= 1;
       trie[node].move[o_history[i]] -= 1;
     }
   /*
    *      Build up a context array pointing at all the nodes in the trie
    *      which predict what the opponent is going to do for the current
    *      history.  While doing this, update the statistics of the trie with
    *      the last move made by ourselves and our opponent.
    */
#if(WINDOW>0)
   for (i=m_history[0]; i>MAX(m_history[0]-MIN(WINDOW,HISTORY),0); --i) {
#else
   for (i=m_history[0]; i>MAX(m_history[0]-HISTORY,0); --i) {
#endif
      /*
       *      Find the node which corresponds to the context.
       */
      node = 0;
      for (j=i; j<m_history[0]; ++j) {
         node = trie[node].next[o_history[j]];
         node = trie[node].next[m_history[j]];
      }
      if ((node<0) || (node>=trie_size)) fprintf (stderr, "OUCH\n");
      /*
       *      Update the statistics of this node with the opponents move.
       */
      trie[node].total += 1;
      trie[node].move[o_history[m_history[0]]] += 1;
      /*
       *      Move to this node, making sure that we've allocated it first.
       */
      if (trie[node].next[o_history[m_history[0]]] == -1) {
         trie[node].next[o_history[m_history[0]]] = trie_size;
         trie_size += 1;
         trie = (NODE *) realloc (trie, sizeof(NODE)*trie_size);
         assert (trie);
         trie[trie_size-1] = (NODE) {0, {0,0,0}, {-1,-1,-1}};
      }
      node = trie[node].next[o_history[m_history[0]]];
      if ((node<0) || (node>=trie_size)) fprintf (stderr, "OUCH\n");
      /*
       *      Move to this node, making sure that we've allocated it first.
       */
      if (trie[node].next[m_history[m_history[0]]] == -1) {
         trie[node].next[m_history[m_history[0]]] = trie_size;
         trie_size += 1;
         trie = (NODE *) realloc (trie, sizeof (NODE)*trie_size);
         assert (trie);
         trie[trie_size-1] = (NODE) {0, {0,0,0}, {-1,-1,-1}};
      }
      node = trie[node].next[m_history[m_history[0]]];
      if ((node<0) || (node>=trie_size)) fprintf (stderr, "OUCH\n");
      /*
       *      Add this node to the context array.
       */
      context_size += 1;
      context[context_size-1].node = node;
      context[context_size-1].size = context_size-2;
   }
   /*
    *      Sort the context array, based upon what contexts have proved
    *      successful in the past.  We sort the context array by looking
    *      at the context lengths which most often give the best predictions.
    *      If two contexts give the same amount of best predictions, choose
    *      the longest one.  If two contexts have consistently failed in the
    *      past, choose the shortest one.
    */
   for (i=0; i<context_size; ++i)
      sorted[i] = context[i];
   qsort (sorted, context_size, sizeof(CONTEXT), halbot_compare);
   /*
    *      Starting at the most likely context, gradually fall-back until we
    *      find a context which has been observed at least BELIEVE times.  Use
    *      this context to predict a probability distribution over the opponents
    *      possible moves.  Select the move which maximises the expected score.
    */
   move =- 1;
   for (i=0; i<context_size; ++i) {
      if (sorted[i].node >= trie_size) continue;
      if (sorted[i].node == -1) break;
      if (trie[sorted[i].node].total >= BELIEVE) {
         for (j=0; j<3; ++j)
            expected[j] = SCOUNT[(j+2)%3]-SCOUNT[(j+1)%3];
         move=0;
         for (j=1; j<3; ++j)
            if (expected[j]>expected[move])
               move = j;
         break;
      }
   }
   /*
    *      If no prediction was possible, make a random move.
    */
   random_move = random()%3;
   if (move == -1) move = random_move;
   /*
    *      Update the timer, and warn if we've exceeded one second per one
    *      thousand turns.
    */
   (void) gettimeofday (&end, NULL);
   if (think >= 0)
      think += 1000000 * (end.tv_sec-start.tv_sec) + (end.tv_usec-start.tv_usec);
   if ((ERROR!=0) && ((think/(m_history[0]+1)>=1000) && (m_history[0]>100))) {
      think =- 1;
      fprintf (stdout, "\n\n*** MegaHAL-Infinite is too slow! ***\n\n");
   }
   /*
    *      Return our move.
    */
   return (move);

}   /* end "halbot" */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*
 *      Function:   halbot_compare
 *
 *      Arguments:   const void *value1, const void *value2
 *                  Two pointers into the sort array.  Our job is to decide
 *                  whether value1 is less than, equal to or greater than
 *                  value2.
 *
 *      Returns:      An integer which is positive if value1<value2, negative if
 *                  value1>value2, and zero if they're equal.  Various heuristics
 *                  are used to test for this inequality.
 *
 *      Overview:   This comparison function is required by qsort().
 */
/*----------------------------------------------------------------------------*/
static int 
halbot_compare (const void *value1, const void *value2)
{
   /*
    *      This is a duplicate of the typedef in halbot(), put here to avoid
    *      having to make it external to the functions.
    */
  typedef struct S_CONTEXT {
    int worst;
    int best;
    int seen;
    int size;
    int node;
  } CONTEXT;
   /*
    *      Some local variables.
    */
  CONTEXT *context1;
  CONTEXT *context2;
  float prob1=0.0;
  float prob2=0.0;
   /*
    *      This looks complicated, but it's not.  Basically, given two nodes
    *      in the trie, these heuristics decide which node should be used to
    *      make a prediction first.  The rules are:
    *      - Choose the one which has performed the best in the past.
    *      - If they're both being tried for the first time, choose the shortest.
    *      - If they've both performed equally well, choose the longest.
    */
  context1 = (CONTEXT *)value1;
  context2 = (CONTEXT *)value2;

  if (context1->seen>0)
    prob1 = (float)(context1->best-context1->worst) / (float)(context1->seen);
  if (context2->seen>0)
    prob2 = (float)(context2->best-context2->worst) / (float)(context2->seen);

  if (prob1 < prob2) return (1);
  if (prob1 > prob2) return(-1);

  //!!!!!!!!!!!!!!!!!!! ОШИБКА ?? !! (но почти ничего не изменилось!)
  //if((context1->seen==0)&&(context2->seen=0)) {
  if ((context1->seen==0) && (context2->seen==0)) {
    if (context1->size < context2->size) return(-1);
    if (context1->size > context2->size) return (1);
    return (0);
  }

  if (context1->size < context2->size) return (1);
  if (context1->size > context2->size) return(-1);

  return (0);

}   /* end of "halbot_compare" */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*
 *      $Log: megahal.c,v $
 *      Revision 1.7  1999/09/16 03:16:55  hutch
 *      Did some speed improvements, improved the method of remembering past
 *      strategies, and imroved the heuristics for sorting.  Over 1000 tourneys
 *      of 1000 trials, it performed 17.6 times better than the second best bot,
 *      "Beat Last Move", and scored an average of 678 per match.  It also
 *      consistently beats version 1.1, scoring an average of 100 or so per
 *      match.
 *
 *      Revision 1.5  1999/09/13 16:51:57  hutch
 *      The sliding window is working perfectly.  Of course, this strategy
 *      doesn't improve the performance of MegaHAL-Infinite on the standard
 *      algorithms, but it will hopefully improve performance on smarter ones.
 *
 *      Revision 1.4  1999/09/13 14:48:57  hutch
 *      Cleaned up the source a bit, and prepared to implement the sliding
 *      window strategy.
 *
 *      Revision 1.3  1999/09/12 06:29:30  hutch
 *      Consideration of the statistics, and correcting it to give proper
 *      probability estimates, improved Megahal-Infinite beyond MegaHAL.
 *
 *      Revision 1.2  1999/09/12 06:23:02  hutch
 *      Infinite contexts are done, and we now choose the context that has
 *      performed the best in the past.  Doesn't perform as well as MegaHAL,
 *      but I believe it will perform better on craftier algorithms.  Plus
 *      it out-performs MegaHAL on R-P-S 20-20-60.
 *
 *      Revision 1.1  1999/09/12 03:53:08  hutch
 *      This is the first official version.  We are now going to concentrate
 *      on making an infinite-context model, and collecting statistics over
 *      a sliding window, in the hope that this will improve performance
 *      against more sophisticated algorithms.
 *
 *      Revision 0.4  1999/09/11 12:40:11  hutch
 *      Okay, experimentation with parameters has increased it's performance to
 *      about 15 times better than the second best bot, and it's near perfect on
 *      "Beat Last Move", "Beat Frequent Pick", "Rotate RPS" and "Good Ol Rock".
 *      It scores about half on "Always Switchin'", and about a third on "R-P-S
 *      20-20-60".  Interestingly, this is the only bot which it has difficulty
 *      with.  Over 1000 tourneys of 1000 trials, it performed 17.5 times better
 *      than the second best bot, "Beat Last Move", and scored an average of 677
 *      per match.
 *
 *      Revision 0.3  1999/09/11 12:33:54  hutch
 *      Everything is working; the program kicks ass against the standard bots
 *      (performing at least twelve times better than the second best).  I will
 *      fine-tune the algorithm a bit, although it is quite quick, and will play
 *      around with the heuristics before submitting.
 *
 *      Revision 0.2  1999/09/11 11:40:01  hutch
 *      The mechanism for selecting the best move has been finished, and the
 *      model is working for a NULL context.  Now we need to expand it to the
 *      infinite context.
 *
 *      Revision 0.1  1999/09/11 05:58:29  hutch
 *      Initial revision
 */
/*----------------------------------------------------------------------------*/
/*============================================================================*/
//  END OF                     M E G A H A L          
/*============================================================================*/





/*============================================================================*/
//  BEGIN OF                    ACT-R  L A G 2                                
/*============================================================================*/
/*----------------------------------------------------------------------------*/

/*  Entrant:  ACT-R Lag2 (13)   Dan Bothell, C Lebiere, R West (USA)

 RoShamBo player submission by Christian Lebiere, Robert West, 
 and Dan Bothell 
 
 This player is based on an ACT-R (http://act.psy.cmu.edu) model
 that plays RoShamBo.  The model can be played against on the web 
 at http://act.psy.cmu.edu/ACT/ftp/models/RPS/index.html.
 
 suggested name "ACT-R Lag2"
 function name actr_lag2_decay
*/
/*
  C function that implements the math underlying the
  ACT-R (http://act.psy.cmu.edu) model of RPS by 
  Christian Lebiere and Robert West (Published in the 
  Proceedings of the Twenty-first Conference of the 
  Cognitive Science Society.)
  This model stores in long-term memory sequences of 
  moves and attempts to anticipate the opponent's 
  moves by retrieving from memory the most active sequence. 
  More information, and a web playable version avalable at:
  http://act.psy.cmu.edu/ACT/ftp/models/RPS/index.html
*/
/*----------------------------------------------------------------------------*/
int 
actr_lag2_decay (void)
{
  double frequencies[3], score, p, best_score = maxrandom;
 
  int back1 = 0, back2 = 0, i, winner, index = m_history[0];
        
  winner = 0; /* -db */
  for (i=0; i<3; i++)
     frequencies[i] = pow (index + 1, -.5);
 
  if (index >= 2)
  {
     back2 = o_history[index - 1];
     back1 = o_history[index];
  }
 
  for (i=0; i<index; i++)
  {
     if (i >= 2 && o_history[i - 1] == back2 && o_history[i] == back1)
       frequencies[o_history[i + 1]] +=  pow(index - i, -0.5); 
  }
                
  for (i=0; i<3; i++)
  {
    /*
      Approximates a sample from a normal distribution with mean zero
      and s-value of .25 [s = sqrt(3 * sigma) / pi]
      */
      
    do {
      p = random();
    } while (p == 0.0);
 
    p /= maxrandom;
    p= .25 * log ((1 - p) / p);
 
    /* end of noise calculation */
    score = p + log(frequencies[i]);
        
    if (best_score == maxrandom || score > best_score)
    {
      winner=i;
      best_score = score;
    }
  }

  return ((winner + 1) % 3);
}       
/*----------------------------------------------------------------------------*/
/*============================================================================*/
//  END OF                      ACT-R  L A G 2                         
/*============================================================================*/





/*============================================================================*/
//  BEGIN OF                     S H O F A R                 
/*============================================================================*/
/*----------------------------------------------------------------------------*/
/*  Entrant:  Shofar (11)   Rudi Cilibrasi (USA)  */
/*----------------------------------------------------------------------------*/

typedef struct {
    int  (*pname) ();
    void  (*init) ();
    double score;
    int    ivar[16];
  //double dvar[16]; // не понадобились переменные
    int    move;
} RT_STRAT;

RT_STRAT  s[128];
int       sc = 0;
RT_STRAT *cur;

int  chose = -1;

/*============================================================================*/
void 
narcissus_init () 
{
  static int whoiam = 0;

  cur->ivar[0] = whoiam; // инициируем из последовательности 0, 1, 2...
  whoiam = (whoiam+1) % 3;

  return;
}
/*-------------------------------------*/
int 
narcissus_play () 
{
  int mymove = m_history[m_history[0]];

  return (cur->ivar[0] + mymove) % 3;
}
/*============================================================================*/
void 
mirror_init () 
{
  static int whoiam = 0;

  cur->ivar[0] = whoiam;
  whoiam = (whoiam+1) % 3;

  return;
}
/*-------------------------------------*/
int 
mirror_play () 
{
  int hermove = o_history[o_history[0]];

  return (cur->ivar[0] + hermove) % 3;
}
/*============================================================================*/
void 
single_init () 
{
  static int whoiam = 0;

  cur->ivar[0] = whoiam; // инициируем из последовательности 0, 1, 2...
  whoiam = (whoiam+1) % 3;

  return;
}
/*-------------------------------------*/
int 
single_play () 
{

  return (cur->ivar[0]);
}
/*============================================================================*/
void 
pattern_init () 
{
  int i;

  cur->ivar[0] = 1 + random() / (maxrandom / 5); // случ.значение [1..5] ??
  cur->ivar[1] = 0;

  // некоторая последовательность случайных чисел
  for (i = 0; i < cur->ivar[0]; ++i)
  {
    cur->ivar[i+2] = 3*(random() / maxrandom) ;  // случ.значение [0..3] ??
  }

  return;
}
/*-------------------------------------*/
int 
pattern_play () 
{
  int which = cur->ivar[cur->ivar[1]+2]; 

  cur->ivar[1] = (cur->ivar[1]+1) % cur->ivar[0];

  return (which);
}
/*============================================================================*/
void 
update_score () 
{
  int mult_win = 4;
  int mult_los = 3;
  double mult_score = 0.99/* 1.0 */;

  int i;
  double worstscore = 1000;
  int    worstguy   = 0; /* -db */
  int  hermove, winmove, losemove;

  if (o_history[0] == 0) 
    return; // если ходов еще не было - уходим

  // последний ход оппонента 
  hermove = o_history[o_history[0]];

  winmove  = (hermove + 1) % 3; // победный ход
  losemove = (hermove + 2) % 3; // проигрышный

  // просматривая все стратегии
  for (i = 0; i < sc; ++i) {

    // берем множитель (для "выбранной стратегии" = 4, иначе = 3)
    int multiplier = (i == chose) ? mult_win : mult_los;

    if (s[i].move == winmove)  s[i].score += multiplier; // если выбор был верный - поощеряем
    if (s[i].move == losemove) s[i].score -= multiplier; // иначе - наказываем
    s[i].score *= mult_score; // ??
  }

  // просматриваем только патерновые стратегии
  for (i = 9; i < sc; ++i)
    if (s[i].score < worstscore)
    {
      worstscore = s[i].score; // наихудшая оценка
      worstguy = i;            // и ее номер
    }

  cur = s + worstguy;
  cur->init(); // инициируем заново стратегию с наихудшим наихудшим паттерном!!

  return;
}
/*----------------------------------------------------------------------------*/
void 
enregister (void (*initfunc)(), int (*playfunc)())
{
  // регистрируем стратегию
  s[sc].pname = playfunc;
  s[sc].init  = initfunc;

  // и тут же ее инициируем
  cur = s+sc;
  cur->init();

  ++sc; // увеличиваем счетчик
}
/*----------------------------------------------------------------------------*/
void 
shofar_init (void)
{
  int i;
  // регистрируем разные стратегии

  enregister (single_init, single_play); //  0 
  enregister (single_init, single_play); //  1 
  enregister (single_init, single_play); //  2 
  enregister (mirror_init, mirror_play); // (0 + hermove) % 3
  enregister (mirror_init, mirror_play); // (1 + hermove) % 3
  enregister (mirror_init, mirror_play); // (2 + hermove) % 3
  enregister (narcissus_init, narcissus_play); // (0 + mymove) % 3
  enregister (narcissus_init, narcissus_play); // (1 + mymove) % 3
  enregister (narcissus_init, narcissus_play); // (2 + mymove) % 3

  // случайные патерны
  for (i = 0; i < 80; ++i)
    enregister (pattern_init, pattern_play);

  // зачем здесь еще раз инициация ???
  /*   for (i = 0; i < sc; ++i) */
  /*   s[i].init(); */
}
/*----------------------------------------------------------------------------*/
// 
/*----------------------------------------------------------------------------*/
int 
shofar (void)
{
  static int has_init = 0;

  double base =1.05;
  double total=0, r;
  int  i;

  if (has_init == 0) { // при первом запуске
    shofar_init ();    // инициируем методику
    has_init = 1; 
  }

  // переоцениваем стратегии по последнему ходу
  // наихудшую патерновую - обновляем
  update_score ();

  // идем по всем стратегиям
  for (i = 0; i < sc; ++i) {
    cur = s + i;
    cur->move = cur->pname(); // в каждой делаем ход (а зачем заранее?)
    total += pow (base, s[i].score); // подсчитываем некоторый интеграл оценок
  }

  //---------------------------------------
  // выбираем случайную величину [0..total]
  r = (random() / maxrandom) * total;

  // поиск этой самой случ.границы
  for (i = 0; i < sc; ++i) {
    r -= pow (base, s[i].score);
    if (r <= 0) break;
  }

  assert (i >= 0 && i < sc); // проверка попадания в интервал
  chose = i; // выбор стратегии для хода
  //---------------------------------------

  // зачем так сложно ? просто выбираем случайную стратегию? 
  // или это по некоторому определенному распределению ?
  //chose = YRAND (0, sc-1);

/* printf ("Her move was %d, my move was %d\n", o_history[o_history[0]], s[chose].move); */

  return (s[chose].move); // ход уже "сделан" для каждой стратегии
}
/*----------------------------------------------------------------------------*/
/*============================================================================*/
//  END OF                       S H O F A R                 
/*============================================================================*/




/******************************************************************************/
/******************************************************************************/


/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: v_rsb3.c                                                  *
 *                                                                             *
  ******************************************************************************
 */ 

//#include "v-rsb-.h"



/*============================================================================*/
//  BEGIN OF              I O C A I N E   P O W D E R          
/*============================================================================*/


/*============================================================================*/
/*  Entrant:  Iocaine Powder (1)   Dan Egnor (USA)

 Winner of the First International RoShamBo Programming Competition
 Iocaine Powder             (from: http://ofb.net/~egnor/iocaine.html)

 They were both poisoned.
 
 Iocaine Powder is a heuristically designed compilation of strategies and
 meta-strategies, entered in Darse Billings' excellent First International
 RoShamBo Programming Competition. You may use its source code freely; I
 ask only that you give me credit for any derived works. I attempt here to
 explain how it works.
 
 Meta-Strategy
 
 RoShamBo strategies attempt to predict what the opponent will do. Given a
 successful prediction, it is easy to defeat the opponent (if you know they
 will play rock, you play paper). However, straightforward prediction will
 often fail; the opponent may not be vulnerable to prediction, or worse, they
 might have anticipated your predictive logic and played accordingly. Iocaine
 Powder's meta-strategy expands any predictive algorithm P into six possible
 strategies:
 
 P.0: naive application
      Assume the opponent is vulnerable to prediction by P; predict their
      next move, and play to beat it. If P predicts your opponent will play
      rock, play paper to cover rock. This is the obvious application of P.
 
 P.1: defeat second-guessing
      Assume the opponent thinks you will use P.0. If P predicts rock, P.0
      would play paper to cover rock, but the opponent could anticipate this
      move and play scissors to cut paper. Instead, you play rock to dull
      scissors.
 
 P.2: defeat triple-guessing
      Assume the opponent thinks you will use P.1. Your opponent thinks you
      will play rock to dull the scissors they would have played to cut the
      paper you would have played to cover the rock P would have predicted,
      so they will play paper to cover your rock. But you one-up them,
      playing scissors to cut their paper.
 
      At this point, you should be getting weary of the endless chain. "We
      could second-guess each other forever," you say. But no; because of the
      nature of RoShamBo, P.3 recommends you play paper -- just like P.0! So
      we're only left with these three strategies, each of which will suggest
      a different alternative. (This may not seem useful to you, but have
      patience.)
 
 P'.0: second-guess the opponent
      This strategy assumes the opponent uses P themselves against you.
      Modify P (if necessary) to exchange the position of you and your
      opponent. If P' predicts that you will play rock, you would expect
      your opponent to play paper, but instead you play scissors.
 
 P'.1, P'.2: variations on a theme
      As with P.1 and P.2, these represent "rotations" of the basic idea,
      designed to counteract your opponent's second-guessing (предугадывания).
 
//------------------------------------------------------------------------------

Итак, даже для одного предсказывающего алгоритма "P", у нас сейчас есть 6 (шесть)
возможных стратегий. Одна из них может быть корректна -- но это не на много более
полезно, чем сказать: "камень, нужницы или бумага - будут правильным следующим 
ходом". Нужна мета-стратегия, чтобы делать выбор между этими 6-тью стратегиями.

Базовая мета стратегия "Iocaine Powder" - проста: использование прошедших 
действий для оценки будующих результатов.
 
Основное допущение этой мета-стратегии: оппонент не будет быстро менять свою 
стратегию. Либо он будет играть некоторый предиктивный алгоритм P, либо он будет 
защищаться от него, или использовать какой-то уровень предугадывания. Но, чтобы 
он ни делал, он будет делать это единообразно.

Чтобы воспользоваться преимуществом от этой (предполагаемой) предсказуемости,
в каждом раунде "Iocaine Powder" измеряет, насколько хорошо каждая из 
рассматриваемых стратегий (6 для каждого предикативного алгоритма!) работала бы, 
при ее использовании.
Для каждой считаются очки, используя стандартную турнирную схему: 
+1 , если стратегия выиграла раунд, -1 , если проиграла и 0 за ничью.
Затем, чтобы реально сделать ход, "Iocaine Powder" просто выбирает вариант 
стратегии с максимальной оценкой.
 
Конечный результат в том, что для любой данной предсказательной техники, мы будем 
бить (побеждать) любого соперника, который может быть бит этой техникой, любого 
соперника использующего технику непосредственно, и любого соперника, наученного 
защищаться от этой техники непосредственно.

//------------------------------------------------------------------------------
СТРАТЕГИИ
 
Все мета-стратегии в мире бесполезны без некоторых определенных предикативных 
алгоритмов.
"Iocaine Powder" использует три предсказателя (predictors):

Случайноя догадка (Random guess)
    Этот "предсказатель" просто выбирает ход случайным образом. 
    Я включил этот алгоритм как страховку; если найдется кто-то, кто действительно 
    способен "раскусить" и разгромить "Iocaine Powder"с некоторой регулярностью, 
    то задолго до этого "случайный предиктор" будет ранжирован с наивысшей оценкой 
    (поскольку никто не может победить "random" !)
    С этого момента, мета-стратегия  будет гарантировать (страховать), что 
    программа "отсекает свои убытки" (cuts its losses) и начинает играть 
    рандомизированно, чтобы исключить разрушительные потери. 
    (спасибо Jesse Rosenstock за исследование необходимости такой страховки)

Частотный анализ
    Частотный анализатор просматривает историю оппонента, ищет ход, который тот 
    делал наиболее часто в прошлом и предсказывает, что он (оппонент)  выберет 
    этот ход.
    Хотя такая оценка ошеломительно действует против "Good Ole Rock", это
    не очень полезно против более изощренных оппонентов (которые обычно довольно 
    симметричны). 
    Я включил его главным образом для победы над другими соперниками, которые 
    используют этот предикативный алгоритм.
 
Историческое сопастовление (History matching)
    This is easily the strongest predictor in Iocaine Powder's arsenal, and
    variants of this technique are widely used in other strong entries. The
    version in Iocaine Powder looks for a sequence in the past matching the
    last few moves. For example, if in the last three moves, we played
    paper against rock, scissors against scissors, and scissors against
    rock, the predictor will look for times in the past when the same three
    moves occurred. 
    (In fact, it looks for the longest match to recent
    history; a repeat of the last 30 moves is considered better than just
    the last 3 moves.) 
    Once such a repeat is located, the history matcher
    examines the move our opponent made afterwards, and assumes they will
    make it again. (Thanks to Rudi Cilibrasi for introducing me to this
    algorithm, long ago.)
 
    Once history is established, this predictor easily defeats many weak
    contestants. Perhaps more importantly, the application of meta-strategy
    allows Iocaine to outguess other strong opponents.
//------------------------------------------------------------------------------ 
ДЕТАЛИ
 
 If you look at Iocaine Powder's source code, you'll discover additional
 features which I haven't treated in this simplified explanation. For
 example, the strategy arsenal includes several variations of frequency
 analysis and history matching, each of which looks at a different amount of
 history; in some cases, prediction using the last 5 moves is superior to
 prediction using the last 500. We run each algorithm with history sizes of
 1000, 100, 10, 5, 2, and 1, and use the general meta-strategy to figure out
 which one does best.
 
 In fact, Iocaine even varies the horizon of its meta-strategy analyzer!
 Strategies are compared over the last 1000, 100, 10, 5, 2, and 1 moves, and
 a meta-meta-strategy decides which meta-strategy to use (based on which
 picker performed best over the total history of the game). This was designed
 to defeat contestants which switch strategy, and to outfox variants of the
 simpler, older version of Iocaine Powder.
 
//------------------------------------------------------------------------------
РЕЗЮМЕ
 
Что необходимо помнить, когда участвуешь в соревнованиях такого типа, это то, 
что мы не пытаемся моделировать явление природы или предсказать действия 
пользователя; вместо этого, программы соревнуются против враждебных оппонентов, 
которые пытаются всеми силами не быть предсказуемыми.
"Iocaine Powder" не использует продвинутые статистические техники или марковские 
модели (хотя возможно они бы и дали улучшение), но это очень отдаленно (devious).

Это однако не означает последнего слова. "Iocaine" смог победить всех участников 
первого турнира, но у меня нет сомнения, что оппоненты усилятся к следующему 
вызову.
//------------------------------------------------------------------------------

   Dan Egnor
*/
/*----------------------------------------------------------------------------*/

#define WILL_BEAT(play) ("\001\002\000"[play])
#define WILL_LOSE(play) ("\002\000\001"[play])


/* static const */ int my_hist = 0, opp_hist = 1, both_hist = 2;

typedef struct {
  int  sum[1+TRIALS][3];
  int  age;
} YT_STATS;

typedef struct {
  YT_STATS  st;
  int     last;
} YT_PREDICT;

int ages[] = { 1000, 100, 10, 5, 2, 1 };
#define NUM_AGES (sizeof(ages) / sizeof(ages[0]))

typedef struct {
  YT_PREDICT  pr_history[NUM_AGES][3][2], pr_freq[NUM_AGES][2];
  YT_PREDICT  pr_fixed, pr_random, pr_meta[NUM_AGES];

  YT_STATS    stats[2]; // статистика по игрокам: 0 - моя, 1 - врага
} YT_IOCANE;


/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
int 
match_single (int i, int num, int *history) 
{
  int *highptr = history + num;
  int *lowptr  = history + i;

  while (lowptr > history && *lowptr == *highptr) --lowptr, --highptr;

  return (history + num - highptr);
}
/*----------------------------------------------------------------------------*/
int 
match_both (int i, int num) 
{
  int j;

  for (j = 0; j < i && o_history[num-j] == o_history[i-j]
         && m_history[num-j]  == m_history[i-j]; ++j) ;

  return j;
}
/*----------------------------------------------------------------------------*/
void 
do_history (int age, int best[3]) 
{
  const int num = m_history[0];
  int best_length[3], i, j, w;

  for (w = 0; w < 3; ++w) 
    best[w] = best_length[w] = 0; 

  for (i = num - 1; i > num - age && i > best_length[my_hist]; --i) {
    j = match_single (i, num, m_history);
    if (j > best_length[my_hist]) {
      best_length[my_hist] = j;
      best[my_hist] = i;
      if (j > num / 2) break;
    }
  }

  for (i = num - 1; i > num - age && i > best_length[opp_hist]; --i) {
    j = match_single (i, num, o_history);
    if (j > best_length[opp_hist]) {
      best_length[opp_hist] = j;
      best[opp_hist] = i;
      if (j > num / 2) break;
    }
  }

  for (i = num - 1; i > num - age && i > best_length[both_hist]; --i) {
    j = match_both(i,num);
    if (j > best_length[both_hist]) {
      best_length[both_hist] = j;
      best[both_hist] = i;
      if (j > num / 2) break;
    }
  }

  return;
}
/* ------------------------------------------------------------------------- */

/*----------------------------------------------------------------------------*/
void 
add_stats (YT_STATS *st, int i, int delta) 
{

  st->sum[st->age][i] += delta;

  return;
}
/*----------------------------------------------------------------------------*/
void  
next_stats (YT_STATS *st) 
{
  if (st->age < TRIALS) {
    int i;
    ++(st->age);

    for (i = 0; i < 3; ++i) 
      st->sum[st->age][i] = st->sum[st->age - 1][i];
  }

  return;
}
/*----------------------------------------------------------------------------*/
int 
max_stats (/* const */ YT_STATS *st, int age, int *which, int *score) 
{
  int i;
  *which = -1;

  for (i = 0; i < 3; ++i) {
    int diff;
    if (age > st->age) 
      diff = st->sum[st->age][i];
    else
      diff = st->sum[st->age][i] - st->sum[st->age - age][i];
    if (diff > *score) {
      *score = diff;
      *which = i;
    }
  }

  return (-1 != *which);
}
/*----------------------------------------------------------------------------*/
void 
reset_stats (YT_STATS *st) 
{
  int i;

  st->age = 0;
  for (i = 0; i < 3; ++i) 
    st->sum[st->age][i] = 0;

  return;
}
/*----------------------------------------------------------------------------*/
void 
reset_predict (YT_PREDICT *pred) 
{
  reset_stats (&pred->st);
  pred->last = -1;

  return;
}
/*----------------------------------------------------------------------------*/
/* last: opponent's last move (-1 if none)
 | guess: algorithm's prediction of opponent's next move */
/*----------------------------------------------------------------------------*/
void 
do_predict (YT_PREDICT *pred, int last, int guess) 
{
  if (-1 != last) {
    const int diff = (3 + last - pred->last) % 3;

    add_stats (&pred->st, WILL_BEAT (diff),  1);
    add_stats (&pred->st, WILL_LOSE (diff), -1);

    next_stats (&pred->st);
  }

  pred->last = guess;
  return;
}
/*----------------------------------------------------------------------------*/
void 
scan_predict (YT_PREDICT *pred, int age, int *move, int *score) 
{
  int i;

  if (max_stats (&pred->st, age, &i, score)) 
    *move = ((pred->last + i) % 3);

  return;
}
/* ------------------------------------------------------------------------- */
int 
iocaine (YT_IOCANE *i) 
{
  /* const */ int num = m_history[0];
  /* const */ int last = (num > 0) ? o_history[num] : -1;
  /* const */ int guess = biased_roshambo (1.0/3.0, 1.0/3.0);
  int  w, a, p;

  //----------------------------------------------------
  if (0 == num) {
    // начальная инициация (еще нет истории), т.е. это - первый ход
    // делаем всем предсказателям RESET:

    for (a = 0; a < NUM_AGES; ++a) {
      reset_predict (&i->pr_meta[a]);

      for (p = 0; p < 2; ++p) {
      for (w = 0; w < 3; ++w)
        reset_predict (&i->pr_history[a][w][p]);

      reset_predict (&i->pr_freq[a][p]);
      }
    }

    for (p = 0; p < 2; ++p)  
      reset_stats (&i->stats[p]);

    reset_predict (&i->pr_random);
    reset_predict (&i->pr_fixed);

  } else {
  //----------------------------------------------------
    
    add_stats (&i->stats[0], m_history[num], 1);
    add_stats (&i->stats[1], o_history[num], 1);
  }
  //----------------------------------------------------


  //----------------------------------------------------
  for (a = 0; a < NUM_AGES; ++a) {
    int best[3];

    do_history (ages[a], best);

    for (w = 0; w < 3; ++w) {
      /* const */ int b = best[w];
      if (0 == b) {
        do_predict (&i->pr_history[a][w][0], last,guess);
        do_predict (&i->pr_history[a][w][1], last,guess);
        continue;
      }
      do_predict (&i->pr_history[a][w][0], last, m_history [b+1]);
      do_predict (&i->pr_history[a][w][1], last, o_history[b+1]);
    }

    for (p = 0; p < 2; ++p) {
      int best = -1,freq;

      if (max_stats (&i->stats[p], ages[a], &freq, &best))
        do_predict (&i->pr_freq[a][p], last, freq);
      else
        do_predict (&i->pr_freq[a][p], last, guess);
    }
  }
  //----------------------------------------------------

  do_predict (&i->pr_random, last, guess);
  do_predict (&i->pr_fixed, last, 0);

  //----------------------------------------------------
  for (a = 0; a < NUM_AGES; ++a) {
    int aa, move = -1, score = -1;

    for (aa = 0; aa < NUM_AGES; ++aa) {
    for (p = 0; p < 2; ++p) {
      for (w = 0; w < 3; ++w)
        scan_predict (&i->pr_history[aa][w][p], ages[a], &move, &score);

      scan_predict (&i->pr_freq[aa][p], ages[a], &move, &score);
    }
    }
    
    scan_predict (&i->pr_random, ages[a], &move, &score);
    scan_predict (&i->pr_fixed,  ages[a], &move, &score);
    do_predict (&i->pr_meta[a], last, move);
  }
  //----------------------------------------------------

  {
    int move = -1, score = -1;

    for (a = 0; a < NUM_AGES; ++a)
      scan_predict (&i->pr_meta[a], TRIALS, &move, &score);

    return (move);
  }
}
/*----------------------------------------------------------------------------*/
int 
iocainebot (void)
{
  static YT_IOCANE  p;

  return (iocaine (&p));
}
/*============================================================================*/
//  END OF                I O C A I N E   P O W D E R            
/*============================================================================*/




/*============================================================================*/
//  BEGIN OF                 P H A S E N B O T T
/*============================================================================*/
/*  Entrant:  Phasenbott (2)   Jakob Mandelson (USA)
 

"Phasenbott" использует стратегию, похожую на "Iocaine Powder" Дэна Игнора, 
и действительно, она происходит от ранней версии работы Дэна.
 
Ранний "Iocaine Powder" ("Old IP") брал одиночную стратегию как входящую, и
"транспонировал" ее в 6 стратегий:
   1. Играем эту стратегию.
   2. Пологаем, что оппонент думает, что вы будете делать (1), и бьем его.
   3. Пологаем, что оппонент думает, что вы будете делать (2), и бьем его.
   4. Пологаем, что оппонент играет эту стратегию, и бьем его.
   5. Пологаем, что оппонент думает, что вы будете делать (4), и бьем его.
   6. Пологаем, что оппонент думает, что вы будете делать (5), и бьем его.
 
Вследствии круговой природы правил (Камень -> Ножницы -> Бумага -> Камень), 
новая стратегия: "полагаем, что оппонент думает, вы будете играть (3), и 
бьем его" равносильна стратегии (1), и также
новая стратегия: "полагаем, что оппонент думает, вы будете играть (6), и 
бьем его" равносильна стратегии (4) !!
Таким образом - эти 6 "стратегий" образуют полное множество вариантов на основе 
начально предположенной стратегии.
  
Затем подсчитывем, какая из них была бы исторически лучшей, если бы игралась и 
выбираем эту стратегию для игры.
"Old IP" использовал историю матча в качестве базовой стратегии.
 
--------------------------------------------------------------------------------
 
 Я обобщил (свел) эту концепцию к функции, которая берет бота из массива "ботов"
 (каждый из которых возвращает, чтобы он сыграл, если бы был вами и если бы был 
 опонентом), 
 делает  для каждого 6-ти вариантное связывание и выбирает лучшую стратегию для 
 игры.
 Заметьте, что эта функция - сама "бот", и может быть "скормлена" сама себе.
 Если рассмотреть оператор "I" , который берет стратегии и выбирает лучшее среди 
 их транспозиций, то "Old IP" можно представить как "I(History)".  
 "Phasenbott" использует альтернативный улучшенный исторический механизм (в 
 дополнение к Дэновскому оригинальному), а также в качестве базовых стратегий  
 "Old IP" и  "Random" (как резервный).
 Т.е. Phasenbott = I(History, AltHistory, Old IP, Random)
 
 "New IP" (Дэновская программа-победитель) эффективно включает в себя "Phasenbott", 
 поэтому не было сюрпризом то, что "Phasenbott" проиграл ей. 
 В ней используется новый исторический механизм в дополнение к оригинальному 
 (как и в "Phasenbott") а также включен частотный анализатор.
 В дополнение, в конце, после применения всех вариантов стратегий, она применяет к 
 полученному результату оператор "I" !! 
 Это означает, что она проверяет, как это будет играться против себя самой и 
 выбирает лучший вариант.
 
 Я проверил эффект от подобного "meta-ing", и (обнаружил что?) после первых 
 нескольких шагов - он неэффективен: если ни одна из базовых стратегий не 
 соответствует игре оппонента, то стратегия "Iocaine" становится настолько 
 изысканной (хитрой), что неотличима от случайной.
 Если одна из базовых стратегий ассоциируется с оппонентом, то "meta-ing" - 
 не есть хорошо.
 
 "Iocaine Powder" также использует более аккуратную метрику для сравнения 
 стратегий.
 "Phasenbott" играет ту стратегию где наибольшее число побед, а "Iocaine Powder" 
 учитывает ничьи (или поражения, в зависимости от вашего POV) при подсчете 
 наивысшей оценки.

 Метрика "Phasenbott" будет более подходящей в игре "Rock-Paper-Scissors" с  
 ненулевой суммой (где просто даются очки за победы).
 Такая игра более интересна с теоретической точки зрения, чем нынешняя, 
 стимулирующая кооперацию, а не отдельную оптимальную стратегию.

 Random scores an expected 1/3, but cooperating players could
 do better by alternating wins, for 1/2.  A player wanting to do better than 
 1/2 would try to exploit the other player, but not enough that the other
 player detects that it's worthwhile to switch into Random mode.  
 The weak
 player scoring say 2/5 could know that it's being exploited by the stronger,
 but still go along with it as if it refused (by going Random) its score would
 drop to 1/3.  

 Это делает, по моему мнению, для изучения, много более интересной игру 
 "Rock-Paper-Scissors", чем "Roshambo". 
 Может быть следующее программистское соревнование, будет отличаться такой игрой 
 с ненулевой суммой.  [Hint, hint. :) ]
 */

/*----------------------------------------------------------------------------*/
/* Phasenbott  --   Jakob Mandelson.

 * Используемые стратегии: 
       Historical prediction based on sequence of both parties,
 *     and of one party, and itself using only both-party history prediction.
 */
/*============================================================================*/

#define PWILL_BEAT(x) ("\001\002\000"[x])

typedef struct {
   long  (*fcn)(void *state);
   void  *state;
} YT_JLMBOT;

typedef struct {
   int  both, my, opp, num;
} YT_JLMHISTRET;

/*----------------------------------------------------------------------------*/

typedef struct {

  int  n;
  int  *my_last, *opp_last;
  int  (*my_stats)[3],  (*opp_stats)[3];
  int  (*my_ostats)[3], (*opp_ostats)[3];
  int  *opp_guess, *my_guess;
  YT_JLMBOT *to_beat;

} YT_JOCAINE_STATE;

//static long apply_jocaine (YT_JOCAINE_STATE *);

/*----------------------------------------------------------------------------*/
void 
jlm_history (YT_JLMHISTRET *s) 
{
  int besta, bestb, bestc, i, j, num;
  /* a is both history, b is my history, c is opponent history. */

  if (s->num == m_history[0]) 
    return;

  s->num = num = m_history[0];
  s->both = s->my = s->opp = besta = bestb = bestc = 0;

  for (i = num - 1; i > besta; --i) {
    for (j = 0; j < i 
           && o_history[num - j] == o_history[i - j]
           && m_history [num - j] == m_history [i - j]; ++j) 
    { } 
    if (j > besta) { besta = j; s->both = i; }
    if (j > bestb) { bestb = j; s->my   = i; }
    if (j > bestc) { bestc = j; s->opp  = i; }

    if (o_history[num-j] != o_history[i - j]) {
      for ( ; j < i && m_history[num-j] == m_history[i-j]; ++j) 
      { }
      if (j > bestb) { bestb = j; s->my = i; }
    }
    else /* j >= i || m_history[num-j] != m_history[i - j] */ {
      for ( ; j < i && o_history[num-j] == o_history[i-j]; ++j) 
      { }
      if (j > bestc) { bestc = j; s->opp = i; }
    }
  }

  return;
}
/*----------------------------------------------------------------------------*/
long 
jlmhist1 (YT_JLMHISTRET *s) 
{
  jlm_history (s);
  if (0 == s->opp) 
    return (biased_roshambo (1.0/3.0, 1.0/3.0));

  return ( PWILL_BEAT(o_history[s->opp + 1]) | (PWILL_BEAT(m_history[s->my + 1]) << 16) 
         );
}
/*----------------------------------------------------------------------------*/
long 
jlmhist0 (YT_JLMHISTRET *s) 
{
  jlm_history (s);

  if (0 == s->both) 
    return (biased_roshambo (1.0/3.0, 1.0/3.0));

  return ( PWILL_BEAT(o_history[s->both + 1]) | (PWILL_BEAT(m_history[s->both + 1]) << 16) 
         );
}
/*----------------------------------------------------------------------------*/
long 
jlmrand (void *throwaway) 
{  
  /* Fallback to keep from losing too badly.  */

  return (biased_roshambo (1.0/3.0, 1.0/3.0) | (biased_roshambo (1.0/3.0, 1.0/3.0) << 16) 
         );
}
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
long 
apply_jocaine (YT_JOCAINE_STATE *s) 
{
  const int num = m_history[0];
  long  b;
  int   i,my_most, opp_most, h;
  int   my_omost,  opp_omost;
  int   hy_omost,  hpp_omost;
  int   hy_most,   hpp_most;

  // инициация при начальном запуске
  if (0 == num) {
    for (h = 0; h < s->n; h++) {   
    for (i = 0; i < 3; ++i) 
        s->my_stats [h][i] = s->opp_stats [h][i] = 
        s->my_ostats[h][i] = s->opp_ostats[h][i] = 0;

      b = s->to_beat[h].fcn (s->to_beat[h].state);
      s->my_last [h] =  b & 0xFFFF;
      s->opp_last[h] =  b >> 16; 
    }

    return (random() % 3);
  }


  for (h = 0; h < s->n; h++) {
    b = s->to_beat[h].fcn (s->to_beat[h].state); 
    s->my_guess [h] = b & 0xFFFF;
    s->opp_guess[h] = b >> 16;

    s->my_stats  [h][(3 + o_history[num] - s->my_last [h]) % 3]++;
    s->opp_stats [h][(3 + o_history[num] - s->opp_last[h]) % 3]++;
    s->my_ostats [h][(3 + m_history [num] - s->opp_last[h]) % 3]++;
    s->opp_ostats[h][(3 + m_history [num] - s->my_last [h]) % 3]++;

    s->my_last [h] = s->my_guess [h];
    s->opp_last[h] = s->opp_guess[h];
  }

  my_most = opp_most = my_omost = opp_omost = 0;
  hy_most = hpp_most = hy_omost = hpp_omost = 0;

  for (h = 0; h < s->n; ++h) 
  for (i = 0; i < 3; ++i)  {
    if (s->my_stats [h][i] > s->my_stats[hy_most][my_most]) { 
      my_most  = i;  hy_most = h; 
    }
    if (s->opp_stats[h][i] > s->opp_stats[hpp_most][opp_most]) { 
      opp_most = i;  hpp_most = h; 
    }
    if (s->my_ostats[h][i] > s->my_ostats[hy_omost][my_omost]) { 
      my_omost = i;  hy_omost = h; 
    }
    if (s->opp_ostats[h][i] > s->opp_ostats[hpp_omost][opp_omost]) { 
      opp_omost = i; hpp_omost = h; 
    }
  }

  if (s->opp_stats[hpp_most][opp_most] >= s->my_stats[hy_most][my_most])
    b = PWILL_BEAT ((s->opp_guess[hpp_most] + opp_most) % 3);
  else
    b = PWILL_BEAT ((s->my_guess[hy_most] + my_most) % 3);

  if (s->opp_ostats[hpp_omost][opp_omost] >= s->my_ostats[hy_omost][my_omost])
    b |= PWILL_BEAT ((s->my_guess[hpp_omost] + opp_omost) % 3) << 16;
  else
    b |= PWILL_BEAT ((s->opp_guess[hy_omost] + my_omost) % 3) << 16;

  return (b);
}
/*----------------------------------------------------------------------------*/
int 
phasenbott ()
{
  typedef long (*fcn)(void *state);

  static YT_JLMHISTRET h;

  /* static */ int sy_last, spp_last, spp_guess, sy_guess;
  /* static */ int sy_stats[3], spp_stats[3], sy_ostats[3], spp_ostats[3];
  /* static */ YT_JLMBOT hb = { (fcn)jlmhist0,  &h};

  /* static */ YT_JOCAINE_STATE t = { 1, &sy_last, &spp_last,
                                      &sy_stats, &spp_stats, &sy_ostats, &spp_ostats,
                                      &spp_guess, &sy_guess, &hb };

  //typedef int  arr4[4];
  //static arr4  my_last, opp_last, opp_guess, my_guess;

  static int   my_last[4], opp_last[4], opp_guess[4], my_guess[4];
  static int   my_stats[4][3], opp_stats[4][3], my_ostats[4][3], opp_ostats[4][3];
  /* static */ YT_JLMBOT ba[4] = {{(fcn)jlmhist1, &h}, {(fcn)jlmhist0,      &h}, 
                                  {(fcn)jlmrand,   0}, {(fcn)apply_jocaine, &t}};

  /* static */ YT_JOCAINE_STATE s = { 4, my_last, opp_last,
                                      my_stats, opp_stats, my_ostats, opp_ostats,
                                      opp_guess, my_guess, ba };

  return ((apply_jocaine (&s)) & 0xFFFF);
}
/*============================================================================*/
//  END OF                   P H A S E N B O T T
/*============================================================================*/




/*============================================================================*/
//  BEGIN OF                  R U S S R O K E R 4                 
/*============================================================================*/
/*----------------------------------------------------------------------------*/

/*  Entrant:  RussRocker4 (4)   Russ Williams (USA)

   > I also welcome more feedback from the participants,
 
 Ok, here's some more feedback & personal info for you.  Feel free to include
 any of it at your site if it seems of interest.
 
 You summed up the basic idea of my AI pretty well in your Part 1 report.  I
 basically made a Markov model of the other player's actions, given the last
 3 moves of both players and basing the probabilities on the entire match
 history.  I then assumed they would simply pick the most likely move.  I
 also used the last 2 moves if the last 3 moves gave a tie for most likely
 guess, and if that still tied, use the last move, and so on.  Experimenting
 showed that using this tie breaking seemed to only be useful early on, so
 after a while ties for most likely opponent choice were broken by choosing
 randomly.
 
 I also intentionally chose to use the large arrays to avoid having to scan
 the entire history array each turn, since I wasn't sure how much of an issue
 execution speed would be.  The cost of that was that there was no simple or
 obvious way to give more emphasis to more recent games, which I would have
 liked to have done.
 
 I'd misunderstood and thought that reverting to random behavior even as a
 "bailout" measure was considered unsporting, else I might have added such a
 feature which would have (as you observed) saved me getting so trounced by
 the rank 1 & 2 programs.  Or did you have some other sort of bailout measure
 in mind?  I could imagine another potentially useful (or at least amusing)
 bailout measure would be "if I'm losing hideously, then start doing the
 opposite of whatever my algorithm says I should do."
 
 I fiddled off & on with my program for about 5 days.  It went through quite
 a few iterations, and I played many long tournaments with variations of
 itself and lots of intentionally weak players to tweak it.
 
 I also found that some versions seemed much stronger at short matches (e.g.
 100 games) and weaker at long matches (e.g. 10000 games), and vice-versa.
 The reasons were not always apparent.
 
 In real life I am a game programmer, which I got into after completing a MS
 in CS at UT Austin.  I worked on 1830 (from Avalon Hill) and Master of Orion
 2 (from Microprose), doing AI for both.  I plan to work on AI for Go one of
 these days.
*/
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
static int 
russrock_max (int *a, int n)
{
  int i;
  int best_index = 0;
  int max_so_far = a[0];

  for (i = 1; i < n; ++i) {
    if (max_so_far < a[i]) {
      max_so_far = a[i];
      best_index = i;
    }
  }

  return best_index;
}
/*----------------------------------------------------------------------------*/
int
for3_proc (int temp[3], int max_value, int n_votes[3], int add_votes)
{
  int i, n = 0;

  for (i = 0; i < 3; ++i) {
    if (temp[i] == max_value) {
      n_votes[i] += /* 10000 */ add_votes;
      ++n;
    }
  }
    
  return (n);
}
/*----------------------------------------------------------------------------*/
int
russrock_max_value (int temp[3])
{

  int max_index = russrock_max(temp, 3);
  int max_value = temp[max_index];

  return (max_value);
}
/*----------------------------------------------------------------------------*/
int russrocker4 ()
{
/* by Russ Williams (e-mail: russrocker at hotmail dot com */

  const int n_moves_for_3 = 825;
  const int n_moves_for_2 = 11;
  const int n_moves_for_1 = 6;

  static int moves0[3];
  static int moves1[3][3][3];
  static int moves2[3][3][3][3][3];
  static int moves3[3][3][3][3][3][3][3];

  int max_index, max_value;

  int i, j, n;

  int n_moves = o_history[0];
  int their_last = -1;

  int temp[3];
  int n_votes[3] = {1, 1, 1};


  if (n_moves == 0) {
    // в самом начале инициируем массивы нулями
    memset (moves0, 0, sizeof moves0);
    memset (moves1, 0, sizeof moves1);
    memset (moves2, 0, sizeof moves2);
    memset (moves3, 0, sizeof moves3);
  } else {

    their_last = o_history[n_moves];
  }

  // что это за конструкция ?
  switch (n_moves) {
  default:
    ++moves3
      [m_history[n_moves - 3]][o_history[n_moves - 3]]
      [m_history[n_moves - 2]][o_history[n_moves - 2]]
      [m_history[n_moves - 1]][o_history[n_moves - 1]]
      [their_last];
    /*  fall through */
  case 3:
    ++moves2
      [m_history[n_moves - 2]][o_history[n_moves - 2]]
      [m_history[n_moves - 1]][o_history[n_moves - 1]]
      [their_last];
    /*  fall through */
  case 2:
    ++moves1
      [m_history[n_moves - 1]][o_history[n_moves - 1]]
      [their_last];
    /*  fall through */
  case 1:
    ++moves0
      [their_last];
    /*  fall through */
  case 0:
    break;
  }

  //-----------------------
  do {

    if (3 <= n_moves) {
      for (i = 0; i < 3; ++i) {
        temp[i] = moves3
          [m_history[n_moves - 2]][o_history[n_moves - 2]]
          [m_history[n_moves - 1]][o_history[n_moves - 1]]
          [m_history[n_moves]][their_last]
          [i];
      }
      //--------------------------------
      max_value = russrock_max_value (temp);
      if (max_value > 0) {
        n = for3_proc (temp, max_value, n_votes, 10000);
        if (n == 1 || n_moves_for_3 <= n_moves) break;
      }
      //--------------------------------

      for (i = 0; i < 3; ++i) {
        temp[i] = 0;
        for (j = 0; j < 3; ++j) {
          temp[i] += moves3
            [j][o_history[n_moves - 2]]
            [m_history[n_moves - 1]][o_history[n_moves - 1]]
            [m_history[n_moves]][their_last]
            [i]
            + moves3
            [m_history[n_moves - 2]][j]
            [m_history[n_moves - 1]][o_history[n_moves - 1]]
            [m_history[n_moves]][their_last]
            [i];
        }
      }
      max_value = russrock_max_value (temp);
      if (max_value > 0) {
        for3_proc (temp, max_value, n_votes, 5000);
      }
    }


    if (2 <= n_moves) {
      for (i = 0; i < 3; ++i) {
        temp[i] = moves2
          [m_history[n_moves - 1]][o_history[n_moves - 1]]
          [m_history[n_moves]][their_last]
          [i];
      }

      max_value = russrock_max_value (temp);
      if (max_value > 0) {
        for3_proc (temp, max_value, n_votes, 1000);
        if (n_moves_for_2 <= n_moves) break;
      }

      for (i = 0; i < 3; ++i) {
        temp[i] = 0;
        for (j = 0; j < 3; ++j) {
          temp[i] += moves2
            [j][o_history[n_moves - 1]]
            [m_history[n_moves]][their_last]
            [i]
            + moves2
            [m_history[n_moves - 1]][j]
            [m_history[n_moves]][their_last]
            [i];
        }
      }

      max_value = russrock_max_value (temp);
      if (max_value > 0) {
        for3_proc (temp, max_value, n_votes, 500);
      }
    }


    if (1 <= n_moves) {
      for (i = 0; i < 3; ++i) {
        temp[i] = moves1
          [m_history[n_moves]][their_last]
          [i];
      }
      //--------------------------------
      max_value = russrock_max_value (temp);
      if (max_value > 0) {
        for3_proc (temp, max_value, n_votes, 100);
        if (n_moves_for_1 <= n_moves) break;
      }
      //--------------------------------

      for (i = 0; i < 3; ++i) {
        temp[i] = 0;
        for (j = 0; j < 3; ++j) {
          temp[i] += moves1
            [j][their_last]
            [i]
            + moves1
            [m_history[n_moves]][j]
            [i];
        }
      }
      max_value = russrock_max_value (temp);
      if (max_value > 0) {
        for3_proc (temp, max_value, n_votes, 50);
      }
    }


    {
      for (i = 0; i < 3; ++i) {
        temp[i] = moves0
          [i];
      }
      max_value = russrock_max_value (temp);
      if (max_value > 0) {
        for3_proc (temp, max_value, n_votes, 10);
      }
    }

  } while (0);
  //-----------------------

  max_index = russrock_max (n_votes, 3);
  for (i = 0; i < 3; ++i) {
    if (n_votes[i] < n_votes[max_index]) {
      n_votes[i] = 0;
    }
  }

  return (1 + biased_roshambo (n_votes[0]/(double)(n_votes[0] + n_votes[1] + n_votes[2]), 
                               n_votes[1]/(double)(n_votes[0] + n_votes[1] + n_votes[2]))
          ) % 3;
}
/*  russrocker4  */
/*----------------------------------------------------------------------------*/
/*============================================================================*/
//  END OF                    R U S S R O K E R 4           
/*============================================================================*/



