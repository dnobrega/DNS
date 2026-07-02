PRO dnsvar_lfrlh, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Ration betweeen the horizontal component of the tension and magntic pressure',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_lfrlh, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx  = d->getvar('bx',snaps,swap=swap)
       by  = d->getvar('by',snaps,swap=swap)
       bz  = d->getvar('bz',snaps,swap=swap)
       bxc = xup(bx)
       byc = yup(by)
       bzc = zup(bz)

       pm  = 0.5*(bxc*bxc + byc*byc + bzc*bzc)

       ; Magnetic tension: T = (B . grad) B
       Tx  = bxc*ddxup(bx) + byc*ddyup(bx) + bzc*ddzup(bx)
       Ty  = bxc*ddyup(by) + byc*ddyup(by) + bzc*ddzup(by)
       T_h = sqrt(Tx*Tx + Ty*Ty)

       ; Magnetic-pressure-gradient magnitude
       Gx = xup(ddxdn(pm))
       Gy = yup(ddydn(pm))

       Gm_h = sqrt(Gx*Gx + Gy*Gy)
       
       eps = 1.d-30
       var = (T_h - Gm_h)/(T_h + Gm_h + eps)
       
       var_title="R!dL,h!n"
       var_range=[-1,1]
       var_log=0
    ENDELSE
END
