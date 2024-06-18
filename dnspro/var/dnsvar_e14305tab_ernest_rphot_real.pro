PRO dnsvar_e14305tab_ernest_rphot_real, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Emissivity of Si X 14305',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_e14305, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       nel   = d->getvar('nel',snaps,swap=swap)
       si    = 1.0*size(nel)
       tg    = d->getvar('tg',snaps,swap=swap)
       tg    = reform(tg,si(1)*si(2)*si(3))
       nel   = reform(nel,si(1)*si(2)*si(3))
       var   = fltarr(si(1),si(2),si(3))
       nh    = 0.85*nel
       z     = -d->getz()
       myrphot = var
       FOR kk=0,n_elements(z)-1 DO myrphot[*,*,kk] = 1.0 + z[kk]/695.7
       myrphot = reform(myrphot,si(1)*si(2)*si(3))
       
       myabund = 7.86
       folder  = GETENV('DNS')+"/dnspro/var/goft_tables/"
       RESTORE, folder+"goft_table_si_10_14304.72_rphot_6483.07.sav"
       drphot  = rphot[1]-rphot[0]
       dlogt   = temperature[1]-temperature[0]
       dlogr   = density[1]-density[0]

       indr    = (alog10(nel)-density[0])/dlogr
       indt    = (alog10(tg)-temperature[0])/dlogt
       indz    = (myrphot-rphot[0])/drphot

       var = 10^(myabund-12.0)*nel*nh*interpolate(table,indr,indt,indz,missing=0)
       var = reform(var,si(1),si(2),si(3))
       var=var/((3600.0*180.0/!PI)^2.0) ; from sr-1 to arcsec-2
       var_title='!4e!3 Si X 14305 (phot cm!u-3!n s!u-1!n arcsec!u-2!n)'
       var_range=[1d-8,5d-7]
       var_log=1
    ENDELSE
END
