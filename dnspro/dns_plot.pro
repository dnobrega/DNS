
PRO DNS_PLOT,name, snap0=snap0,snapf=snapf,snapt=snapt, step=step,$
                   ;Plot options
                   nwin=nwin, $
                   xsize=xsize, ysize=ysize, setplot=setplot,$
                   pbackground=pbackground, pcolor=pcolor,$
                   pcharthick=pcharthick, pcharsize=pcharsize, $
                   pthick=pthick, pticklen=pticklen, pmulti=pmulti,$
                   xthick=xthick, ythick=ythick, $
                   pposition=pposition, fmipos=fmipos, fmititle=fmititle, $
                   load=load, reverse=reverse, $
                   ; Saving options
                   namef=namef,$                   
                   folder=folder,movie=movie,png=png,$
                   ; Variable options
                   myrange=myrange,mylog=mylog,$
                   xmin=xmin, xmax=xmax, $
                   ymin=ymin, ymax=ymax, $
                   zmin=zmin, zmax=zmax, $
                   ix0=ix0,iy0=iy0,iz0=iz0, $
                   ixstep=ixstep, iystep=iystep, izstep=izstep,$
                   ixf=ixf,iyf=iyf,izf=izf,$
                   ; Oplot options
                   blines=blines, bcolor=bcolor,bh=bh, $
                   bxmin=bxmin, bxmax=bxmax, bzmin=bzmin, bzmax=bzmax,$
                   bseeds=bseeds, biter=biter, bu=bu,$
                   velovect=velovect, vcolor=vcolor,$
                   dim=dim, dtp=dtp, donde=donde, nghost=nghost,$
                   shiftx=shiftx, $
                   uvector=uvector,ucolor=ucolor,uh=uh, uthick=uthick, $
                   ulength=ulength, uu=uu, $
                   uxmin=uxmin, uxmax=uxmax, uzmin=uzmin, uzmax=uzmax,$
                   useeds=useeds,$
                   lagrange=lagrange, lcolor=lcolor,lh=lh, lsymsize=lsymsize, $
                   lxmin=lxmin, lxmax=lxmax, lzmin=lzmin, lzmax=lzmax,$
                   lseeds=lseeds, xxl=xxl, zzl=zzl


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                             INPUT PARAMETERS                                   
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;---------------------------------------------------------------------------------
; Basic parameters
;---------------------------------------------------------------------------------
  br_select_idlparam,idlparam
  d=obj_new('br_data',idlparam)
  br_getsnapind,idlparam,snaps
;---------------------------------------------------------------------------------
; Default values
;---------------------------------------------------------------------------------
  IF (NOT (KEYWORD_SET(swap)))         THEN swap=0  
  IF (NOT (KEYWORD_SET(dim)))          THEN dim='xz'
  IF (NOT (KEYWORD_SET(xsize)))        THEN xsize=800
  IF (NOT (KEYWORD_SET(ysize)))        THEN ysize=600                 
  IF (NOT (KEYWORD_SET(setplot)))      THEN setplot='X'
  IF (NOT (KEYWORD_SET(pbackground)))  THEN pbackground=255
  IF (NOT (KEYWORD_SET(pcolor)))       THEN pcolor=255
  IF (NOT (KEYWORD_SET(pcharthick)))   THEN pcharthick=2.0
  IF (NOT (KEYWORD_SET(pcharsize)))    THEN pcharsize=2.0
  IF (NOT (KEYWORD_SET(pthick)))       THEN pthick=2.0
  IF (NOT (KEYWORD_SET(pticklen)))     THEN pticklen=-0.02
  IF (NOT (KEYWORD_SET(pmulti)))       THEN pmulti=0
  IF (NOT (KEYWORD_SET(xthick)))       THEN xthick=2.0
  IF (NOT (KEYWORD_SET(ythick)))       THEN ythick=2.0
  IF (NOT (KEYWORD_SET(pposition)))    THEN pposition=[0.14, 0.14, 0.83, 0.92]
  IF (NOT (KEYWORD_SET(fmipos)))       THEN fmipos=[0.84, 0.14, 0.88, 0.92]  
  IF (NOT (KEYWORD_SET(fmititle)))     THEN fmititle=[0.95,0.82] 
  IF (NOT (KEYWORD_SET(nwin)))         THEN nwin=0
  IF (NOT (KEYWORD_SET(namefile)))     THEN namefile=name
;---------------------------------------------------------------------------------
  SPAWN, 'echo $PROJECTS', projects
  IF (NOT (KEYWORD_SET(folder)))       THEN folder=projects+'/Plots/'+idlparam+'/' 
  print, folder
  file_mkdir,folder
