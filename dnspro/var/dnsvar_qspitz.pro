PRO dnsvar_qspitz, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Entropy term due to Spitzer Conductivity: qspitz (erg/cm^3/s)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_tauqspitz, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       UNITS, units
       var=d->getvar('qspitz',snaps,swap=swap)*units.ue/units.ut
       var_title=TEXTOIDL('Q_{Spitz} (erg cm^{-3} s^{-1})')
       var_range=[-0.001, 0.001]
       var_log=0
    ENDELSE
END
