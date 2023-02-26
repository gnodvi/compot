// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************
 *                                                                          *
 *  demons.c  --  demo examples for "Library Yzone";                        *
 *                                                                          *
 *  Copyright (c) 2000, Life Software.                                      *
 *                                                                          *
 *  This library is free software; you can redistribute it and/or           *
 *  modify it under the terms of the GNU Library General Public             *
 *  License as published by the Free Software Foundation; either            *
 *  version 2 of the License, or (at your option) any later version.        *
 *                                                                          *
 *  This library is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       *
 *  Library General Public License for more details.                        *
 *                                                                          *
 *  You should have received a copy of the GNU Library General Public       *
 *  License along with this library; if not, write to the Free              *
 *  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.      *
 *                                                                          *
 *                Life Software:                                            *
 *                Web:     http://www.chat.ru/~lifesoft                     *
 *                E-mail:  lifesoft@chat.ru                                 *
 *                                                                          *
 ****************************************************************************
 */                                                                          
                                                                             


#ifdef  D_FLTK_TEST2  
/*************************************************************************
 *                                                                       *
 *        Test2 for library FLTK                                         *  
 *                                                                       *
 *************************************************************************
 */ 

#include <FL/Fl.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Menu_Bar.H>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <FL/fl_draw.H>
#include <FL/Fl_Box.H>                                                        
#include <FL/Fl_Input.H>                                                      
#include <FL/Fl_Button.H>                                                     
#include <FL/Fl_Return_Button.H>                                              
                                                                              

Fl_Menu_Item big_menu[] = {
  {"Buffers", 0,0,0, FL_SUBMENU},
    {"New Window", 0,0,0, FL_MENU_DIVIDER}, 
    {"Open ..."},
    {"Save"},     
    {"Save All"},     
    {"Save As ...", 0,0,0, FL_MENU_DIVIDER},     
    {"Kill"},     
    {"Split"},     
    {"Unsplit"},     
    {"List All", 0,0,0, FL_MENU_DIVIDER},     
    {"Exit"},     
    {0},
  {"Edit", 0,0,0, FL_SUBMENU},
    {"Undo"},
    {"Redo", 0,0,0, FL_MENU_DIVIDER},
    {"Cut"},
    {"Copy"},
    {"Paste"},
    {0},
  {"Search", 0,0,0, FL_SUBMENU},
    {"Find ..."},
    {"Find Again ...", 0,0,0, FL_MENU_DIVIDER},
    {"Replace ..."},
    {"Replace Again", 0,0,0, FL_MENU_DIVIDER},
    {"Goto Line"},
    {0},
  {"Project", 0,0,0, FL_SUBMENU},
    {"Open ..."},
    {"Close ..."},
    {"New", 0,0,0, FL_MENU_DIVIDER},
    {"Options ...", 0,0,0, FL_MENU_DIVIDER},
    {"Run ..."},
    {0},
  {"Compile", 0,0,0, FL_SUBMENU},
    {"Make All"},
    {"Make ...", 0,0,0, FL_MENU_DIVIDER},
    {"Next Error"},
    {"Prev Error", 0,0,0, FL_MENU_DIVIDER},
    {"Help Error"},
    {0},
  {"Debug", 0,0,0, FL_SUBMENU},
    {"Run/Continue"},
    {"Stack Next"},
    {"Stack Prev", 0,0,0, FL_MENU_DIVIDER},
    {"Goto"},
    {"Step"},
    {"Next", 0,0,0, FL_MENU_DIVIDER},
    {"Set B-point"},
    {"Del B-point", 0,0,0, FL_MENU_DIVIDER},
    {"Stop"},
    {0},
  {"Options", 0,0,0, FL_SUBMENU},
    {"Big Menu"},
    {"Min Menu", 0,0,0, FL_MENU_DIVIDER},
    {"Text Font"},
    {0},
  {"Help", 0,0,0, FL_SUBMENU},
    {"About"},
    {"Index"}, 
    {0},
  {0}
};


