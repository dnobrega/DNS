PRO lagrangian_tracing_2d, seeds, snap0, snapf, $
                           step=step, filename=filename, folder=folder,$
                           amb=amb


   ;--------------------------------------------------------------------------------- 
   ; Input parameters
   ;--------------------------------------------------------------------------------- 
    IF (NOT (KEYWORD_SET(step)))     THEN step=2
    IF (NOT (KEYWORD_SET(filename))) THEN filename='tracers'
    IF (KEYWORD_SET(folder))         THEN BEGIN
       filename=folder+filename
       seeds=folder+seeds
    ENDIF
    IF (KEYWORD_SET(amb))            THEN filename=filename+'_amb'
    IF snap0 GT snapf THEN BEGIN
       step=-step
    ENDIF
    PRINT, "-----------------------------------------------------------------------"
    PRINT, "For a RK4 integration, we need snapshots at t, t+1 and t+2."
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
    zz=d->getz() & z=zz

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

        save, xp, zp, filename=filename+'_'+STRTRIM(snaps,2)+'.sav'
        print, "Integrating snapshot: ", snaps
        spawn, "free -m"
        d->readpars, snaps
        hh=(d->getdtsnap())*step

        ux=reform(d->getvar("ux",snaps,swap=swap))
        uz=reform(d->getvar("uz",snaps,swap=swap))

        ux1=reform(d->getvar("ux",snaps+step/2,swap=swap))
        uz1=reform(d->getvar("uz",snaps+step/2,swap=swap))

        ux2=reform(d->getvar("ux",snaps+step,swap=swap))
        uz2=reform(d->getvar("uz",snaps+step,swap=swap))

        IF (KEYWORD_SET(amb)) THEN BEGIN
            ux=reform(d->getvar("uamb_x",snaps,swap=swap)) + ux
            uz=reform(d->getvar("uamb_z",snaps,swap=swap)) + uz
            ux1=reform(d->getvar("uamb_x",snaps+step/2,swap=swap)) + ux1
            uz1=reform(d->getvar("uamb_z",snaps+step/2,swap=swap)) + uz1
            ux2=reform(d->getvar("uamb_x",snaps+step,swap=swap)) + ux2
            uz2=reform(d->getvar("uamb_z",snaps+step,swap=swap)) + uz2
        ENDIF 

        IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
           zz=minz+dz*FINDGEN(nelz)
           FOR i=0,nelx-1 DO BEGIN
              ux(i,*)  = INTERPOL( ux(i,*), z, zz )
              uz(i,*)  = INTERPOL( uz(i,*), z, zz )
              ux1(i,*) = INTERPOL( ux1(i,*), z, zz )
              uz1(i,*) = INTERPOL( uz1(i,*), z, zz )
              ux2(i,*) = INTERPOL( ux2(i,*), z, zz )
              uz2(i,*) = INTERPOL( uz2(i,*), z, zz )
           ENDFOR
        ENDIF
        
        RK4, xx, zz, $
             xp, zp, hh, $
             ux, uz, ux1, uz1, ux2, uz2

    ENDFOR

END
