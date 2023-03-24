PRO dnsvar_alpoly, d, name, snaps, swap, var, units, $
                    var_title=var_title, var_range=var_range, var_log=var_log, $
                    info=info
  IF KEYWORD_SET(info) THEN BEGIN
     message, 'XRT Al-poly response',/info
     RETURN
  ENDIF ELSE BEGIN
     IF n_params() LT 6 THEN BEGIN
        message,'dnsvar_alpoly, d, name, snaps, swap, var, units, ' $
                +'var_title=var_title, var_range=var_range, var_log=var_log',/info
        RETURN
     ENDIF     
     CALL_PROCEDURE, "units_"+units, u
     wave_resp = make_xrt_wave_resp(contam_time='2023-Mar-01 09:00:00')
     xrt_tresp = make_xrt_temp_resp(wave_resp,/apec_default)
     tresp = alog10((xrt_tresp.temp)[0:25,1])
     xresp = (xrt_tresp.temp_resp)[0:25,1]
     nel   = d->getvar('nel',snaps,swap=swap)
     si    = size(nel)
     tg    = d->getvar('tg',snaps,swap=swap)
     tg(where(tg le tresp[0])) = tresp[0]
     tg    = reform(tg,si(1),si(2),si(3))
     var   = fltarr(si(1),si(2),si(3))
     FOR j=0,si(2)-1 DO BEGIN
        var(*,j,*) = nel(*,j,*)*nel(*,j,*)*interpol(xresp,tresp,alog10(tg(*,j,*)),/NAN)
     ENDFOR
     d->readpars, snaps
     d->readmesh
     z       = d->getz()
     wh      = where(z ge -1.0)
     var(*,*,wh)=1e-32
     var=reform(var)
     var(where(var le 0)) = 1e-32
     var(where(tg le tresp[0])) = 1e-32
     var_title='XRT Al-poly'
     IF (units EQ "solar") THEN var_title=var_title+" (DN cm!u-1!n s!u-1!n pix!u-1!n)"
     var_range=[1d-8,5d-7]
     var_log=1
  ENDELSE
END
