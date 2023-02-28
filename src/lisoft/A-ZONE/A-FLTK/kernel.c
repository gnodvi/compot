/*******************************************************************************
 *                                                                             *
 *  interface.hh  --  
 *                                                                             *
 *  Copyright (c) 2001,  Gennady M.                                            *
 *                                                                             *
  ******************************************************************************
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
             
//#include  <iostream.h>
#include  <iostream>

using namespace std;
/*----------------------------------------------------*/

#include  "a-comm.h" 
#include  "kernel.h" 



//#ifdef  D_KERNEL  

int X0_DRAW;
int Y0_DRAW;

/*******************************************************************************/
#define N_ENTRIES 8192

//------------------------------------------------------------------------------
Fl_Gnuplot::Fl_Gnuplot (int x, int y, int w, int h, const char *l) : Fl_Box(x,y,w,h,l) 
{
  char *temp_dir = "/tmp/GP/GP-XXXXXX";

  filename[0] = 0;
  loaded = 0;
  scaleX = 1.0;
  scaleY = 1.0;

  currentIndex=0;

  nEntries = 0;
  nMaxEntries = N_ENTRIES;
  entries = new OutputEntry[nMaxEntries];

  system ("mkdir /tmp/GP");

  //tmpnam (pre);
  strcpy (pre, temp_dir);
  mkstemp (pre);

  std::ofstream f1 (pre);
  if (f1) {
    f1 << "set term xlib\n";
  } else {
    ZError ("ofstream f1");
  }

  //tmpnam (post);
  strcpy (post, temp_dir);
  mkstemp (post);
  std::ofstream f2 (post);

  //tmpnam (data);
  strcpy (data, temp_dir);
  mkstemp (data);
  std::ofstream f3 (data);

  //tmpnam (script);
  strcpy (script, temp_dir);
  mkstemp (script);
  std::ofstream f4 (script);

  set_filename (script);
}
//------------------------------------------------------------------------------
Fl_Gnuplot::~Fl_Gnuplot () 
{
  unlink(pre);
  unlink(post);
  unlink(data);
  unlink(script);
  delete [] entries;
}
//------------------------------------------------------------------------------
void
Fl_Gnuplot::clear_entries (int release) 
{
  nEntries = 0;
  if (!release || nMaxEntries <= N_ENTRIES) 
    return;

  cerr << "clear_entries\n";
  delete [] entries;
  nMaxEntries = N_ENTRIES;
  entries = new OutputEntry[nMaxEntries]; 
  cerr << "/clear_entries\n";

}
//------------------------------------------------------------------------------
void
Fl_Gnuplot::add_entry (char *buf) {

  if (nEntries == nMaxEntries) {
    nMaxEntries += N_ENTRIES;
    OutputEntry *nn = new OutputEntry[nMaxEntries];
    int i;
    for(i=0 ; i<nEntries ; i++) {
      nn[i] = entries[i];
    }
    delete [] entries;
    entries = nn;
  }

  if (buf[0] == 'G') {
    clear_entries();
    nEntries = 1;
    entries[0].k = 'G';

    delete [] entries[0].t;
    entries[0].t = 0;
    return;
  }
        
  OutputEntry &e = entries[nEntries];
  nEntries++;
	
  char *str;
  e.k = buf[0];
  delete [] e.t;
  e.t = 0;

  switch(e.k) {
  case 'L':
    sscanf(buf, "L%4d", &e.x);
    e.x = (e.x % 8) + 2;
    break;
  case 'M':
    sscanf(buf, "M%4d%4d", &e.x, &e.y);
    break;
  case 'V':
    sscanf(buf, "V%4d%4d", &e.x, &e.y);
    break;
  case 'J':
    sscanf(buf, "J%4d", &e.x);
    break;
  case 'T':
    sscanf(buf, "T%4d%4d", &e.x, &e.y);
    str = buf + 9;
    e.t = new char[strlen(str)+1];
    strcpy(e.t, str);
    break;
    break;
  case 'R':
    break;
  }
  
}
//------------------------------------------------------------------------------

