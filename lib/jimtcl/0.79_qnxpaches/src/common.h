//------------------------------------------------------------------------------ 

#ifndef _COMMON_H
#define _COMMON_H
 
#ifdef __cplusplus
extern "C" {
#endif

//------------------------------------------------------------------------------

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <errno.h>
#include <unistd.h>

#include <pwd.h>
#include <dirent.h>

//------------------------------------------------------------------------------
  // Gen: 
//------------------------------------------------------------------------------
                                                                             
  //FILE*  
  //jim_open_file_from_folder (char *folder, char *fileName, const char *mode);

int    jim_get_file_size (FILE* fp);
  //int    jim_get_fsize (char *folder, char *fname);

#define FALSE  0
#define TRUE   1

//------------------------------------------------------------------------------
#if 0
//------------------------------------------------------------------------------

extern char *folder_remote;

//------------------------------------------------------------------------------

void syserr (const char* msg);

char* init_main_home_folder (const char *folder);

char*
  get_full_path (char *folder);

int
  run_cmd_to_buffer (char *cmd, char *msgBuffer, int sizeof_msgBuffer); 

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

  void  dir_to_buffer (DIR *dir, char *msgBuffer); 
  void  run_rls_to_buffer (char *folder, char *msgBuffer);
  void
  test_read_dir (); 
  void
  test_read_dir_folder (char *folder); 

  void run_dir_to_buffer (DIR *dir, char *msgBuffer);
  void 
  dir_to_buffer (DIR *dir, char *msgBuffer); 

//------------------------------------------------------------------------------
#endif
//------------------------------------------------------------------------------
                                                                              
#ifdef __cplusplus
}
#endif

#endif /* _COMMON_H */

//------------------------------------------------------------------------------
