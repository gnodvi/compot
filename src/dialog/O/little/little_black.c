//-----------------------------------------------------------------------------
 /*
  * Simple Xlib application drawing a box in a window.
  * gcc input.c -o output -lX11
  */
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
 
#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
//-----------------------------------------------------------------------------
int main (int argc, char **argv)
{
  Display *display;
  Window   window;
  XEvent   event;
  char     *msg = "Hello, World!";
  int      s;

  int       wid; 
  Window parent;
  
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (argc == 1) { 
    display = XOpenDisplay (NULL);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  } else {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    int wid = atoi (argv[1]); // frameid = 0x4600014 !!! а я как целое читаю !!
    
    //printf ("wid = %d \n", wid);
    /* open connection with the server */

    display = XOpenDisplay (wid);
  }
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if (display == NULL)
  {
    fprintf(stderr, "Cannot open display\n");
    exit(1);
  }
  
  s = DefaultScreen (display);
  
  if (argc == 1) { 
    parent =  RootWindow(display, s);
  } else {
    parent = wid;
  }

  /* create window */
  //
  /* Window XCreateSimpleWindow(display, parent, x, y, width, height, border_width, */
  /*      border, background) */
  /*      Display *display; */
  /*      Window parent; */
  /*      int x, y; */
  /*      unsigned int width, height; */
  /*      unsigned int border_width; */
  /*      unsigned long border; */
  /*      unsigned long background; */


  //window = XCreateSimpleWindow (display, parent , 10, 10, 200, 200, 1,
  //                             BlackPixel(display, s), WhitePixel(display, s));
  
  window = XCreateSimpleWindow (display, parent , 0, 0, 100, 100, 1,
                               BlackPixel(display, s), WhitePixel(display, s));
  
  /* select kind of events we are interested in */
  XSelectInput (display, window, ExposureMask | KeyPressMask);
  
  /* map (show) the window */
  XMapWindow (display, window);
  
  /* event loop */
  for (;;)
  {
    XNextEvent (display, &event);
    
    /* draw or redraw the window */
    if (event.type == Expose)
    {
      XFillRectangle (display, window, DefaultGC(display, s), 20, 20, 10, 10);
      XDrawString (display, window, DefaultGC(display, s), 50, 50, msg, strlen(msg));
    }
    /* exit on key press */
    if (event.type == KeyPress)
      break;
  }
  
  /* close connection to server */
  XCloseDisplay (display);
  
  return 0;
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
