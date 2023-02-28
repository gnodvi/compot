// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: dialog.c                                                  *
 *                                                                             *
  ******************************************************************************
 */ 

// TODO:
// - неправильная рейтинг-система! случайное распределение гандикапа - это 
//   почти сразу проигрыш, или хотя бы исключить крайности -  бортики и центр!
//   кто в центре - выиграл, с краю - проиграл!
//  
//  
//  
//  
//  
 
/******************************************************************************/
#ifdef _UNIX  

#include <FL/x.H>
//#include "i_blauw.xpm"
  Pixmap p;
#define _ENG  
 
#else /************************************************************************/

#include  <windows.h> 
#define DIAL_ICON 345
#include <FL/x.H>

#endif
/******************************************************************************/

/******************************************************************************/
                                                                            
#include  <stdio.h>
#include  <stdlib.h>  
#include  <string.h>
#include  <math.h>
#include  <time.h>  
#include  <unistd.h> 
#include  <ctype.h>  
//#include  <dirent.h> 
#include  <sys/time.h> 
#include  <sys/param.h>
                                                                             
/****************************************************************************/

#include "common.h"
#include "aboard.h"
#include "gowork.h"

//#include "ggtl.h"
#include "minmax.h"
#include "client.h"

//#include "aaa-l.h"
#include "myfltk.h"

/****************************************************************************/
#include <FL/Fl.H>
#include <FL/Fl_Double_Window.H>
#include <FL/Fl_Bitmap.H>
#include <FL/fl_draw.H>
#include <FL/Fl_Menu_Item.H>
#include <FL/fl_ask.H>

#define  YNEW    01
#define  YNULL   02
#define  YEXIT   03
#define  YHELP   04
#define  YABOUT  05


//*****************************************************************************/   
typedef struct {

  int      nn;
  char    *game_name;
  GO_GAME *game;
  double   rating, rat;
  int      gamer0;
  int      game_end;

} YT_ATARIGO;

YT_ATARIGO* ata_begin (char *name, int nn);
void        ata_final (YT_ATARIGO *pa); 
void        ata_newgame (YT_ATARIGO *pa, char *name, int nn) ;
//void        set_position (GO_GAME *); 
//******************************************************************************

YT_ATARIGO atarigo/* , *pa = &atarigo */;


/*----------------------------------------------------------------------------*/
void  
ata_rating_read (YT_ATARIGO *pa) 
{
  FILE *inifile;
  inifile = fopen ("atarigo.ini", "r");

  if (!inifile) {
    pa->rating = 0; 
  } else {
    fscanf (inifile, "%lf", &(pa->rating));
  }

  return;
}
/*----------------------------------------------------------------------------*/
void  
rating_write (double rating) 
{
  FILE *inifile;
  inifile = fopen ("atarigo.ini", "w");

  if (!inifile)
    Error ("rating_write");
  else {
    fprintf (inifile, "%f", rating);
  }

  return;
}
/*----------------------------------------------------------------------------*/
YT_ATARIGO* 
ata_begin (char *name, int nn) 
{

  YT_ATARIGO *pa = (YT_ATARIGO*) malloc (sizeof (YT_ATARIGO));

  ata_rating_read (pa);
  pa->rat = /* 0.25 */0.5;

  pa->game_name = name; 
  pa->nn    = nn;

  return (pa);
}
/*----------------------------------------------------------------------------*/
void
ata_final (YT_ATARIGO *pa) 
{

  rating_write (pa->rating);

  free (pa);
  return;
}
/*----------------------------------------------------------------------------*/
//*****************************************************************************/   

int  about_dialog (); 

void about_cb ();
void help_cb ();

int   dlg_update_check_end (); 
/*******************************************************************************/

#ifdef _ICON
#include <FL/Fl_Image.H>
#include <FL/Fl_Bitmap.H>
static unsigned char idata_splash[] =
"1111111111111111111111111";
static Fl_Bitmap image_splash (idata_splash, 5, 5);
#endif

 
#ifdef _ENG
  char *main_caption  = "  ATARIGO";
  char *main_rating   = "Rating:";
  char *main_status   = "Gaming [ . . . . . . . ]";
  char *main_youwins  = "You Win  !";
  char *main_youlose  = "You Lose..";
  char *main_not_move = "Don't move here!";
  char *mess_ok       = "Ok";
  char *mess_title    = "Message";

  char *menu_game       = "Game";
  char *menu_game_new   = "New Game";
  char *menu_game_null  = "Rating Nulling";
  char *menu_game_exit  = "Exit";

  char *menu_opt        = "Options";

  char *menu_info       = "Help";
  char *menu_info_help  = "Game Rules";
  char *menu_info_about = "About ...";

  char *about_caption = "About";
  char *about_push_ok = "OK";
  char *about_text[]  = {
  "Game   'ATARIGO'",
  "Version 1.2",
  "10 November, 2004 year",
  "",
  "Author: Goga Zahvatov, etc..",
  "E-mail: gennady.em@gmail.com",
  "",
  "Copyright (с) Goga Software",
  "http://www.....",
  "",
  "See also file README",
  NULL
  };

  char *help_caption = "Rules of Game";

