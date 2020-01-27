FUNCTION ALMA_MODELFILES, folder
 
 ; --------------------------------------------
 ; Function to create a list of strings
 ; with the names of the ALMA model files
 ; --------------------------------------------
 IF (KEYWORD_SET(folder)) THEN CD, folder
 model_format='model.h5'
 SPAWN, 'ls *'+model_format, model_list
 RETURN, model_list

END