enum JUSTIFY {
	LEFT, CENTRE, RIGHT
};

static int _colors[13] = { FL_WHITE, FL_BLACK, FL_BLACK, FL_BLACK,
			   FL_BLACK, FL_RED, FL_GREEN, FL_BLUE,
			   FL_MAGENTA, FL_CYAN, FL_GRAY, FL_GRAY, FL_GRAY };

//------------------------------------------------------------------------------
void
Fl_Gnuplot::load () {

  clear_entries(1);

  scaleX = 1/4096.0*w();
  scaleY = 1/4096.0*h();

  if (!filename[0])
    return;

  FILE *p;
  char buf[10*MAXPATHLEN];

  build_command(buf);
  p = popen(buf, "r");
  if (!p) {
    printf("could not open pipe\n");
    return;
  }

  while(!feof(p)) {
    if (fgets(buf, 1023, p)) {
      add_entry(buf);
    }
  }
  pclose(p);
  loaded = 1;

}
//------------------------------------------------------------------------------
void
Fl_Gnuplot::build_command (char *buf) {

  sprintf(buf, "gnuplot %s %s %s", pre, filename, post);
//   sprintf(buf, "gnuplot -background white  %s %s %s ", pre, filename, post);
}
//------------------------------------------------------------------------------
void
Fl_Gnuplot::play () const {

  char *str;
  double sw;
  int jmode;
  int cx, cy;
  int x1, y1;
  int lt;
  int i;

  fl_font (FL_TIMES, 12);
  fl_color (FL_BLACK);

  for (i=0 ; i<nEntries ; i++) { 
    OutputEntry &e = entries[i];
    switch(e.k) {
    case 'G':
      draw_box ();
      draw_label ();
      break;
    case 'L':
      lt = e.x;
      fl_color (_colors[lt+3]);
      break;
    case 'M':
      cx = e.x; cy = e.y;
      break;
    case 'V':
      x1 = e.x; y1 = e.y;
      fl_line(x() + x1*scaleX, y() + h()-y1*scaleY, x() + cx*scaleX, y() + h()-cy*scaleY);
      cx = x1;
      cy = y1;
      break;
    case 'J':
      jmode = e.x;
      break;
    case 'T':
      x1 = e.x; y1 = e.y;
      str = e.t;
      sw = fl_width (str);
      switch (jmode) {
      case LEFT:
        sw = 0;
        break;
      case CENTRE:
        sw = -sw / 2;
        break;
      case RIGHT:
        sw = -sw;
        break;
      }
      fl_color (_colors[2]);
      fl_draw (str, x() + x1*scaleX + sw, y() + h()-y1*scaleY + fl_height()/3);	   
      fl_color (_colors[lt+3]);
      break;
    case 'R': 
      break;
    }
  }
}
//------------------------------------------------------------------------------
void
Fl_Gnuplot::draw() {

  if (!loaded)
    load();

  play();
}
//------------------------------------------------------------------------------
void
Fl_Gnuplot::set_2d_data (const double *xx, const double *yy, int n, const char *title) 
{		
  ofstream scriptFile(script);
  ofstream dataFile(data);
		
  int i;
		
  currentIndex = 0;

  if (!title || !*title)
    scriptFile << "set nokey\n";
  scriptFile << "plot '" << data << "' index 0 ";
  if (title && *title)
    scriptFile << "title '" << title << "' ";
  scriptFile << " with lines\n";

  for(i=0 ; i<n ; i++) {
    dataFile << xx[i] << " " << yy[i] << endl;
  }
  set_filename(script);

}
//------------------------------------------------------------------------------
void
Fl_Gnuplot::add_2d_data (const double *xx, const double *yy, 
                         int n, const char *title) 
{
  fstream scriptFile(script, ios::app);
  fstream dataFile(data, ios::app);
		
  int i;

  currentIndex++;

  if (!title || !*title)
    scriptFile << "set nokey\n";
  scriptFile << "replot '" << data << "' index " << currentIndex;
  if (title && *title)
    scriptFile << " title '" << title << "' ";
  scriptFile << " with lines\n";

  dataFile << "\n\n";
  for(i=0 ; i<n ; i++) {
    dataFile << xx[i] << " " << yy[i] << endl;
  }
  set_filename(script);

}
//------------------------------------------------------------------------------
void
Fl_Gnuplot::set_2d_polar_data(const double *xx, const double *yy, 
                                int n, const char *title) 
{
  ofstream scriptFile (script);
  ofstream dataFile (data);
		
  int i;
		
  currentIndex = 0;

  scriptFile << "set polar\n";

  if (!title || !*title)
    scriptFile << "set nokey\n";
  scriptFile << "plot '" << data << "' index 0 ";
  if (title && *title)
    scriptFile << "title '" << title << "' ";
  scriptFile << " with lines\n";

  for(i=0 ; i<n ; i++) {
    dataFile << xx[i] << " " << yy[i] << endl;
  }
  set_filename(script);

}
//------------------------------------------------------------------------------
void
Fl_Gnuplot::add_2d_polar_data (const double *xx, const double *yy, 
                               int n, const char *title) 
{
  fstream scriptFile(script, ios::app);
  fstream dataFile(data, ios::app);
	
  int i;

  currentIndex++;

  if (!title || !*title)
    scriptFile << "set nokey\n";
  scriptFile << "replot '" << data << "' index " << currentIndex;
  if (title && *title)
    scriptFile << " title '" << title << "' ";
  scriptFile << " with lines\n";

  dataFile << "\n\n";
  for(i=0 ; i<n ; i++) {
    dataFile << xx[i] << " " << yy[i] << endl;
  }
  set_filename(script);

  return;
}
//------------------------------------------------------------------------------
void
Fl_Gnuplot::resize (int _x, int _y, int _w, int _h) 
{

  Fl_Box::resize(_x, _y, _w, _h);
  scaleX = 1/4096.0*w();
  scaleY = 1/4096.0*h();

}
/******************************************************************************/

