// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/* random.h */

void usrand (unsigned seed);
unsigned urand0 (void);
unsigned urand (void);
int randint(int upto);

double randreal();

#define MAX_URAND 0xFFFFFFFFL

//------------------------------------------------------------------------------
