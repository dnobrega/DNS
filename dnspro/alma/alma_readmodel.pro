
FUNCTION ALMA_READMODEL, file, parameter

  list=['Pgas','temperature','dens','dx','dy','z']
  ;Pgas         : Gas pressure in CGS
  ;temperature  : Temperature in K
  ;dens         : Total density in CGS
  ;dx           : X axis in cm
  ;dy           : Y axis in cm
  ;z            : Z azis in cm 

  If (NOT FILE_EXIST(file)) THEN BEGIN
     PRINT, "File not found"
     STOP
  ENDIF
  IF total(strmatch(list,parameter)) EQ 0 THEN BEGIN
     PRINT, "Parameter not found. Try with the followin ones:", list
     STOP
  ENDIF

  dd  = H5F_OPEN(file)
  ss  = H5D_OPEN(dd,parameter)
  var = H5D_READ(ss)
  H5F_CLOSE, dd

  RETURN, var

END
