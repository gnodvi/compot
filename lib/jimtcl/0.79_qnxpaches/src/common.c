//------------------------------------------------------------------------------


#include "common.h"

//------------------------------------------------------------------------------
// Gen: 
//------------------------------------------------------------------------------
int 
jim_get_file_size (FILE* fp)
{

  int file_size = 0;

  if (fseek (fp, 0, SEEK_END) != 0)
    printf ("Error determining file size\n");
  
  file_size = ftell (fp);
  rewind (fp);
  
  return (file_size);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
#if 0
//------------------------------------------------------------------------------

char *folder_remote = "./f-server" ;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
FILE*  
jim_open_file_from_folder (char *folder, char *fileName, const char *mode)
{

  //char *mode = "wb";

  char path[256];

  strcpy (path, folder/* _local */);
  strcat (path, "/"); //
  strcat (path, fileName);

  //printf ("path: %s \n", path);

  FILE* fp;

  fp = fopen (path, /* "wb" */mode); //overwrite if existing

  return (fp);
}
//------------------------------------------------------------------------------
int 
jim_get_fsize (char *folder, char *fname)
{

  FILE* fp = jim_open_file_from_folder (folder, fname, "rb");

  int fsize = jim_get_file_size (fp);

  fclose (fp);

  return (fsize);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
char *
get_current_dir_name__ (void)
{

  long size;
  char *buf;
  char *ptr;
    
  size = pathconf (".", _PC_PATH_MAX); //
  
  if ((buf = (char *) malloc ((size_t) size)) == NULL)
    return NULL;

  ptr = getcwd (buf, (size_t)size);

  return (ptr);
}
//------------------------------------------------------------------------------
char*
init_main_home_folder (const char *folder)
{

  //static char main_dir[512];

  char *main_dir = malloc (512);

  const char *homedir;
  
  if ((homedir = getenv ("HOME")) == NULL) {
    homedir = getpwuid (getuid())->pw_dir;
  }

  printf ("home_dir = %s \n", homedir);

  strcpy (main_dir, homedir);
  strcat (main_dir, "/"); 
  strcat (main_dir, folder); 

  printf ("main_dir = %s \n", main_dir);


  chdir (main_dir);

  char *ptr = get_current_dir_name__ ();

  printf ("main_home_folder  = %s \n", ptr);


  return (main_dir);
}
//------------------------------------------------------------------------------
void 
dir_to_buffer (DIR *dir, char *msgBuffer) 
{

  char line [80];
  static struct dirent *directory;

  printf  ("\n");

  while ((directory = readdir (dir)) != NULL)//while in dir.
  {

    if (strcmp (directory->d_name,  ".") == 0 || 
        strcmp (directory->d_name, "..") == 0)
    {
      // printf("\nCAUGHT !!"); // особые папки, зачем это печатать?
    }
    else
    {
      int fsize = jim_get_fsize (folder_remote, directory->d_name);
        
      sprintf (line, ".... %18s   %d", directory->d_name, fsize);        
      printf  ("%s \n", line);
      
      if (msgBuffer)
        sprintf (msgBuffer + strlen (msgBuffer), "\n%s", line);
    }
    
  }

  if (msgBuffer)
    sprintf (msgBuffer + strlen (msgBuffer), "\n");

  printf  ("\n");

}
//------------------------------------------------------------------------------
void run_dir_to_buffer (DIR *dir, char *msgBuffer) 
{

  dir_to_buffer (dir, msgBuffer); 
  
  //rewind!
  rewinddir (dir);
  
}
//------------------------------------------------------------------------------

void syserr (const char* msg) { perror(msg); exit(-1); }

//------------------------------------------------------------------------------
void 
run_rls_to_buffer (char *folder, char *msgBuffer) 
{

  printf ("\n");
  printf ("folder = %s \n", folder);

  DIR *dir = opendir (folder); 

  if (dir == NULL) {
    syserr ("rls_server_proc ERROR");
  }

  printf ("Files at server: \n");

  if (dir)//if directory opens successfully
  {
            
    run_dir_to_buffer (dir, msgBuffer);

    closedir (dir);

  }
  else //could not open directory
  {
    //sprintf (msgBuffer, "server could not open directory"); 

    exit (0);
  }

}
//------------------------------------------------------------------------------
void
test_read_dir_folder (char *folder) 
{

  static char testbuffer[2560];
  memset  (testbuffer, 0, 2560);

  run_rls_to_buffer (folder, NULL ); 

  printf ("\n");

}
//------------------------------------------------------------------------------
void
test_read_dir () 
{

  folder_remote = init_main_home_folder ("MAIN/FOLDER"); 

  test_read_dir_folder (folder_remote);

}
//------------------------------------------------------------------------------
#endif
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