;---------------------------------------------------------------------------------
  IF NOT (KEYWORD_SET(snap0)) THEN snap0=MIN(snaps) 
  IF NOT (KEYWORD_SET(snapf)) THEN snapf=MAX(snaps)
  IF NOT (KEYWORD_SET(step))  THEN step=1 
  IF N_ELEMENTS(snapt) NE 0 THEN BEGIN
     snaps=snapt & snap0=snaps & snapf=snaps
  ENDIF
  n_snaps=N_ELEMENTS(snaps)
;---------------------------------------------------------------------------------
  IF (setplot EQ 'X') THEN BEGIN
     SET_PLOT, 'X'
     DEVICE, DECOMPOSED=0, RETAIN=2
     WINDOW, nwin, XSIZE=xsize,YSIZE=ysize
  ENDIF ELSE BEGIN
     SET_PLOT,'Z'
     DEVICE, SET_RESOLUTION=[xsize,ysize],SET_PIXEL_DEPTH=24,DECOMPOSED=0
  ENDELSE
;---------------------------------------------------------------------------------     
  LOADCT,0,/SILENT
  !P.Background=pbackground
  !P.color=pcolor
  !P.charthick=pcharthick
  !P.charsize=pcharsize
  !P.thick=pthick
  !P.ticklen=pticklen
  !P.MULTI=pmulti
  !x.thick=xthick
  !y.thick=ythick
  !P.position=pposition      
;---------------------------------------------------------------------------------
  IF N_ELEMENTS(load) EQ 0 THEN BEGIN
     MYCOLOR 
  ENDIF ELSE BEGIN
     IF load LT 0 THEN BEGIN
        RESTORE, "/Users/dnobrega/Bifrost/IDL/data/ancillary/bluewhitered.sav"
        tvlct, r,g,b
     ENDIF ELSE LOADCT,load,/SILENT
  ENDELSE 
  tvlct, rgb, /get
  IF (KEYWORD_SET(REVERSE)) THEN BEGIN
     IF reverse EQ 1 THEN BEGIN 
        rgb=reverse(rgb,1)
        rgb(0,*)=255
        rgb(255,*)=0
        !P.Background=0
        !P.color=255
     ENDIF
  ENDIF ELSE BEGIN
     rgb(0,*)=0
     rgb(255,*)=255
     !P.Background=255
     !P.color=0
  ENDELSE
  tvlct, rgb
;---------------------------------------------------------------------------------
  IF (KEYWORD_SET(movie)) THEN BEGIN
     video=IDLffVideoWrite(folder+idlparam+'_'+namefile+'_movie.mp4')
     stream=video.AddVideoStream(xsize,ysize,10,BIT_RATE=24E5)
  ENDIF
;---------------------------------------------------------------------------------  

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                                 MAIN
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

;---------------------------------------------------------------------------------
; 1D CASE
;---------------------------------------------------------------------------------
  IF (FIX(STRLEN(dim)) EQ 1) THEN BEGIN
     FOR k=snap0,snapf,step DO BEGIN
         pfm5_var,d,k,var,name, swap,$
                  dim=dim,donde=donde,title1d=title1d,ytitle1d=ytitle1d,$
                  title2d=title,btitle=btitle,$
                  log=log,yrange=yrange,$
                  myrange=myrange,mylog=mylog,$
                  varunits=varunits,$
                  shiftx=shiftx
         pfm5_1dplot,d,snaps,var,name,$
                     xmin=xmin, xmax=xmax, zmin=zmin, zmax=zmax, $
                     title1d=title1d,ytitle1d=ytitle1d,$
                     yrange=yrange,log=log,$
                     dim=dim,donde=donde
        IF (KEYWORD_SET(png))   THEN $
           WRITE_PNG,folder+idlparam+'_'+name+'_'+STRTRIM(k,2)+'.png', TVRD(TRUE=1)
        IF (KEYWORD_SET(movie)) THEN $
           makingmp4=video.Put(stream,TVRD(TRUE=1))
     ENDFOR
  ENDIF
