PRO LAGRANGIAN_OPLOT, kk, l_var, l_folder=l_folder, $
                          l_color=l_color, l_load=l_load,$
                          l_psym=l_psym, l_size=l_size


    filename=l_var
    IF (KEYWORD_SET(l_folder))         THEN BEGIN
       filename=l_folder+l_var
    ENDIF
    IF (NOT (KEYWORD_SET(l_size)))     THEN l_size=0.5 
    IF (NOT (KEYWORD_SET(l_psym)))     THEN l_psym=4 
    IF (NOT (KEYWORD_SET(l_color)))    THEN l_color=0
    
    IF (N_ELEMENTS(load) GT 0) THEN BEGIN 
       tvlct,rgb,/get
       load, l_load, /silent
    ENDIF
    
    RESTORE, filename+'_'+STRTRIM(kk,2)+'.sav', /VERBOSE

    OPLOT, xp, -zp, psym=l_psym, symsize=l_size, color=l_color

    IF (N_ELEMENTS(load) GT 0) THEN tvlct, rgb

END
