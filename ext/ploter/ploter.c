// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: b_test.c                                                  *
 *                                                                             *
  ******************************************************************************
 */ 
                                                                             
#include <gtk/gtk.h>  

#include "p_comm.h"
#include "p_gnup.h"

#include "p_plot.h"
#include "p_plot_more.h"


//#include "b_plox.h"

//newgena #include "gaul.h"
//#include "m_corp.h"  
//#include "m_fgsl.h"  
//#include "s_func.h"


/******************************************************************************/
/*******************************************************************************/
//
//
// GTK+   GTK+   GTK+   GTK+   GTK+   GTK+   GTK+   GTK+   GTK+   GTK+   GTK+   
//
//
/*******************************************************************************/

GtkWidget *main_window;
GtkWidget *scale;


static T_PLOTSTEP *ps;



//==============================================================================
//------------------------------------------------------------------------------
/* For the check button */
//------------------------------------------------------------------------------
static void 
option_check (gpointer callback_data,
              guint    callback_action,
              GtkWidget *menu_item)
{

   g_message ("Check button state = %d \n",
              GTK_CHECK_MENU_ITEM (menu_item)->active);

}
//------------------------------------------------------------------------------
/* For the radio buttons */
//------------------------------------------------------------------------------
static void 
option_radio (gpointer   callback_data,
              guint      callback_action,
              GtkWidget *menu_item )
{

   if (GTK_CHECK_MENU_ITEM (menu_item)->active)
     g_message ("Radio button %d selected \n", callback_action);

}
//------------------------------------------------------------------------------
void
help_about (GtkMenuItem *menuitem, gpointer user_data)
{
  GtkWidget *dialog;
		
  dialog = gtk_message_dialog_new_with_markup (GTK_WINDOW (main_window),
                                               GTK_DIALOG_MODAL,
                                               GTK_MESSAGE_INFO,
                                               GTK_BUTTONS_OK,
"<b>Plot Viewer</b>\n\n\
Example program by:\n\
Ishan Chattopadhyaya and Muthiah Annamalai\n\
for\n\
<i>A Journey through GTK+</i>"
                                               );
	
  gtk_dialog_run (GTK_DIALOG (dialog));
  gtk_widget_destroy (dialog);

  return;
}
//------------------------------------------------------------------------------
/* Get the selected filename and print it to the console */
//------------------------------------------------------------------------------
static void 
file_ok_sel (GtkWidget        *w,
             GtkFileSelection *fs)
{
  const gchar *s_filename;

  s_filename = gtk_file_selection_get_filename (GTK_FILE_SELECTION (fs));
  
  g_print ("%s \n", s_filename);

}
//------------------------------------------------------------------------------
static void 
file_open (GtkWidget *w,
           gpointer   data)
{
  GtkWidget *dialog;

  dialog = gtk_file_selection_new ("Please select a file for editing.");
   
  gtk_file_selection_hide_fileop_buttons (GTK_FILE_SELECTION (dialog));
  //gtk_file_selection_complete (GTK_FILE_SELECTION (dialog), "*.c");
  //GTK_FILE_SELECTION (dialog)->history_pulldown = NULL;
  //GTK_FILE_SELECTION (dialog)->history_menu = NULL;
  //GTK_FILE_SELECTION (dialog)->history_list = NULL;
  //gtk_widget_destroy (GTK_WIDGET(GTK_FILE_SELECTION (dialog)->history_menu));

  g_signal_connect (G_OBJECT (GTK_FILE_SELECTION (dialog)->ok_button),
                    "clicked", G_CALLBACK (file_ok_sel), (gpointer) dialog);

    
  gtk_dialog_run (GTK_DIALOG (dialog));
  gtk_widget_destroy (dialog);

  return;
}
//------------------------------------------------------------------------------
/* Our menu, an array of GtkItemFactoryEntry structures that defines each menu item */
//------------------------------------------------------------------------------