#else
#include "russia.h"

#endif


/*******************************************************************************/

  Fl_Color color_white_stone = background2;
  Fl_Color color_black_stone = foreground;

  Fl_Color color_group       = background;
  Fl_Color color_group_rect  = foreground;
  Fl_Color color_board       = background;
  Fl_Color color_board_rect  = foreground;

  Fl_Color color_goban       = background2;
  Fl_Color color_goban_lines = foreground ;
  //--------------------------------


  int WW = 250;
  int HH = 300;

  Fl_Window *main_window;
  Fl_Window *win;                                                               

#define NEW_BOARD(i, j) (new_board[i*(pa->nn)+j])
#define OLD_BOARD(i, j) (old_board[i*(pa->nn)+j])

  int status_x, status_y, status_w, status_h;
  Fl_Box  *wtext_raiting=NULL, *wtext_status=NULL;
  Fl_Button  *wpush=NULL;

  /* static */ char text_raiting[80];
  /* static */ char text_status [80];


/*******************************************************************************/

YT_ATARIGO *pa;

#define SPRINT_RATING (sprintf (text_raiting, "%+3.1f",  pa->rating))
//#define SPRINT_RATING (sprintf (text_raiting, "%+4.2f",  pa->rating))
#define SPRINT_STATUS(stat) (sprintf (text_status,  "%s",  (stat)))

/*******************************************************************************/

//void  ata_newgame (YT_ATARIGO *pa, char *name, int nn) ;

void  draw_updated () ;
void  showboard (); 
void  draw_rating (); 
void  draw_status (char *status);
void  draw_newgame (); 
void  newboard (); 
int   endgame (); 
void  menu_new (); 
void  menu_exit ();
void  one_step_moves (int i, int j) ;
int   human_move (int i, int j) ;
int   computer_move () ;


/*******************************************************************************/
/*-----------------------------paint_stone_black------------------------------*/
void 
paint_stone_black (int x, int y, int r) 
{
  //int step = r;
  //if (!fl_not_clipped(x,y,ISIZE,ISIZE)) return;

  //fl_push_no_clip (); // не до конца но работает !!!!!!!!!!!!!!!!! 
  // но лучше вставить в другое место
  //fl_clip (x(),y(), w(),h()); //!!!!!!!!!!!!!!!!!!!!

  //Fl::flush();

  fl_color (color_black_stone);
  fl_pie (x-r/2, y-r/2, r, r, 0,360);   

  //fl_color (color_white_stone);
  //fl_arc (x-step/2, y-step/2, step, step, 0,360);   
  //fl_pop_clip();
  
  //Fl::damage(FL_DAMAGE_ALL/* , x-step/2, y-step/2, step, step */);

  //printf ("paint_stone_black %d %d \n", x, y);
  //Fl::check();
  //Fl::flush();

  return;
}
/*-----------------------------paint_stone_white------------------------------*/
void 
paint_stone_white (int x, int y, int d) 
{
  //int step = r;

  fl_color (color_white_stone);
  fl_pie (x-d/2, y-d/2, d, d, 0,360);   

  fl_color (color_black_stone);
  fl_arc (x-d/2, y-d/2, d, d, 0,360);   

  return;
}
/*----------------------------------------------------------------------------*/


int *new_board;
int *old_board;


/****************************************************************************/
//                         BOARD   BOARD   BOARD   BOARD 
/****************************************************************************/

class Board : public Fl_Widget {

public:

  int  x0_ckick, y0_ckick;
  int  x0, y0, step, size;
  int  X, Y, W, H;