;---------------------------------------------------------------------------------
; 2D CASE
;---------------------------------------------------------------------------------
  IF (STRLEN(dim) EQ 2) THEN BEGIN
      FOR k=snap0,snapf,step DO BEGIN
            pfm5_var,d,k,var,name,swap,$
                      title1d=title1d,ytitle1d=ytitle1d,$
                      title2d=title,btitle=btitle,$
                      log=log,yrange=yrange,$
                      myrange=myrange,mylog=mylog,$
                      varunits=varunits,$
                      shiftx=shiftx,$
                      ix0=ix0,iy0=iy0,iz0=iz0, $
                      ixstep=ixstep, iystep=iystep, izstep=izstep,$
                      ixf=ixf,iyf=iyf,izf=izf,$
                      im0=im0, imf=imf, imstep=imstep,$
                      x3d=x3d,y3d=y3d,z3d=z3d

            FOR m=im0,imf,imstep DO BEGIN
               IF (x3d EQ 1) THEN var_plot = reform(var(m,*,*))
               IF (y3d EQ 1) THEN var_plot = reform(var(*,m,*))
               IF (z3d EQ 1) THEN var_plot = reform(var(*,*,m))
               pfm5_2dplot,d,k,var_plot,name,swap,$
                           xmin=xmin, xmax=xmax, zmin=zmin, zmax=zmax, $
                           blines=blines, bcolor=bcolor,bh=bh, $
                           bxmin=bxmin, bxmax=bxmax, bzmin=bzmin, bzmax=bzmax,$
                           bseeds=bseeds, biter=biter, bu=bu,$
                           velovect=velovect, vcolor=vcolor,$
                           title2d=title,btitle=btitle,$
                           brange=yrange,log=log,nghost=nghost,$
                           uvector=uvector,ucolor=ucolor,uh=uh, uthick=uthick, $
                           ulength=ulength, uu=uu, $
                           uxmin=uxmin, uxmax=uxmax, uzmin=uzmin, uzmax=uzmax,$
                           useeds=useeds, $
                           lagrange=lagrange, lcolor=lcolor,lh=lh, lsymsize=lsymsize, $
                           lxmin=lxmin, lxmax=lxmax, lzmin=lzmin, lzmax=lzmax,$
                           lseeds=lseeds, xxl=xxl, zzl=zzl, $
                           fmipos=fmipos, fmititle=fmititle
               IF (KEYWORD_SET(png)) THEN $
                  WRITE_PNG,folder+idlparam+'_'+namefile+'_'+STRTRIM(k,2)+'_'+dim+'_'+coord+STRTRIM(m,2)+'.png', TVRD(TRUE=1)
               IF (KEYWORD_SET(movie)) THEN $
                  makingmp4=video.Put(stream,TVRD(TRUE=1))
            ENDFOR
         ENDFOR
   ENDIF
;---------------------------------------------------------------------------------
; Evolution with time of the average
;---------------------------------------------------------------------------------
   IF (KEYWORD_SET(dtp)) THEN BEGIN
      tarray=0. & vtime=0. & tplot=0
      FOR k=snap0,snapf,step DO BEGIN
            
          pfm5_var,d,k,var,name, swap,$
                dim=dim,donde=donde,title1d=title1d,ytitle1d=ytitle1d,$
                title2d=title,btitle=btitle,$
                log=log,yrange=yrange,$
                myrange=myrange,mylog=mylog,$
                varunits=varunits,$
                shiftx=shiftx

          pfm5_1dtimeplot,d,snaps,var,name,temp,tplot,timev,$
                   xmin=xmin, xmax=xmax, zmin=zmin, zmax=zmax, $
                   title1d=title1d,ytitle1d=ytitle1d,$
                   yrange=yrange,log=log,$
                   dim=dtp,donde=donde
          tarray=[tarray, temp]
          vtime=[vtime, timev]
          IF (k EQ snapf) THEN BEGIN
             tplot=1
             temp=tarray(1:*)
             timev=vtime(1:*)
             pfm5_1dtimeplot,d,snaps,var,name,temp,tplot,timev,$
                   xmin=xmin, xmax=xmax, zmin=zmin, zmax=zmax, $
                   title1d=title1d,ytitle1d=ytitle1d,$
                   yrange=yrange,log=log,$
                   dim=dtp,donde=donde
          ENDIF

       ENDFOR

       IF (KEYWORD_SET(png)) THEN $
           WRITE_PNG,folder+idlparam+'_'+name+'_'+STRTRIM(k,2)+'.png', TVRD(TRUE=1)
       IF (KEYWORD_SET(movie)) THEN $
           makingmp4=video.Put(stream,TVRD(TRUE=1))

   ENDIF 

;---------------------------------------------------------------------------------

IF (KEYWORD_SET(movie)) THEN video.cleanup 

;---------------------------------------------------------------------------------
;                                     END                                            
;---------------------------------------------------------------------------------

END
