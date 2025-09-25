PRO dnsvar_q_perp3d, d, name, snaps, swap, var, units, $
                   var_title=var_title, var_range=var_range, var_log=var_log, $
                   info=info
  IF KEYWORD_SET(info) THEN BEGIN
     message, 'Squashing factor Q_perp',/info
     RETURN
  ENDIF ELSE BEGIN
     IF n_params() LT 6 THEN BEGIN
        message,'dnsvar_q_perp3d, d, name, snaps, swap, var, units, ' $
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
     RESTORE, folder+"q_perp3d_"+STRTRIM(STRING(snaps),2)+".sav"
     var[*,*,0:(size(q_perp3d))[3]-1] = reverse(reverse(q_perp3d,3),2)
     var_title='Q!dperp!n'
     var_range=[2,1e4]
     var_log=1
  ENDELSE
END