static GtkItemFactoryEntry menu_items[] = {

  { "/_File",         NULL,         NULL,           0, "<Branch>"      },
  { "/File/_Open",    "<control>O", file_open,      0, "<StockItem>",  GTK_STOCK_OPEN },
  { "/File/sep1",     NULL,         NULL,           0, "<Separator>"   },
  { "/File/_Quit",    "<CTRL>Q",    gtk_main_quit,  0, "<StockItem>",  GTK_STOCK_QUIT },

  { "/_Options",      NULL,         NULL,           0, "<Branch>"      },
  { "/Options/Check", NULL,         option_check,   1, "<CheckItem>"   },
  { "/Options/sep",   NULL,         NULL,           0, "<Separator>"   },
  { "/Options/Rad1",  NULL,         option_radio,   1, "<RadioItem>"   },
  { "/Options/Rad2",  NULL,         option_radio,   2, "/Options/Rad1" },
  { "/Options/Rad3",  NULL,         option_radio,   3, "/Options/Rad1" },

  { "/_Help",         NULL,         NULL,           0, "<LastBranch>"  },
  { "/_Help/About",   NULL,         help_about,     0, "<Item>"        },
};

static gint nmenu_items = sizeof (menu_items) / sizeof (menu_items[0]);

//------------------------------------------------------------------------------
/* Returns a menubar widget made from the above menu */
//------------------------------------------------------------------------------
static GtkWidget *
get_menubar_menu (GtkWidget  *window)
{
  GtkItemFactory *item_factory;
  GtkAccelGroup *accel_group;

  /* Make an accelerator group (shortcut keys) */
  accel_group = gtk_accel_group_new ();

  /* Make an ItemFactory (that makes a menubar) */
  item_factory = gtk_item_factory_new (GTK_TYPE_MENU_BAR, "<main>",
                                       accel_group);

  /* This function generates the menu items. Pass the item factory,
     the number of items in the array, the array itself, and any
     callback data for the the menu items. */
  gtk_item_factory_create_items (item_factory, nmenu_items, menu_items, NULL);

  /* Attach the new accelerator group to the window. */
  gtk_window_add_accel_group (GTK_WINDOW (window), accel_group);

  /* Finally, return the actual menu bar created by the item factory. */
  return gtk_item_factory_get_widget (item_factory, "<main>");
}
/*******************************************************************************/
//
//------------------------------------------------------------------------------
static void cb_page_size (GtkAdjustment *get,
                          GtkAdjustment *set)
{
  /* Set the page size and page increment size of the sample
    * adjustment to the value specified by the "Page Size" scale */
  //set->page_size = get->value;
  //  set->page_increment = get->value;

  int val = (gint) get->value;

  ps->plot->ti = val;
  plotbig_step_do (ps, ps->plot->ti);

  // надо бы вернуть фокус в окошко управления после отрисовки графиков  GNUPLOT
  gtk_window_set_focus (GTK_WINDOW (main_window), scale);

  /* This sets the adjustment and makes it emit the "changed" signal to 
    reconfigure all the widgets that are attached to this signal.  */
  //gtk_adjustment_set_value (set, CLAMP (set->value,
  //					  set->lower,
  //					  (set->upper - set->page_size)));
  //g_signal_emit_by_name(G_OBJECT(set), "changed");
}
//------------------------------------------------------------------------------
static void 
control_quit (void)
{

  plotbig_step_end (ps);

  gtk_main_quit ();
  return;
}
//------------------------------------------------------------------------------
/******************************************************************************/
void 
plotbig_create_controls (double tnum, int X, int Y, int W, int H)
{

  GtkWidget *main_vbox;
  GtkWidget *box1;

  GtkWidget *button;
  GtkObject *adj1, *adj2;

  // -----------------------------------------------------
  main_window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  gtk_widget_set_name (main_window, "main_window");

  gtk_window_set_title (GTK_WINDOW (main_window), "Plot Viewer");

  gtk_window_set_default_size (GTK_WINDOW (main_window), W, H);
  gtk_window_move (GTK_WINDOW (main_window), X, Y);

  g_signal_connect (G_OBJECT (main_window), "destroy", G_CALLBACK (gtk_main_quit),
                    NULL);

  main_vbox = gtk_vbox_new (FALSE, 1);

  gtk_container_set_border_width (GTK_CONTAINER (main_vbox), 1);
  gtk_container_add (GTK_CONTAINER (main_window), main_vbox);
  // -----------------------------------------------------

  GtkWidget *menubar = get_menubar_menu (main_window);
  
  gtk_box_pack_start (GTK_BOX (main_vbox), menubar, FALSE, TRUE, 0);

  // -----------------------------------------------------
  // установим объект юстировки:
  adj1 = gtk_adjustment_new (0.0, 0.0, 101.0, 0.1, 1.0, 1.0);

  adj2 = gtk_adjustment_new (
                             0.0,    // initial value
                             0.0,    // minimum value 
                             tnum-1, // maximum value
                             1.0,    // step increment 
                             1.0,    // page increment
                             0.0     // page size
                             );

  g_signal_connect (G_OBJECT (adj2), "value_changed",
                    G_CALLBACK (cb_page_size), (gpointer) adj1);
  // -----------------------------------------------------
  // создадим вертикальный шкаф для установки боксов:

  box1 = gtk_vbox_new (FALSE, 0);
  //gtk_container_add (GTK_CONTAINER (main_window), box1);
  gtk_container_add (GTK_CONTAINER (main_vbox), box1);
  gtk_container_set_border_width (GTK_CONTAINER (box1), 10);

  // -----------------------------------------------------
  // установим линейку прокрутки:

  scale = gtk_hscale_new (GTK_ADJUSTMENT (adj2));
  gtk_widget_set_size_request (GTK_WIDGET (scale), 200, -1);

  gtk_scale_set_digits (GTK_SCALE (scale), 0);
  gtk_box_pack_start (GTK_BOX (box1), scale, TRUE, TRUE, 0);

  // -----------------------------------------------------
  // установим небольшой вертикальный пробел:
  GtkWidget *box_space = gtk_vbox_new (FALSE, 0);
  //gtk_container_set_border_width (GTK_CONTAINER (box_space), 0);

  gtk_box_pack_start (GTK_BOX (box1), box_space, TRUE, TRUE, 5);
  gtk_widget_show (box_space);

  // -----------------------------------------------------
  // установим кнопку выхода:

  button = gtk_button_new_with_label ("Quit");
  g_signal_connect_swapped (G_OBJECT (button), "clicked", 
                            G_CALLBACK (control_quit),
                            NULL);

  gtk_box_pack_start (GTK_BOX (box1), button, TRUE, TRUE, 0);

  GTK_WIDGET_SET_FLAGS (button, GTK_CAN_DEFAULT);
  gtk_widget_grab_default (button);

  // -----------------------------------------------------
  // визуализируем все что создали:

  gtk_widget_show (menubar);
  gtk_widget_show (main_vbox);
  gtk_widget_show (scale);
  gtk_widget_show (button);
  gtk_widget_show (box1);
  gtk_widget_show (main_window);

/*   gint root_x, root_y; */
/*   gtk_window_get_position (GTK_WINDOW (window), &root_x, &root_y);  */
/*   printf ("root_x= %d  root_y= %d  \n", root_x, root_y); */
}
/******************************************************************************/
/*----------------------------------------------------------------------------*/
void
plotbig_print_gtk (YT_PLOT *plot, int X, int Y, int W, int H)
{

  if (W == 0) {
    X = 400; 
    Y = 100;  

    W = 620; 
    H = 500;
  }

  ps = plotbig_step_beg (plot, X, Y, W, H); // глобальная переменная 

  plotbig_step_do (ps, plot->ti);

  //sleep (10);
  //return;

  // -----------------------------------
  gtk_init (0, NULL);
  gtk_rc_parse ("b_gtk.rc");

  plotbig_create_controls (plot->tnum, X, Y + H + 27, 400, 100);

  gtk_main ();

  return;
}
/*----------------------------------------------------------------------------*/
/******************************************************************************/

