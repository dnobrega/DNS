PRO dnsvar_ambflux, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Diffusive flux: Phi_{amb}',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_ambflux, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       eta_amb=1.0
       modb=d->getvar("modb",snaps,swap=swap)
       by=d->getvar("by",snaps,swap=swap)
       maxb=max(modb,ind)
       ind=array_indices(modb, ind)
       x=d->getx()
       z=d->getz()
       x0=x(ind(0))
       z0=z(ind(2))
       nelx=n_elements(x)
       nelz=n_elements(z)
       rr=fltarr(nelx,nelz)
       sina=fltarr(nelx,nelz)
       cosa=fltarr(nelx,nelz)
       FOR ii=0,nelx-1 DO BEGIN
          FOR jj=0,nelz-1 DO BEGIN
             rr(ii,jj)=SQRT( (x(ii)-x0)^2.0 + (z(jj)-z0)^2.0)
             sina(ii,jj)=(z(jj)-z0)/rr(ii,jj)
             cosa(ii,jj)=(x(ii)-x0)/rr(ii,jj)
          ENDFOR
       ENDFOR
       sina(ind(0),ind(2))=0.0
       cosa(ind(0),ind(2))=0.0
;       var=-(eta_amb*modb^2.0)*((xup(ddxdn(by)))*cosa + (zup(ddzdn(by)))*sina )
       var=-(eta_amb/3.0)*((xup(ddxdn(by^3.0)))*cosa + (zup(ddzdn(by^3.0)))*sina )
       var_title='Phi!damb!n'
       IF (units EQ "solar") THEN var_title=var_title+" (Mx)"
       var_range=[-5d-2,5d-2]
       var_log=0
    ENDELSE
END
