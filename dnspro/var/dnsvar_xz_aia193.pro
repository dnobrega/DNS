PRO dnsvar_xz_aia193, d, name, snaps, swap, var, units, $
                    var_title=var_title, var_range=var_range, var_log=var_log, $
                    info=info
  IF KEYWORD_SET(info) THEN BEGIN
     message, 'AIA Fe XII 193 response computed by Fernando Moreno Insertis',/info
     RETURN
  ENDIF ELSE BEGIN
     IF n_params() LT 6 THEN BEGIN
        message,'dnsvar_xz_aia193, d, name, snaps, swap, var, units, ' $
                +'var_title=var_title, var_range=var_range, var_log=var_log',/info
        RETURN
     ENDIF     
     CALL_PROCEDURE, "units_"+units, u
     r     = d->getvar('r',snaps,swap=swap)
     d->readmesh
     nelx=d->getmx()
     nelz=d->getmz()
     var = fltarr(nelx,nelz)     
     openr,unit,"SYNTH/A193/XZ_A193_"+string(snaps, format='(I04)')+".dat",/get_lun
     readu,unit, var
     close,unit
     free_lun,unit
     var=reverse(var,2)
     var_title='AIA 193'
     IF (units EQ "solar") THEN var_title=var_title+" (DN s!u-1!n pix!u-1!n Mm!u-1!n)"
     var_range=[1d-8,5d-7]
     var_log=1
  ENDELSE
END