  //int  nn; //=7
  //int  dsize;

//Board *d=NULL;
//Board *d;
/*----------------------------------------------------------------------*/
Board (/* int nnn, */ Fl_Color color, int X,int Y,int W,int H, int dsize) : Fl_Widget (X,Y,W,H) {

  //pa->nn    = nnn;

  color_board = color;

  //newboard (); 
}
/*----------------------------------------------------------------------*/
~Board () {

  //YMessageBox ("Exit");
  //OUTS ("Exit");
  //menu_exit ();

}
/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
int   
Coord_to_Index (int x0, int x) 
{
  int index, o;

  index = (x - x0) / step;
  o     = (x - x0) % step;

  if (o > step/2) index++;

  //fprintf (stderr, "x0=%d x=%d index=%d \n", x0, x, index);
  return (index);
}
/*----------------------------------------------------------------------------*/
int 
handle (int event) 
{
  int    i, j;

  switch (event) {
  case FL_RELEASE:
    //if (game_end) return 0;

    //if (Fl::event_button()==3) {
    //  ata_newgame (pa, pa->game_name, pa->nn);
    //  set_position (pa->game); 
    //  draw_newgame (); 
    //  break;     
    //}

    if (pa->game_end) return 0;

    if (Fl::event_button()!=1) return 0;

    x0_ckick = Fl::event_x();
    y0_ckick = Fl::event_y();    
    j = Coord_to_Index (x0, x0_ckick);
    i = Coord_to_Index (y0, y0_ckick);
    
    one_step_moves (i, j) ;

    if (pa->game_end) {
      game_finish (pa->game);
    }
    break;     
/*  case FL_SHOW: */
/*     OUTD (222); */
/*     //this->menu_new(); */
/*     break;      */
 default:
    return 1;
  }

  return 1;
}
/*----------------------------------------------------------------------------*/
void 
draw_gopoint (int i, int j) 
{
  return;
  if (pa->nn== 7 && !(((i==1)||(i==3)||(i==5)) && ((j==1)||(j==3)||(j==5))))
    return;

  int x = x0 + step*j;
  int y = y0 +step*i;
  int r = /*2.5f*/2;

  //g.FillEllipse (Brushes.Red, x-r, y-r, 2*r, 2*r);
  YDrawRectF (x-r, y-r, 2*r, 2*r, FL_RED);    
  return;
}
/*----------------------------------------------------------------------------*/
int 
Index_to_Coord (int x0, int index) 
{
  int x = x0 + step*index;

  return (x);
}
/*----------------------------------------------------------------------------*/
void 
paint_none (int i, int j, int x, int y, int r) 
{

  //C.DrawRectF (g, x-r, y-r, step, step, board_brush); 

  int xmin = x-r;
  int xmax = x+r;
  int ymin = y-r;
  int ymax = y+r;

  if (j == 0)    xmin = x;
  if (i == 0)    ymin = y;
  if (j == pa->nn-1) xmax = x;
  if (i == pa->nn-1) ymax = y;
    
  //C.DrawLine  (g, xmin, y, xmax, y, Pens.Black);   
  //C.DrawLine  (g, x, ymin, x, ymax, Pens.Black);

  //draw_gopoint  (i, j); 
  return;
}
/*----------------------------------------------------------------------*/
//public:
/*----------------------------------------------------------------------------*/
void 
draw_goban () 
{
  int x = x0-step/2-5;
  int y = y0-step/2-5;
  int w = size+step+10;
  int h = size+step+10;

  YDrawRectFB (x, y, w, h, color_goban, color_goban_lines);   
  //YDrawRectB  (x-1, y-1, w+2, h+2, color_goban_lines);   

  for (int j=0; j < pa->nn; j++) 
    YDrawLine (x0+step*j, y0, x0+step*j, y0+size, color_goban_lines);   
  for (int i=0; i < pa->nn; i++)
    YDrawLine (x0, y0+step*i, x0+size, y0+step*i, color_goban_lines);   

  for (int j=0; j < pa->nn; j++) 
  for (int i=0; i < pa->nn; i++) {

    draw_gopoint (i, j); 
  }

  return;
}
/*----------------------------------------------------------------------------*/
void 
board_calc_sizes () 
{
  X = x();
  Y = y();
  W = w();
  H = h();

  size = YMIN (W, H); // предварительный размер поля
  step = size / (pa->nn-1);   // предварительный размер клетки

  //step = dsize;   // предварительный размер клетки

  //size = (int)(size - 2.0*step);
  //size = (int)(size - 60);
  size = (int)(size - size/3);

  //size = (int)(size - step);
  //size -= 30;
  step = size / (pa->nn-1);
  step = YMIN (step, 29); // надо размеры пристроить к фонту что-ли..

  size = step*(pa->nn-1);

  // координаты начала доски
  x0   = X + (W - size) / 2;
  y0   = Y + (H - size) / 2;
  
  return;
}
/*----------------------------------------------------------------------------*/
void 
draw_stone (int i, int j, int to_move) 
{
  int x, y, r = step/2;
  int l = /* 5 */ /* r-2 */step/5;

  x = Index_to_Coord (x0, j);
  y = Index_to_Coord (y0, i);
  

  fl_push_no_clip (); //??
  //fl_clip (x(),y(), w(),h()); //!!!!!!!!!!!!!!!!!!!!

  switch (to_move) {
  case STONE_BLACK:
    paint_stone_black (x, y, step); 
    break;
  case STONE_WHITE:
    paint_stone_white (x, y, step); 
    break;

  case STONE_WHITE_FALSE:
    YDrawRectF (x-l, y-l, 2*l+1, 2*l+1, color_white_stone);   
    break; 
  case STONE_BLACK_FALSE:
    YDrawRectF (x-l, y-l, 2*l+1, 2*l+1, color_black_stone);   
    break;
 
  case STONE_WHITE_DEAD:
    draw_stone (i, j, STONE_WHITE); 
    draw_stone (i, j, STONE_BLACK_FALSE); 
    break; 
  case STONE_BLACK_DEAD:
    draw_stone (i, j, STONE_BLACK); 
    draw_stone (i, j, STONE_WHITE_FALSE); 
    break;
  
  case STONE_NONE:
    paint_none (i, j, x, y, r); 
    break;
 
  default:
    //MessageBox.Show ("default: draw_stone");
    break;
  }

  fl_pop_clip();  //??
  return;
}
/*----------------------------------------------------------------------------*/
void 
draw_all_stones () 
{

  for (int j=0; j < pa->nn; j++) { 
  for (int i=0; i < pa->nn; i++) {
    //printf (" %d", stone);
    draw_stone (i, j, NEW_BOARD(i,j)); 
  }
  //printf ("\n");
  }

  return;
}
/*----------------------------------------------------------------------------*/

void draw (); 

/*******************************************************************************/
}; // class BOARD
/*******************************************************************************/