Fl_Menu_Item min_menu[] = {
  {"Buffers", 0,0,0, FL_SUBMENU},
    {"New Window", 0,0,0, FL_MENU_DIVIDER}, 
    {"Open ..."},
    {"Save"},     
    {"Save All"},     
    {"Save As ...", 0,0,0, FL_MENU_DIVIDER},     
    {"Kill"},     
    {"Split"},     
    {"Unsplit"},     
    {"List All", 0,0,0, FL_MENU_DIVIDER},     
    {"Exit"},     
    {0},
  {"Edit", 0,0,0, FL_SUBMENU},
    {"Undo"},
    {"Redo", 0,0,0, FL_MENU_DIVIDER},
    {"Cut"},
    {"Copy"},
    {"Paste"},
    {0},
  {"Search", 0,0,0, FL_SUBMENU},
    {"Find ..."},
    {"Find Again ...", 0,0,0, FL_MENU_DIVIDER},
    {"Replace ..."},
    {"Replace Again", 0,0,0, FL_MENU_DIVIDER},
    {"Goto Line"},
    {0},
  {"Options", 0,0,0, FL_SUBMENU},
    {"Big Menu"},
    {"Min Menu", 0,0,0, FL_MENU_DIVIDER},
    {"Text Font"},
    {0},
  {"Help", 0,0,0, FL_SUBMENU},
    {"About"},
    {"Index"}, 
    {0},
  {0}
};

  Fl_Window *window;

/*--------------------------------------------------------------------*/
int 
MessageBox (char* message) 
{   
	int w=320, h=200;
                                              
  Fl_Window window (w,h);                                                   

  Fl_Box box(FL_BORDER_BOX, 30,20, w-60,h-10-60, message);  
	box.color(FL_CYAN);

/*   Fl_Button    cancel( 60, h-40, 80, 25, "cancel");                                  */
  Fl_Return_Button ok (w/2-40, h-40, 80, 25, "OK");                                 
	ok.color (FL_CYAN);

	window.color (FL_BLUE);
  window.hotspot(&/* cancel */ok); // you must position modal windows                 
  window.end();                                                               
  window.set_modal();                                                         
  window.label("MessageBox");                                                              
  window.show();                                                              

  for (;;) {                                                                  
    Fl::wait();                                                               
    Fl_Widget *o;                                                             

    while ((o = Fl::readqueue())) {                                           
      if (o == &ok)                                                          
        return 1;                                                             
      else                             
        return 0;                                                             
    }                                                                         
  }                                                                           

}                                                                             
/*----------------------------------------------------*/
void 
test_cb (Fl_Widget* w, void*) 
{
  Fl_Menu_* mw = (Fl_Menu_*)w;
  const Fl_Menu_Item* m = mw->mvalue();

  if (!m) {
    printf("NULL\n");
    return;
  }

  if      (strcmp(m->label(), "Exit")==0) 
    exit(0);
  else if (strcmp(m->label(), "Min Menu")==0) {
    printf("-- Min Menu -- \n");
    window->make_current();
    fl_color(FL_RED);  
    fl_rectf(50, 50, 20, 20);

    static Fl_Button b1(60, 100, 80, 25, "&Beep");                       
    window->add(b1);

    window->redraw();
		

    /* mw->menu(big_menu); */
    /* (w->parent())->redraw(); */
    /* redraw(); */
    /* w->show(); */ /* ??? */
  } else {
    MessageBox ((char*)(m->label()));
  }

  if (m->shortcut())
    printf("%s - %s\n", m->label(), fl_shortcut_label(m->shortcut()));
  else
    printf("%s\n", m->label());

  /* char buffer[80]; */

}
/*-----------------------------------main------------------------------*/
int 
main (int argc, char **argv) {

  int h_menu;
  int x, y, w, h;
  int width  = 600;
  int height = 400;

  window = new Fl_Window(width,height);

  h_menu = 30;

  Fl_Menu_Bar menubar (0,0,width,h_menu); 

  menubar.menu(big_menu);
  menubar.callback(test_cb);
  menubar.color(FL_WHITE);
  menubar.selection_color(FL_BLUE);

  window->size_range(300,20);
  window->color(FL_GREEN);

  x = 170;
  y = 20 + h_menu;
  w = width - 190;
  h = height - h_menu - 40;
  Fl_Box *box = new Fl_Box (FL_BORDER_BOX, x,y,w,h, "Hello, World!");  
  box->color(FL_YELLOW);

  window->end();
  window->show(argc, argv);
  window->make_current();

  return Fl::run();
}
/*******************************************************************************/

#endif
/*******************************************************************************/

