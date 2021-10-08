PRO dnsvar_lundquist, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Lundquist number: S',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_lundquist, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       qjoule=d->getvar('qjoule',snaps,swap=swap)
       var=d->getvar('iy',snaps,swap=swap)
       var=var*var
       var=(qjoule/var)*u.ul*u.ul/u.ut
       va=d->getvar('va',snaps,swap=swap)*u.ul/u.ut
       job=1./(d->getvar('job',snaps,swap=swap)/u.ul)
       var=job*va/var
       var_title="Lundquist"
       var_range=[1d-5, 1d5]
       var_log=1
    ENDELSE
END
