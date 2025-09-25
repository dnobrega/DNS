PRO dnsvar_twist3d, d, name, snaps, swap, var, units, $
                   var_title=var_title, var_range=var_range, var_log=var_log, $
                   info=info
  IF KEYWORD_SET(info) THEN BEGIN
     message, 'Tw factor (Bergen and Prior 2006)',/info
     RETURN
  ENDIF ELSE BEGIN
     IF n_params() LT 6 THEN BEGIN
        message,'dnsvar_twist3d, d, name, snaps, swap, var, units, ' $
                +'var_title=var_title, var_range=var_range, var_log=var_log',/info
        RETURN
     ENDIF     
     d->readpars, snaps
     d->readmesh
     nx  = d->getmx()
     ny  = d->getmy()
     nz  = d->getmz()
     var = fltarr(nx,ny,nz)
     spawn, "pwd", folder
     folder   = folder+"/qfactor/"
     RESTORE, folder+"twist3d_"+STRTRIM(STRING(snaps),2)+".sav"
     var[*,*,0:(size(twist3d))[3]-1] = reverse(reverse(twist3d,3),2)
     var_title='T!dw!n'
     var_range=[-1,1]
     var_log=0
  ENDELSE
END