/*******************************************************************************/

/*----------------------------------------------------------------------------*/
void 
Board :: draw () {  

  board_calc_sizes (); 

  fl_clip (x(),y(), w(),h()); //!!!!!!!!!!!!!!!!!!!!
  YDrawRectFB (x(),y(), w(),h(), color_board, color_board_rect);

  draw_goban (); 
  draw_all_stones ();

  //fl_color (FL_RED); 
  //fl_draw ("Game ATARIGO", 2, 5); /*??*/

  fl_pop_clip ();
  //fl_color (FL_RED); 
  //fl_draw ("Game ATARIGO", 50, 90); /*??*/
}
/*----------------------------------------------------------------------------*/

/*******************************************************************************/
/*******************************************************************************/



Board *p_board = NULL;


/*******************************************************************************/
/*----------------------------------------------------------------------------*/
void  
set_rating_handicap (double rating) 
{
  int h, handicap, i, j;

  handicap = int (fabs(rating));

  if (rating >= 0) { // первый ход - компутер
    for (h = 0; h < handicap; h++) {
      //computer_move (); 
      //if (game_random_stone_new (pa->game, &i, &j))
      if (game_random_handicap (pa->game, handicap, &i, &j))
        game_set_move (pa->game, i, j, STONE_WHITE);
    }
  ////////////
  } else {
  ////////////
    for (h = 0; h < handicap; h++) {
      //if (game_random_stone_new (pa->game, &i, &j)) // не сработает только, если нет места
      if (game_random_handicap (pa->game, handicap, &i, &j)) // не сработает только, если нет места
        human_move (i, j); 
    }
    computer_move (); 
  }

  return;
}
/*----------------------------------------------------------------------------*/
int
human_move (int i, int j) 
{
  int  ret;

  if (pa->game_end) return (FALSE); //??

  // ход человека
  ret = game_set_move (pa->game, i, j, STONE_BLACK);
  if (!ret) {
    YMessageBox (main_not_move, mess_ok, mess_title);
    return (FALSE);
  }

  return (TRUE);
}
/*----------------------------------------------------------------------------*/
int 
computer_move () 
{

  if (pa->game_end) return FALSE;

  // ход компутера
  if (!game_make_move (pa->game, pa->gamer0, STONE_WHITE)) {

    draw_status ("Белые сдались !");
    pa->game_end = TRUE;
    pa->rating  += pa->rat; 

    return FALSE;
  }

  return TRUE;
}
/*----------------------------------------------------------------------------*/
void  
one_step_moves (int i, int j) 
{

  if (! human_move (i, j)) return;
  if (dlg_update_check_end ()) return;

  if (! computer_move ()) return; 
  if (dlg_update_check_end ()) return;

  return;
}
/*----------------------------------------------------------------------------*/
void 
menu_new () 
{
  if (!pa->game_end) pa->rating -= pa->rat;  
  //work_endgame ();  // ???? !!!!

  ata_newgame (pa, pa->game_name, pa->nn);

  set_rating_handicap (pa->rating);  // а это нет!!!!!
  //set_position ();         // это работает!!!

  //game_make_move (pa->game, pa->gamer0, STONE_WHITE);
  //game_make_move (pa->game, pa->gamer0, STONE_WHITE);

  draw_newgame (); 

  return;
} 
/*----------------------------------------------------------------------------*/
void 
menu_exit () 
{

  endgame (); 
  ata_final (pa); 

  exit (0);
  return;
}
/*----------------------------------------------------------------------------*/
void  
ata_newgame (YT_ATARIGO *pa, char *name, int nn) 
{

  pa->game = game_begin (nn, nn);

  pa->gamer0 = game_create_gamer (pa->game, /* NULL, */ name /* game_get_prog (name) */, 0, STONE_WHITE);

  pa->game_end = /* false */FALSE;

  return;
}
/*----------------------------------------------------------------------------*/
int  
endgame () 
{

  delete[] new_board;
  delete[] old_board;

  game_finish (pa->game);

  //ata_final (pa); 
  //rating_write (pa->rating);
 
  return (0);
}
/*----------------------------------------------------------------------------*/
void  
newboard () 
{
  int  nn2 = (pa->nn)*(pa->nn);

  new_board = new int [nn2];
  old_board = new int [nn2];

  for (int i=0; i<pa->nn; i++)
  for (int j=0; j<pa->nn; j++) {
    NEW_BOARD(i,j) = OLD_BOARD(i,j) = STONE_NONE;
  }

  return;
}
/*----------------------------------------------------------------------------*/
void 
draw_newgame () 
{

  dlg_update_check_end ();

  draw_rating (); 
  draw_status (main_status); 
  p_board->redraw();

}
/*----------------------------------------------------------------------------*/
void 
draw_rating () 
{

  SPRINT_RATING;
  wtext_raiting->redraw();

  //fl_font (FL_HELVETICA_KOI8, 10);
  Fl::check();


  return;
}
/*----------------------------------------------------------------------------*/
void 
draw_status (char *status) 
{
  if (status == NULL) return; 

  //sprintf (text_status, "%s", status);
  SPRINT_STATUS (status);
  if (!wtext_status) return;

  wtext_status->redraw();
  Fl::check();
  return;
}
/*----------------------------------------------------------------------------*/
void 
draw_updated () 
{
  // Надо так организовать работу, чтобы в Dialog  вообще не было массивов,
  // т.е. от Client должны поступать конкретные команды по отрисовке,
  // а Dialog только организует правильные запросы и их прием.

  for (int i=0; i<pa->nn; i++)
  for (int j=0; j<pa->nn; j++) {
    if (OLD_BOARD(i,j) == NEW_BOARD(i,j)) continue;

    p_board->draw_stone (i, j, NEW_BOARD(i,j)); 
    OLD_BOARD(i,j) = NEW_BOARD(i,j);
  }

  return;
}
/*----------------------------------------------------------------------------*/
void 
showboard () 
{ 

  game_get_board (pa->game, new_board);
  //game_showboard (pa->game);
  draw_updated ();
 
  return;
}
/*----------------------------------------------------------------------------*/
int 
dlg_update_check_end () 
{
  int   b_cap, w_cap;
  char *mes;

  work_get_captures (/* ptr_work */ (pa->game)->mywork, TRUE, &b_cap, &w_cap);
  showboard ();  

  if  (b_cap==0 && w_cap==0)
    return FALSE;

  // есть захват - конец игре!
  if      (b_cap>0)  {
    pa->rating += pa->rat; 
    mes = main_youwins;
  }
  else if (w_cap>0)  {
    pa->rating -= pa->rat;  
    mes = main_youlose;
  }
  else YERROR ("update_check_end");

  draw_status (mes);
  pa->game_end = TRUE;

  return TRUE;
}
/*----------------------------------------------------------------------------*/




