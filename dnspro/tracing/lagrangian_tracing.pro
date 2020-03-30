PRO lagrangian_tracing_2d, seeds, snap0, snapf, $
                           step=step, filename=filename, folder=folder


   ;--------------------------------------------------------------------------------- 
   ; Input parameters
   ;--------------------------------------------------------------------------------- 
    IF (NOT (KEYWORD_SET(step)))     THEN step=2
    IF (NOT (KEYWORD_SET(filename))) THEN filename='tracers'
    IF (KEYWORD_SET(folder))         THEN filename=folder+'tracers'
    IF snap0 GT snapf THEN BEGIN
       step=-step
    ENDIF
    PRINT, "-----------------------------------------------------------------------"
    PRINT, "For a RK4 integration, we need snapshtos at t, t+1 and t+2."
    PRINT, "We integrate then from ", STRTRIM(snap0,2), " to ", STRTRIM(snapf-step,2)
    PRINT, "with a step of ", STRTRIM(step,2)
    PRINT, "-----------------------------------------------------------------------"

   ;--------------------------------------------------------------------------------- 
   ; Loading Bifrost parameters
   ;--------------------------------------------------------------------------------- 
    br_select_idlparam,idlparam
    d=obj_new('br_data',idlparam)
    br_getsnapind,idlparam,snapshots
    swap=0

    d->readpars, min(snapshots)
    d->readmesh
    xx=d->getx()
    zz=d->getz()

    maxx=MAX(xx,MIN=minx)
    maxz=MAX(zz,MIN=minz)
    nelx=N_ELEMENTS(xx)
    nelz=N_ELEMENTS(zz)
    dz=(maxz-minz)/(nelz-1)
    dz1d=d->getdz1d()

    RESTORE, seeds, /verbose

   ;--------------------------------------------------------------------------------- 
   ; Main loop
   ;--------------------------------------------------------------------------------- 
    FOR snaps=snap0,snapf-step,step DO BEGIN

        save, xp, zp, filename=filename+STRTRIM(snaps,2)+'.sav'
        print, "Integrating snapshot: ", snaps
        spawn, "free -m"
        d->readpars, snaps
        hh=(d->getdtsnap())*step

        ux=reform(d->getvar("ux",snaps,swap=swap))
        uz=reform(d->getvar("uz",snaps,swap=swap))

        ux1=reform(d->getvar("ux",snaps+1,swap=swap))
        uz1=reform(d->getvar("uz",snaps+1,swap=swap))

        ux2=reform(d->getvar("ux",snaps+2,swap=swap))
        uz2=reform(d->getvar("uz",snaps+2,swap=swap))

        IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
           zz=minz+dz*FINDGEN(nelz)
           FOR i=0,nelx-1 DO BEGIN
              ux(i,*)  = INTERPOL( ux(i,*), z, zz )
              uz(i,*)  = INTERPOL( uz(i,*), z, zz )
              ux1(i,*) = INTERPOL( ux(i,*), z, zz )
              uz1(i,*) = INTERPOL( uz(i,*), z, zz )
              ux2(i,*) = INTERPOL( ux(i,*), z, zz )
              uz2(i,*) = INTERPOL( uz(i,*), z, zz )
           ENDFOR
        ENDIF
        
        RK4, xx, zz, $
             xp, zp, hh, $
             ux, uz, ux1, uz1, ux2, uz2


    ENDFOR

END
