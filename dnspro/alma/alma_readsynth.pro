
FUNCTION ALMA_READSYNTH, file, parameter

 list=['Stokes_I','Tau1','Wavelength']
 ; Stokes_I   : Stokes Intensity in erg/cm^2
              ; We convert it in temperature:
              ; Stokes_I * lambda^2/Kb
 ; Tau1       : Optical depth in cm
              ; We convert it in Mm
 ; Wavelength : Wavelength in Angstrom

 IF (NOT FILE_EXIST(file)) THEN BEGIN
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

 IF (parameter EQ "Stokes_I") THEN BEGIN
    ss = H5D_OPEN(dd,'Wavelength')
    wave = H5D_READ(ss)*1e-8 ;angstrom -> cm
    Kb   = 1.381e-16 ; erg/K
    FOR ii=0,(size(var))[1]-1 DO BEGIN
        var(ii,*,*)=var(ii,*,*)*wave(ii)^2./Kb
    ENDFOR
 ENDIF

 IF (parameter EQ "Tau1") THEN var=var*1e-8

 H5F_CLOSE, dd

 RETURN, var

END