/*----------------------------------------------------*/
void 
menu_proc (Fl_Widget* w, void*) 
{
  
  Fl_Menu_* mw = (Fl_Menu_*)w;
  const Fl_Menu_Item* m = mw->mvalue();

  if (!m) { 
    printf("NULL\n");
    return; 
  }  
  int  myitem = (int)(m->user_data());

  switch (myitem) {
  case YNULL:
    pa->rating = 0;
    draw_rating (); 
    //d->game_end = TRUE;   
    /* p_board-> */pa->game_end = TRUE;   
    //break;
  case YNEW:
    /* p_board-> */menu_new (); 
    break;
  case YEXIT:
    /* p_board-> */menu_exit ();
    break;
  case YHELP:
#ifdef _ENG
    //YHelp ("HELP/sorry.html");
    //YHelp ("HELP/index.html");
#else
    help_cb ();
#endif
    break;
  case YABOUT:
    //about_dialog ();
    about_cb ();
  break;
  default: ;;;
    //YMessageBox ((char*)m->label());
  }

  return;
}
/*---------------------------------------------------------------------*/
void quit_cb (Fl_Widget*, void*) {
  //if (changed && !check_save())
  //  return;
  YMessageBox ("Exit ?", NULL, NULL);

  exit(0);
}
/*---------------------------------------------------------------------*/
void 
make_menu (int x, int y, int w, int h) 
{ 

  static Fl_Menu_Item min_menu[] = {
  {menu_game, 0,0,0, FL_SUBMENU},
    {menu_game_new,  0,0,(void*)YNEW}, 
    {menu_game_null, 0,0,(void*)YNULL, FL_MENU_DIVIDER}, 
    {menu_game_exit, 0,0,(void*)YEXIT},     
  //{"E&xit", FL_CTRL + 'q', (Fl_Callback *)quit_cb, 0 },
    {0},
    

/*   {menu_opt, 0,0,0, FL_SUBMENU}, */
/*     {menu_info_help, 0,0,(void*)YHELP},  */
/*     {menu_info_about, 0,0,(void*)YABOUT},  */
/*     {0}, */

  {menu_info, 0,0,0, FL_SUBMENU},
    {menu_info_help, 0,0,(void*)YHELP}, 
    {menu_info_about, 0,0,(void*)YABOUT}, 
    {0},

  {0} };

  YDrawRectB (x, y, w, h, FL_BLACK); 

  YTopmenu (x+1, y+1, w-1, h-1, min_menu, menu_proc); 

  return;
} 
/*------------------------------push_proc------------------------------------*/
void 
push_proc (Fl_Widget *wid, void *ptr) 
{  
  Fl_Button *p = (Fl_Button*) wid;

  if (p != wpush)  return;

  //if (strcmp (p->tooltip(), "Новая игра")==0) {
  /* p_board-> */menu_new (); 
  //} 
    
  return;
}  
/*******************************************************************************/