/******************************************************************************/
// 
// 
// 
/*----------------------------------------------------------------------------*/
YT_PLOT *
make_plot_test_1 ()
{ 
  YT_PLOT *plot = make_test_sin_cos (10,  
                             100, 0, 2*G_PI);

  // начальная инициация (обнуление) списка фреймов:
  plot_frames_init0 (plot);

  // в 1-м фрейме:
  plot->fr[0][0] = 0/*fi*/;  // "Sinus"
  //plot->fr[0][1] = 1/*fi*/;  // "Cosin"

  // во 2-м фрейме:
  //plot->fr[1][0] = 0/*fi*/;  // "Sinus" 

  return (plot);  
}
/*----------------------------------------------------------------------------*/
void 
tadmor_plotbig_print (char *main_dir) 
{
  YT_PLOT *plot;

  TADMOR tadmor, *tad = &tadmor;

  tadmor_get_arrays (tad, main_dir);

  plot = tadmor_make_plot (tad);

  plotbig_print_gtk (plot, 0,0,0,0);

  return;
}
/*============================================================================*/
int 
main (int argc, char** argv) 
{
  char *name;
  YT_PLOT *plot;

  printf ("\n");

  //-----------------------------------------------------------------
  // eсли вообщe нeт парамeтров
  if (argc == 1) {

    tadmor_plotbig_print (".");
    //tadmor_print_arrays (); 

    //plot = make_plot_test_3 ();
    //plotbig_print (plot, 0,0,0,0);

  //-----------------------------------------------------------------
  } else {
  //-----------------------------------------------------------------

    // а иначe смотрим по пeрвому парамeтру

    name = argv[1];

    if (! strcmp (name, "1")) {

      plot = make_plot_test_1 ();
      plotbig_print_gtk (plot, 0,0,0,0);

    } else 

    //-----------------------------------------------------------------
    if (!strcmp (name, "2")) {
 
      // это мы тут сравнивали вычисленные результаты с эталонными

     // double  xmin, xmax;
      // YT_MINFUNC *minfunc = minfunc_read_save ("LAST.sol", YREAD, NULL);
      // xmin = +0;
      // xmax = -0;
      // YT_PLOT *plot;
      // plot = minfunc_print_prepare (minfunc, xmin, xmax);


      //YT_PLOT *plot2;
      //TADMOR tadmor, *tad = &tadmor;

      //tadmor_get_arrays (tad, "D");

      //plot2 = tadmor_make_plot (tad);

      //plotbig_print_gtk (plot2, 0,0,0,0);
      //plot_print (plot2);


      //plot_save_print_test () ;

    } else 
    //-----------------------------------------------------------------

      //if (!strcmp (name, "0")) {
    if (!strcmp (name, "3")) {

      //tadmor_print_arrays (); 

      plot = make_plot_test_3 ();
      plotbig_print_gtk (plot, 0,0,0,0);

    } //else 
    //-----------------------------------------------------------------

/*     if (!strcmp (name, "anim"))   gnuplot_i_anim ();  */
/*     else */
/*     if (!strcmp (name, "exam"))   gnuplot_i_example ();  */
/*     else */
/*     if (!strcmp (name, "sine"))   gnuplot_i_sinepng ();  */

    //-----------------------------------------------------------------
    else {

      tadmor_plotbig_print (argv[1]);

      //Error ("name = argv[1]");
      //tadmor_plotbig_print (name) ;
    }

  }

  printf ("\n");
  return (0);
}
/*============================================================================*/
// 
// 
// 
/*============================================================================*/