/*----------------------------------------------------------------------------*/
int  
YMessageBox (char* message) 
{   
  int w=320, h=200;
                                              
  Fl_Window window (w,h);                                                   

  Fl_Box box(FL_BORDER_BOX, 30,20, w-60,h-10-60, message);  
  box.color(FL_CYAN);

  /* Fl_Return_Button ok (w/2-40, h-40, 80, 25, "OK");  */                                
  /* static  */Fl_Button ok (w/2-40, h-40, 80, 25, "OK");                                 
  ok.color (FL_CYAN);

  window.color (FL_BLUE);
  window.label("YMessageBox");                                                              

  window.hotspot(&ok); // you must position modal windows                 
  window.end();                                                               
  window.set_modal();                                                         
  window.show();                                                              

  for (;;) {                                                                  
    Fl::wait();                                                               
    Fl_Widget *o;                                                             
    while ((o = Fl::readqueue())) {                                           
      if (o == &ok)                                                          
        return 1;                                                             
      /*       else                              */
      /*         return 0;                                                              */
    }                                                                         
  }                                                                           

  /*   for (;;) { */
  /*     Fl_Widget *o = Fl::readqueue(); */
  /*     if (!o) Fl::wait(); */
  /*     else if (o == &ok) return 1; */
  /*     else               return 0;  */
  /*   } */
}                                                                             
/*-------------------------------PROC_NULL------------------------------------*/
void 
PROC_NULL (Fl_Widget *wid, void *ptr) 
{  

  return;
}  
/*----------------------------------YPush------------------------------*/ 
Fl_Widget *
YPush (char *name, int x, int y, int w, int h, Fl_Callback proc)
{
  CALCXY(x,y);

  /* #define OB ((Fl_Button*)(buton)) */
  /* static Fl_Button *buton; */
  static Fl_Button *OB;

  OB = new Fl_Button(x, y, w, h, name);                       
  OB->callback(proc, NULL);
  /* 	OB->color(WND->color); */
  /* 	OB->down_color(YColor("white")); */
  OB->labelfont(3);
  /* 	OB->labelsize(Y_FONT_SIZE); */
  /* fltkwin->add(OB); */

  /* OB->redraw(); */

  return (OB);
}
/*----------------------------------YCheck------------------------------*/ 
Fl_Widget *
YCheck (char *name, int x, int y, int w, int h)
{
  static Fl_Button *OB;

  OB = new Fl_Button(x, y, w, h, name);          
  /* 	OB->callback(F_CHECK_CB, WND->pid); */
  OB->when(FL_WHEN_RELEASE);

  OB->type(FL_TOGGLE_BUTTON);
  OB->align(FL_ALIGN_RIGHT);
  OB->labelfont(3);
  /* 	OB->labelsize(Y_FONT_SIZE); */

  /* 	OB->color(WND->color); */
  /* 	OB->selection_color(FL_RED); */

  /* OB->redraw(); */
  /*     YDrawString (WND->name, WND->w+WND->w/2, WND->h/2, YColorV("vc_black"));  */
  /* fltkwin->draw_outside_label(OB);  */

  return (OB);
}
/*----------------------------------YList------------------------------*/ 
Fl_Widget *
YList (int x, int y, int w, int h, char **list, int top_line)
{
  static Fl_Hold_Browser *OB;
  char **l;

  OB =  new Fl_Hold_Browser (x, y, w, h);       
  /* 	OB->callback(F_LIST_CB, WND->pid); */
  /* 	OB->color(WND->color, YColor("white"));  */
  OB->box(FL_FRAME_BOX);

  for (l=list; *l!=NULL; l++) 
    OB->add(*l);

  OB->topline(top_line);
  OB->redraw();

  return (OB);
}
/*----------------------------------YScroll------------------------------*/ 
Fl_Widget *
YScroll (int x, int y, int w, int h, int type, int full_size, int item_size, int item_top)
{
  static Fl_Scrollbar *OB;

  OB = new Fl_Scrollbar(x, y, w, h, "");                  
  /* 	OB->callback(F_SCROLL_CB, WND->pid); */

  OB->type(type);
  /* 	else */
  /* 	  OB->type(FL_HORIZONTAL); */

  OB->minimum(0);
  OB->maximum(full_size);
  /* o->value(item_top); */  /*??*/
  OB->slider_size((float)item_size/full_size);

  /* 	OB->color(WND->color); */
  OB->selection_color(FL_RED);

  OB->redraw();

  return (OB);
}
/*----------------------------------YEdit------------------------------*/ 
Fl_Widget *
YEdit (char *name, int x, int y, int w, int h, char *text)
{
  static Fl_Input *OB;

  CALCXY(x,y);

  OB = new Fl_Input(x, y, w, h, name);               
  /* 	OB->callback(F_EDIT_CB, WND->pid); */

  /* OB->type(FL_TOGGLE_BUTTON); */
  /* OB->align(FL_ALIGN_RIGHT); */
  OB->textfont(3);
  /* 	OB->textsize(Y_FONT_SIZE); */

  OB->labelfont(3);
  /* 	OB->labelsize(Y_FONT_SIZE); */

  OB->insert(text);
  /* OB->when(FL_WHEN_ENTER_KEY|FL_WHEN_NOT_CHANGED); */
  OB->when(FL_WHEN_RELEASE|FL_WHEN_NOT_CHANGED);

  /* 	OB->color(WND->color); */
  OB->selection_color(FL_RED);

  OB->redraw();
  return (OB);
}
/*----------------------------------YClock------------------------------*/ 
Fl_Widget *
YClock (int x, int y, int w, int h)
{
  static Fl_Clock *OB;

  OB = new Fl_Clock(x, y, w, h, "");
  OB->labelfont(3);
  /* 	OB->labelsize(Y_FONT_SIZE); */
  OB->box(FL_OSHADOW_BOX);
  OB->align(130);

  OB->color(FL_WHITE);
  OB->selection_color(FL_RED);

  OB->redraw();
  return (OB);
}  
/*----------------------------------YTopmenu------------------------------*/ 
Fl_Widget *
YTopmenu (int x, int y, int w, int h, Fl_Menu_Item *items, Fl_Callback cb)
{
  static Fl_Menu_Bar *OB;

  OB = new Fl_Menu_Bar (x, y, w, h);                       
  OB->callback(cb, NULL);
  /* 	OB->color(WND->color); */
  OB->selection_color(FL_BLUE);
  OB->textfont(3);
  /* 	OB->textsize(Y_FONT_SIZE); */
  OB->menu(items);

  OB->redraw();
  return (OB);
}
/*----------------------------------YDecimal------------------------------*/ 
Fl_Widget *
YDecimal (char *name, int x, int y, int w, int h, int v_min, int v_max)
{
  static Fl_Value_Slider *OB;

  OB = new Fl_Value_Slider (x, y, w, h, name); 
  OB->type(FL_HOR_NICE_SLIDER);
  OB->range(v_min, v_max);
  OB->step (1);
  /* 	OB->label(FL_ALIGN_LEFT, "kjkjkjkj"); */
  OB->align(FL_ALIGN_LEFT);

  /* OB->redraw(); */
  return (OB);
}
/*-------------------------------YDrawGroup---------------------------------*/ 
void 
YDrawGroup (char *sText, int x, int y, int w, int h, YT_COLOR color) 
{ 
  static Fl_Box *box;
 
  box = new Fl_Box (FL_BORDER_BOX, x, y, w, h, "");  
  box->color (color);

  return; 
} 
/*------------------------------YSetOrigin----------------------------------*/ 
void 
YSetOrigin (int x0, int y0) 
{ 
  X0_DRAW = x0; 
  Y0_DRAW = y0; 
  return; 
}  
/*------------------------------YGetOrigin----------------------------------*/ 
void 
YGetOrigin (int *x0, int *y0) 
{ 
  *x0 = X0_DRAW; 
  *y0 = Y0_DRAW; 
  return; 
} 
/*-----------------------------YGroup----------------------------------*/ 
void 
YGroup (int numer, char *name, int x, int y, int w, int h, YT_COLOR color) 
{ 
  static int x0group[100], y0group[100];
  static int cur=0;
       
  if (numer == 1) {
    if (name != NULL)  
      YDrawGroup (name, x, y, w, h, color); 
     
    YGetOrigin (&(x0group[cur]), &(y0group[cur])); 
    YSetOrigin (x0group[cur] + x, y0group[cur] + y);
    cur++;
    
  } else {
    cur--;
    YSetOrigin (x0group[cur], y0group[cur]); 
  }

  return;
} 
/*-----------------------------YBeginGroup----------------------------------*/ 
void 
YBeginGroup (char *name, int x, int y, int w, int h, YT_COLOR color) 
{ 
       
  YGroup (1, name, x, y, w, h, color); 
  
} 
/*-------------------------------YEndGroup----------------------------------*/ 
void 
YEndGroup () 
{ 
 
  YGroup (2, NULL, 0, 0, 0, 0, FL_WHITE); 
 
} 
/*----------------------------------YBook-----------------------------*/ 
Fl_Widget *
YBook (int x, int y, int w, int h, YT_BOOK *pages)
{
  int h_capt = 20;

  { Fl_Tabs* o = new Fl_Tabs(x, y, w, h);
  o->selection_color(15);

  for (YT_BOOK *pb=pages; pb->text!=NULL; pb++) {
    { Fl_Group* o = new Fl_Group(x, y+h_capt, w, h-h_capt, pb->text);
    o->color(pb->color);
    o->hide();
    YBeginGroup (NULL, x, y+h_capt, w, h-h_capt, pb->color); 
    pb->proc (); 
    YEndGroup ();	
    o->end();
    Fl_Group::current()->resizable(o);
    }
  }

  o->end();
  Fl_Group::current()->resizable(o);

  return (o);
  }

}
/*--------------------------about_proc------------------------------------*/
void 
about_proc (Fl_Widget *wid, void *ptr) 
{  
  char buf[80];

  strcpy (buf, "Primer");
  YMessageBox ("Sorry, it's under construction!!");

  /* fl_message ("Sorry, it's under construction!!"); */
 
  /* get_string(buf);   */                                               

  return;
}  
/*==========================================================================*/

//#endif // D_KERNEL 