/*******************************************************************************/
//                        MYWINDOW   MYWINDOW   MYWINDOW   
/*******************************************************************************/

/*******************************************************************************/
//class My_Window : public Fl_Double_Window {
//class My_Window : public Fl_Overlay_Window {
class My_Window : public Fl_Window {

public:
  My_Window (int x,int y,int w,int h) : Fl_Window (x,y,w,h) {;;}
  My_Window (int w,int h,char*title) : Fl_Window (w,h,title) {;;}
  My_Window (int x,int y,int w,int h,char*title) : Fl_Window (x,y,w,h,title) {;;}

  //My_Window (int x,int y,int w,int h) : Fl_Double_Window (x,y,w,h) {;;}

/*----------------------------------------------------------------------------*/
virtual void 
OPEN_DRAW () {


}
/*----------------------------------------------------------------------------*/
void 
draw () 
{
  DRAWING = TRUE;
  OPEN_DRAW ();

  Fl_Widget *const*a = array();

  if (damage() == FL_DAMAGE_CHILD) { // only redraw some children
    for (int i = children(); i --; a ++) update_child(**a);
  } else 

  { // total redraw
    /* ... draw background graphics ... */
    //YRedrawAll();

    // now draw all the children atop the background:
    for (int i = children(); i --; a ++) {
      draw_child(**a);
      draw_outside_label(**a); // you may not want to do this
    }
  }

  return;
}
/*----------------------------------------------------------------------------*/
/* int  */
/* handle (int e) { */

/*   if (Fl_Window::handle(e)) return 1; */
/*   return 0; */
/* } */
/*----------------------------------------------------------------------------*/
int 
YMOUSE (int message, int x, int y) {

  switch (message) {
  case LEFTDOWN:
    printf ("LEFTDOWN \n");
    break;
  case RIGHTDOWN:
    printf ("RIGHTDOWN \n");
    break;
  case LEFTUP:
    printf ("LEFTUP \n");
    break;
  case RIGHTUP:
    printf ("RIGHTUP \n");
   break;
  default: 
    return (0);
  }

  return (0);
}
/*----------------------------------------------------------------------------*/
/* int  */
/* handle (int event) { */
/*   int  message; */

/*   switch (event) { */
/*   case FL_PUSH: */
/*     if (Fl::event_button() == 1) message = LEFTDOWN; */
/*     if (Fl::event_button() == 3) message = RIGHTDOWN; */
/*     break; */
/*   case FL_RELEASE: */
/*     if (Fl::event_button() == 1) message = LEFTUP; */
/*     if (Fl::event_button() == 3) message = RIGHTUP; */
/*     break; */
/*   default: */
/*     message = -100; */
/*   } */

/*   return (YMOUSE (message, Fl::event_x(), Fl::event_y() )); */
/* } */
/*----------------------------------------------------------------------------*/
/* ~My_Window () { // YDELETE */
/*   OUTS ("~My_Window"); */
/* } */
/*******************************************************************************/
};
/*******************************************************************************/

