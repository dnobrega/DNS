PRO ALMA_SYNTHFILES, synth_list, folder=folder
 
 ; --------------------------------------------
 ; Function to create a list of strings
 ; with the names of the ALMA synthesis files
 ; --------------------------------------------
 IF (KEYWORD_SET(folder)) THEN CD, folder
 synth_format='int.h5'
 SPAWN, 'ls *'+synth_format, synth_list

END
