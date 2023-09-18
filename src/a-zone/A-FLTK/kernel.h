/*******************************************************************************
 *                                                                             *
 *  interface.hh  --                                                           *
 *                                                                             *
  ******************************************************************************
 */   
                                                                       
#include <unistd.h>
#include <sys/param.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <fstream.h>
#include <fstream>

#include <math.h>
                                                                             
#include <FL/Fl.H>
#include <FL/Fl_Window.H> 
#include <FL/Fl_Menu_Bar.H>
#include <FL/fl_draw.H>
#include <FL/Fl_Box.H>                                                        
#include <FL/Fl_Input.H>                                                      
#include <FL/Fl_Menu_Button.H>
#include <FL/Fl_Button.H>                                                     
#include <FL/Fl_Toggle_Button.H>
#include <FL/Fl_Return_Button.H>                                              
#include <FL/Fl_Slider.H>
#include <FL/Fl_Value_Slider.H>                                                       
#include <FL/Fl_Scrollbar.H>                                                    
#include <FL/Fl_Clock.H>                                                        
//#include <FL/fl_file_chooser.H>                                                 
#include <FL/Fl_Hold_Browser.H>
#include <FL/Fl_Tabs.H>
#include <FL/fl_message.H>                                                      
                                                                              
/*----------------------------------------------------------------------------*/

extern int X0_DRAW;
extern int Y0_DRAW;

#define YT_COLOR Fl_Color

/* typedef struct { */
/*   char     *text; */
/*   Fl_Callback proc; */
/*   Fl_Color color;  */
/* } YT_BOOK;  */

enum keys { 
  YLEVEL1_BEGIN = 0, 

	YINIT, YCALC, YOPEN, YSAVE,
  
  YLEVEL1_END 
};

typedef  void (*YT_PFUNC) (void);                             

typedef struct {
  char     *text;
  YT_PFUNC  proc;
  Fl_Color color; 
  /* Fl_Callback proc; */
} YT_BOOK; 

void   PROC_NULL (Fl_Widget *, void *); 

int        YMessageBox (char* message); 
Fl_Widget *YDecimal (char *name, int x, int y, int w, int h, int v_min, int v_max);
Fl_Widget *YPush (char *name, int x, int y, int w, int h, Fl_Callback);
Fl_Widget *YList (int x, int y, int w, int h, char **list, int top_line);
Fl_Widget *YCheck (char *name, int x, int y, int w, int h);
Fl_Widget *YScroll (int x, int y, int w, int h, int type, int full_size, int item_size, int item_top);
Fl_Widget *YEdit (char *name, int x, int y, int w, int h, char *text);
Fl_Widget *YClock (int x, int y, int w, int h);
Fl_Widget *YTopmenu (int x, int y, int w, int h, Fl_Menu_Item *items, Fl_Callback cb);
// Fl_Widget *YBook (int x, int y, int w, int h);
void  about_proc (Fl_Widget *wid, void *ptr); 
void  YBeginGroup (char *name, int x, int y, int w, int h, YT_COLOR color); 
void  YEndGroup (void); 
Fl_Widget *
YBook (int x, int y, int w, int h, YT_BOOK *pages);
void 
about_proc (Fl_Widget *wid, void *ptr); 


#define  CALCXY(x,y)      { x=x+X0_DRAW;  y=y+Y0_DRAW; }
#define  ANTICALCXY(x,y)  { x=x-X0_DRAW;  y=y-Y0_DRAW; }

/*----------------------------------------------------------------------------*/
/* #include <sys/param.h> */
/* #include <string.h> */
/* #include "Fl/Fl_Widget.h" */
/* #include "Fl/Fl_Box.h" */
/* #include "FL/Fl_Widget.H" */
/* #include "FL/Fl_Box.H" */

class Fl_Gnuplot : public Fl_Box {
private:
  Fl_Gnuplot();
protected:
  char pre[MAXPATHLEN];
  char post[MAXPATHLEN];
  char data[MAXPATHLEN];
  char script[MAXPATHLEN];

  int currentIndex;
  
  char filename[MAXPATHLEN];
  int loaded;

  void play() const;
  void load();

  double scaleX, scaleY;

  struct OutputEntry {
    char k;
    int x, y;
    char *t;
    OutputEntry() : k('G'), x(0), y(0), t(0) {}
    OutputEntry &operator=(OutputEntry &e) {
      delete [] t;
      k = e.k; x = e.x; y = e.y; 
      t = e.t;
      e.t = 0;
    }
    ~OutputEntry() { delete [] t;}
  private:
    OutputEntry(const OutputEntry &e);
		OutputEntry &operator=(const OutputEntry &e);
  };

  OutputEntry *entries;
  int nEntries;
  int nMaxEntries;
  void clear_entries(int release=0);
  void add_entry(char *);
  
  virtual void build_command(char *);

public:

  const char *pre_filename() const { return pre; }
  const char *post_filename() const { return post; }
  const char *script_filename() const { return script; }
  const char *data_filename() const { return data; }
  void touch() { loaded=0; }

  Fl_Gnuplot(int x, int y, int w, int h, const char *l=0);
  ~Fl_Gnuplot();

  void set_filename(const char *f) {
    strcpy(filename, f);
    loaded = 0;
  }

  void draw();
  void resize(int x, int y, int w, int h);

  void set_2d_data(const double *, const double *, int n, const char *label = 0);
  void add_2d_data(const double *, const double *, int n, const char *label = 0);
	
  void set_2d_polar_data(const double *, const double *, int n, const char *label = 0);
  void add_2d_polar_data(const double *, const double *, int n, const char *label = 0);
};
/*----------------------------------------------------------------------------*/
// fltk-common.h  

/*----------------------------------------------------------------------------*/