/*******************************************************************************/
//                         MAIN_ATARIGO     MAIN_ATARIGO 
/*******************************************************************************/
class MAIN_ATARIGO : public My_Window { 

public:

/*----------------------------------------------------------------------------*/
MAIN_ATARIGO (int X, int Y, int W, int H) : My_Window (X, Y, W, H) 
{ 

  //pa = ata_begin ();
  //rating_read (&(pa->rating));
  //pa->game_end = TRUE;  

  SPRINT_RATING; 
  //------------------------

  DRAWING = FALSE;
  OPEN_DRAW ();

  //pa->game_end = TRUE;  

#ifdef _WIND
  /* p_board-> */menu_new (); 
#endif

  //d->work_newgame (d->game_name);
  //d->draw_newgame ();

}
/*----------------------------------------------------------------------------*/
/* ~MAIN_ATARIGO () { */

/*   OUTD(44444); //?????? */
/* } */
/*----------------------------------------------------------------------------*/
void  
OPEN_DRAW () {

  int menu_h=30, h_control=65, w_push=35, h_push=55, x, y, wt;
  int h_text = 25;
  int dd = 5;
  int x_push = 8;
  int y_push = 5;
  int w_text = WW-2*dd-w_push-3*x_push;

  YDrawRectF (0,0, w(),h(), FL_WHITE); // x(),y()  - ?????

  make_menu (dd, dd, WW-2*dd, menu_h); 

  YBeginGroup ("", dd, dd+menu_h, WW-2*dd, h_control, color_group, color_group_rect); 
    YDrawLine ( dd, dd+menu_h, dd+WW-2*dd, dd+menu_h, FL_WHITE);
    YPush (&wpush, "@circle", "Новая игра", x_push, y_push, w_push, h_push, push_proc, color_board);

    YText (&wtext_status,  text_status,  x_push+5+w_push, y_push+5, w_text, h_text, color_group, 
           FL_HELVETICA_KOI8, 14); 

    x = x_push+w_push+8;
    y = y_push+h_text+5;
    fl_font (FL_HELVETICA_KOI8, 14);
    wt = (int) fl_width (main_rating)+5;
    YDrawRectText (main_rating, x, y, wt, h_text, YLEFT, YNONE, foreground); 

    YText (&wtext_raiting, text_raiting, x+wt, y, w_text-wt, h_text, color_group, 
           FL_BOLD /* FL_HELVETICA_KOI8 */, 15);
//fl_font (FL_HELVETICA_KOI8, 10);

  YEndGroup ();
 
  if (!DRAWING) 
    p_board = new Board (/* boardsize, */ color_board /* FL_RED */,
                   dd, menu_h+h_control+2*dd, WW-2*dd, HH-menu_h-h_control-3*dd,  /* 30 */10);
  
  return;
}  
/*----------------------------------------------------------------------------*/
/* int  */
/* handle (int event)  */
/* { */
/*   int    i, j; */

/*   switch (event) { */
/*     case FL_SHOW: */
/*     OUTD (333); */
/*     break;      */
/*  default: */
/*     return 1; */
/*   } */

/*   return 1; */
/* } */
/*******************************************************************************/
};// class MAIN_ATARIGO                                                        // 
/*******************************************************************************/




/*-----------------------------YDrawLogo--------------------------------*/ 
void 
YDrawLogo (int x, int y, int w, int h) 
{ 

  YDrawRectFB (x, y, w, h, background2, foreground); 
  //fl_color (FL_BLACK); 
  //fl_draw ("@circle", x+w/2, y+h/2);
  paint_stone_black (x+w/2, y+h/2, (int) (w/2.5)); 

  return;
} 
/******************************************************************************/

Fl_Button  *ok;
//Fl_Return_Button  *ok;

Fl_Window *dlg_window=NULL;
Fl_Window *help_window=NULL;


/*------------------------------ok_proc------------------------------------*/
void 
ok_proc (Fl_Widget *wid, void *ptr) 
{  

  delete dlg_window;
  dlg_window =NULL;

  //return;

  //this->Fl_Window::~Fl_Window();
  //delete win;
  //OUTD(33);
  Fl::check();
  main_window->redraw (); 
  main_window->make_current();

  p_board->redraw (); 
  //d->make_current (); 
  p_board->draw (); 
  //OUTD(44);

                                      
  Fl::check();
    
  return;
}  


/*******************************************************************************/
//                         ABOUT   ABOUT   ABOUT   ABOUT   
/*******************************************************************************/
class ABOUT : public My_Window { 

public:
  //Fl_Button  *ok;

/*----------------------------------------------------------------------------*/
  //ABOUT (int X, int Y, int W, int H) : My_Window (X, Y, W, H) 
ABOUT (int X, int Y, int W, int H,char *title) : My_Window (X, Y, W, H,title) 
{ 

  ok=NULL;

  DRAWING = FALSE;
  OPEN_DRAW ();
}
/*----------------------------------------------------------------------------*/
void  
OPEN_DRAW () {
  int x, y, dy;
  int dd = 5;

  YDrawRectF (0,0, w(),h(), background);
  YDrawRectFB (dd,dd, w()-2*dd, h()-2*dd, background2, foreground); 

  x = 20;
  y = 20; dy = 15;

  fl_font (FL_HELVETICA_KOI8, 14); //????
  YDrawStrings (about_text, x, &y, dy, FL_BLACK);
  //OUTD(y);

  //y+=13;
  y = 183;
  //printf ("y (push0) = %d \n", y);
  YPush (&ok, about_push_ok, "", x+55, y, 70, 25, ok_proc, color_board);

  return;   //y
}  
/*******************************************************************************/
};//                                                                           // 
/*******************************************************************************/

/*******************************************************************************/
//                         HELP     HELP     HELP     HELP     
/*******************************************************************************/
class HELP : public My_Window { 

public:
  //Fl_Button  *ok;

/*----------------------------------------------------------------------------*/
HELP (int X, int Y, int W, int H,char *title) : My_Window (X, Y, W, H,title) 
{ 
  ok=NULL;

  DRAWING = FALSE;
  OPEN_DRAW ();
}
/*----------------------------------------------------------------------------*/
~HELP ()
{ 

  //delete dlg_window;
  //dlg_window = NULL;

}
/*----------------------------------------------------------------------------*/
void  
OPEN_DRAW () {

  int x, y, dy;
  int dd = 5;

  YDrawRectF (0,0, w(),h(), background);
  YDrawRectFB (dd,dd, w()-2*dd, h()-2*dd, background2, foreground); 

  x = 20;
  y = 20; dy = 15;

#ifdef _ENG
#else
  fl_font (FL_HELVETICA_KOI8, 14); //????
  YDrawStrings (help_text, x, &y, dy, FL_BLACK);
#endif

  return;
}  
/*******************************************************************************/
}; //  class HELP                                                              // 
/*******************************************************************************/

/*-------------------------------------------------------------------*/
void 
about_cb() 
{
  int x, y;

  if (!dlg_window) {
    x = main_window->x() + main_window->w() +10;
    y = main_window->y();
    dlg_window = new ABOUT  (x,y, WW,220, about_caption);

    dlg_window->color(FL_WHITE);
    //Fl_Box *b = new Fl_Box(20,0,380,270,copyright);
    //b->labelsize(10);
    //b->align(FL_ALIGN_LEFT|FL_ALIGN_INSIDE|FL_ALIGN_WRAP);
    dlg_window->end();
  }

  //dlg_window->hotspot(dlg_window);
  dlg_window->set_non_modal();
  dlg_window->show();
}
/*-------------------------------------------------------------------*/
void 
help_cb() 
{
  int x, y;

  if (!help_window) {
    x = main_window->x() + main_window->w() +10;
    y = main_window->y();
    help_window = new HELP  (x,y, (int)(2.2*WW), (int)(2.2*HH), help_caption);

    help_window->color(FL_WHITE);
    help_window->end();
  }

  help_window->set_non_modal();
  help_window->show();
}
/*-------------------------------------------------------------------*/
int 
about_dialog () 
{ 
  win = new Fl_Window (WW, 220, about_caption);

  Fl_Window *about = new ABOUT (0,0, WW, 220, about_caption);
  win->add (about);  
  //win->hotspot(about); // you must position modal windows                 
  //win->hotspot (-100, -100); 
  win->set_modal();

  win->end();                                                           
  //win->set_non_modal();
  win->show ();                                                        

  //Fl::check();
  //main_window->redraw (); 
  //main_window->make_current();
  //return 1;        //?????????????????????????????????                      
  return Fl::run();                                                             

  //-----------------------------------
  for (;;) {                                                                  
    Fl::wait();                                                               
    Fl_Widget *o;                                                             

    while ((o = Fl::readqueue())) {                                           
      if (o == ok)  goto end;;                                                             
    }                                                                         
  }                                                                           

 end:
  delete win;
  //OUTD(33);
  Fl::check();
  main_window->redraw ();                                                        
  Fl::check();

}
/*******************************************************************************/
void close_cb (Fl_Widget*, void* v) {
  //Fl_Window* w = (Fl_Window*)v;
  //if (num_windows == 1 && !check_save()) {
  //  return;

  //YMessageBox ("Close ?");
  /* p_board-> */menu_exit ();

  //exit(0);
  }
/*******************************************************************************/
//
/*******************************************************************************/
int 
  //WinMain (int argc, char **argv) 
main (int argc, char **argv) 
{  
  YStart ();
  WW = 230;  
  HH = 300;
  char *myicon=NULL; 

  main_window = new  Fl_Window (WW, HH, main_caption);

  //boardsize = 5;  // 2, 3, 4, 5, 6, 7
  //deepsize  = 2;

  pa = ata_begin (/* "goga" */ "aigo2", 5);
  //!!!!!!!!!! надо заменить на "aigo" !!!!!!!!!
  newboard (); 


  Fl_Window *main_atarigo = new MAIN_ATARIGO (0,0, WW,HH);
  main_window->add (main_atarigo);                                   

  //main_window->end ();                                                               
 
  //OUTD (1); 
#ifdef _UNIX //--------------------------------------------
  /* set the icon */
  //p = XCreateBitmapFromData(fl_display, DefaultRootWindow(fl_display), (char*)i_blauw_xpm, 64, 64);
  //printf ("33 \n");
  //myicon = (char *) p;
#else //---------------------------------------------------
  if (fl_display == 0)
    fl_display = GetModuleHandle (NULL);

  myicon = (char *) LoadIcon (fl_display, MAKEINTRESOURCE (DIAL_ICON)); 
  if (!myicon) return 0;  
#endif //--------------------------------------------------

  //OUTD (2); 
  main_window->icon (myicon);
  main_window->callback((Fl_Callback *)close_cb);

  Fl::visual (FL_DOUBLE|FL_INDEX);
  //mainwin->show(argc, argv);   // don't do this, uses default user
                                 // colors on windows
  //main_window->show();
  main_window->show (argc, argv);
  //OUTD (3); 

  Fl::flush();

  //OUTD (4); 
  //d->menu_new (); 

  Fl::run(); 
  //OUTD (5); 
                                                            
  //return Fl::run();                                                             
  return 1;                                                             
}  
/******************************************************************************/
// 
/******************************************************************************/


