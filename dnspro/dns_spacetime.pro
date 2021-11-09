
PRO DNS_SPACETIME, name, coord, dim=dim, snap0=snap0,snapf=snapf,snapt=snapt,step=step,$
                   ; General plot options
                   nwin=nwin, multi=multi,$
                   xsize=xsize, ysize=ysize, setplot=setplot,$
                   charthick=charthick, charsize=charsize, $
                   thick=thick, ticklen=ticklen, $
                   xthick=xthick, ythick=ythick, $
                   position=position, $
                   isotropic=isotropic,$
                   load=load, reverse_load=reverse_load, $
                   ; Specific options for 2D plots
                   smooth=smooth, $
                   bottom=bottom, top=top, $
                   ; Bar options for 2D plots
                   bar_pos=bar_pos, $
                   bar_titlepos=bar_titlepos,$
                   bar_titchart=bar_titchart,bar_titchars=bar_titchars,$
                   bar_orient=bar_orient, bar_charthick=bar_charthick, $
                   bar_thick=bar_thick, bar_charsize=bar_charsize,$
                   ; Saving options
                   namefile=namefile,$                   
                   folder=folder,png=png,$
                   save_dnsvar=save_dnsvar, save_dnsfolder=save_dnsfolder,$
                   ; Variable options
                   swap=swap, units=units,$
                   bifrost_coord=bifrost_coord,$
                   var_range=var_range,var_log=var_log, var_title=var_title,$
                   var_minmax=var_minmax,$
                   showminmax=showminmax, $
                   xmin=xmin, xmax=xmax, $
                   ymin=ymin, ymax=ymax, $
                   zmin=zmin, zmax=zmax, $
                   ixt=ixt,iyt=iyt,izt=izt, $
                   ix0=ix0,iy0=iy0,iz0=iz0, $
                   ixstep=ixstep, iystep=iystep, izstep=izstep,$
                   ixf=ixf,iyf=iyf,izf=izf,$
                   xshift=xshift, yshift=yshift,zshift=zshift,ishift=ishift, jshift=jshift
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                                COMMON
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

COMMON BIFPLT_COMMON,  $
       cb_bar_pos, cb_bar_titlepos, $
       cb_bar_orient, cb_bar_charthick, $
       cb_bar_thick, cb_bar_charsize,$
       cb_bar_titchart,$
       cb_bar_titchars,$
       cb_bottom, cb_top, $
       cb_isotropic, cb_smooth

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
     ; General plot options 
     dnwin=0
     dxsize=600
     dysize=800
     dcharthick=2.0
     dcharsize=2.0
     dthick=2.0
     dticklen=-0.02
     dxthick=2.0
     dythick=2.0
     dposition=[0.20, 0.10, 0.90, 0.78]
     dload=39
     dreverse_load=0
     disotropic=0

     ; Specific options for 2D plots  
     dsmooth=0
     dbottom=0
     dtop=255

     ; Bar options for 2D plots  
     dbar_pos =  fltarr(4)
     dbar_pos(0)=dposition(0)
     dbar_pos(1)=dposition(3)+0.08
     dbar_pos(2)=dposition(2)
     dbar_pos(3)=dbar_pos(1)+0.02
     dbar_titlepos=[0.5*(dposition(0)+dposition(2)),0.95]
     dbar_orient="xtop"
     dbar_charthick=dcharthick-0.5
     dbar_thick=dcharthick
     dbar_charsize=dcharsize
     dbar_titchart=dcharthick-0.5
     dbar_titchars=dcharsize

     ; Variable options
     dswap=0
     dunits="solar"

  ; General plot options 
  IF (NOT (KEYWORD_SET(nwin)))         THEN nwin=dnwin
  IF (NOT (KEYWORD_SET(xsize)))        THEN xsize=dxsize
  IF (NOT (KEYWORD_SET(ysize)))        THEN ysize=dysize              
  IF (NOT (KEYWORD_SET(charthick)))    THEN charthick=dcharthick
  IF (NOT (KEYWORD_SET(charsize)))     THEN charsize=dcharsize
  IF (NOT (KEYWORD_SET(thick)))        THEN thick=dthick
  IF (NOT (KEYWORD_SET(ticklen)))      THEN ticklen=dticklen
  IF (NOT (KEYWORD_SET(xthick)))       THEN xthick=dxthick
  IF (NOT (KEYWORD_SET(ythick)))       THEN ythick=dythick
  IF (NOT (KEYWORD_SET(position)))     THEN position=dposition ELSE BEGIN
     dbar_pos =  fltarr(4)
     dbar_pos(0)=position(0)
     dbar_pos(1)=position(3)+0.08
     dbar_pos(2)=position(2)
     dbar_pos(3)=dbar_pos(1)+0.02
  ENDELSE
  IF (N_ELEMENTS(load) EQ 0)           THEN load=dload
  IF (N_ELEMENTS(reverse_load) EQ 0)   THEN reverse_load=dreverse_load
  IF (N_ELEMENTS(isotropic) EQ 0)      THEN cb_isotropic=disotropic         ELSE cb_isotropic=isotropic

  ; Specific options for 2D plots
  IF (N_ELEMENTS(bottom) EQ 0)         THEN cb_bottom=dbottom               ELSE cb_bottom=bottom
  IF (N_ELEMENTS(top) EQ 0)            THEN cb_top=dtop                     ELSE cb_top=top
  IF (N_ELEMENTS(smooth) EQ 0)         THEN cb_smooth=dsmooth               ELSE cb_smooth=smooth

  ; Bar options for 2D plots 
  IF (NOT (KEYWORD_SET(bar_pos)))      THEN cb_bar_pos=dbar_pos             ELSE cb_bar_pos = bar_pos
  IF (NOT (KEYWORD_SET(bar_titlepos))) THEN cb_bar_titlepos=dbar_titlepos   ELSE cb_bar_titlepos=bar_titlepos
  IF (NOT (KEYWORD_SET(bar_orient)))   THEN cb_bar_orient=dbar_orient       ELSE cb_bar_orient=bar_orient
  IF (NOT (KEYWORD_SET(bar_charthick)))THEN cb_bar_charthick=dbar_charthick ELSE cb_bar_charthick=bar_charthick
  IF (NOT (KEYWORD_SET(bar_thick)))    THEN cb_bar_thick=dbar_thick         ELSE cb_bar_thick=bar_thick 
  IF (NOT (KEYWORD_SET(bar_charsize))) THEN cb_bar_charsize=dbar_charsize   ELSE cb_bar_charsize=bar_charsize
  IF (NOT (KEYWORD_SET(bar_titchart))) THEN cb_bar_titchart=dbar_titchart   ELSE cb_bar_titchart=bar_titchart 
  IF (NOT (KEYWORD_SET(bar_titchars))) THEN cb_bar_titchars=dbar_titchars   ELSE cb_bar_titchars=bar_titchars

  ; Variable options
  IF (NOT (KEYWORD_SET(swap)))         THEN swap=dswap  
  IF (NOT (KEYWORD_SET(units)))        THEN units=dunits
  IF (NOT (KEYWORD_SET(namefile)))     THEN namefile=name

;---------------------------------------------------------------------------------
  SPAWN, 'echo $DNS_PROJECTS', projects
  IF (NOT (KEYWORD_SET(folder)))         THEN folder=projects+'/'+idlparam+'/' 
  IF (NOT FILE_TEST(folder, /DIRECTORY)) THEN file_mkdir,folder
;---------------------------------------------------------------------------------
  IF NOT (KEYWORD_SET(snap0)) THEN snap0=MIN(snaps) 
  IF NOT (KEYWORD_SET(snapf)) THEN snapf=MAX(snaps)
  IF NOT (KEYWORD_SET(step))  THEN step=1 
  IF N_ELEMENTS(snapt) NE 0 THEN BEGIN
     snap0=snapt & snapf=snapt
  ENDIF
  ns = FLOOR((snapf-snap0)/step) + 1
  tv = FLTARR(ns)
;---------------------------------------------------------------------------------
  IF NOT (KEYWORD_SET(dim)) THEN dim="x"
  d->readpars, snap0
  d->readmesh
  x     = d->getx()
  y     = d->gety()
  z     = d->getz()
  nx    = d->getmx()
  ny    = d->getmy()
  nz    = d->getmz()
  IF ny EQ 1 THEN iyt=0 ELSE STOP
  IF dim EQ "x" THEN BEGIN
     wh   = min(where(z ge coord))
     scr1 = FLTARR(nx, ns)
     dx   = x(1)-x(0)
     x0   = x(0)
  ENDIF
  IF dim EQ "y" THEN BEGIN
     wh   = min(where(z ge coord))
     scr1 = FLTARR(ny, ns)
     dx   = y(1)-y(0)
     x0   = y(0)
  ENDIF
  IF dim EQ "z" THEN BEGIN
     wh   = min(where(x ge coord))
     scr1 = FLTARR(nz, ns)
     dx   = z(1)-z(0)
     x0   = z(0)
  ENDIF
;---------------------------------------------------------------------------------
  IF (NOT KEYWORD_SET(setplot)) THEN BEGIN
     SET_PLOT, 'X'
     IF ((!D.WINDOW NE nwin) OR (!D.x_size NE xsize) OR (!D.y_size NE ysize)) THEN BEGIN
        DEVICE, DECOMPOSED=0, RETAIN=2
        WINDOW, nwin, XSIZE=xsize,YSIZE=ysize
        ERASE
     ENDIF
  ENDIF ELSE BEGIN
     IF (setplot EQ 1) THEN BEGIN 
        SET_PLOT,'Z'
        DEVICE, SET_RESOLUTION=[xsize,ysize],SET_PIXEL_DEPTH=24,DECOMPOSED=0
     ENDIF
  ENDELSE
;---------------------------------------------------------------------------------     
  IF (load GT 74) THEN aia_lct, r,g, b, wave=load, /load ELSE load, load, /SILENT
  IF (NOT KEYWORD_SET(multi)) THEN !P.multi=0
  !P.charthick=charthick
  !P.charsize=charsize
  !P.thick=thick
  !P.ticklen=ticklen
  !x.thick=xthick
  !y.thick=ythick
;---------------------------------------------------------------------------------
  tvlct, rgb, /get
  IF reverse_load EQ 1 THEN BEGIN 
     rgb=REVERSE(rgb,1)
     rgb(0,*)=255
     rgb(255,*)=0
  ENDIF ELSE BEGIN
     rgb(0,*)=0
     rgb(255,*)=255
     !P.background=255
     !P.color=0
  ENDELSE
  tvlct, rgb

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                                 MAIN
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  jj = 0
  FOR k=snap0,snapf,step DO BEGIN
        dns_var,d,name,k,swap,var,$
                bifrost_coord=bifrost_coord,$
                var_title=var_title, var_range=var_range, var_log=var_log,$
                units=units,$
                ixt=ixt,iyt=iyt,izt=izt, $                   
                ix0=ix0,iy0=iy0,iz0=iz0, $
                ixstep=ixstep, iystep=iystep, izstep=izstep,$
                ixf=ixf,iyf=iyf,izf=izf,$
                im0=im0, imf=imf, imstep=imstep,$
                dim=dim, tt=tt,$
                xx=xx, yy=yy, zz=zz,$
                xshift=xshift, yshift=yshift, zshift=zshift, $
                xtitle=xtitle, $
                bar_log=bar_log, bar_title=bar_title,$
                save_dnsvar=save_dnsvar, save_dnsfolder=save_dnsfolder

        IF (dim EQ "x") THEN scr1[*,jj] = reform(var[*, iyt, wh])
        IF (dim EQ "y") THEN scr1[*,jj] = reform(var[ixt, *, wh])
        IF (dim EQ "z") THEN scr1[*,jj] = reform(var[wh, iyt, *])
        tv(jj) = tt
        jj = jj + 1
   ENDFOR     
  IF (units EQ "solar") THEN ytitle = "t (min)" ELSE ytitle="t"
  y0 = min(tv)
  dy = tv(1)-tv(0)

  bar_range=var_range
  plot_image, scr1, $
              position=position,$
              origin=[x0,y0], scale=[dx,dy], $
              xtitle=xtitle, ytitle=ytitle, $
              min=bar_range[0],max=bar_range[1], $
              xminor=5, yminor=5, $
              isotropic=isotropic,$
              bottom=bottom, top=top,$
              smooth=smooth
  
  DNS_COLORBAR, bar_range, nlev=nlev,$
                varname=bar_title, $
                log=bar_log,  $
                charthick=cb_bar_charthick,$
                thick=cb_bar_thick, $
                chars=cb_bar_charsize,$
                orient=cb_bar_orient, $
                position=cb_bar_pos,$
                postitle=cb_bar_titlepos,$
                tit_chart=cb_bar_titchart,$
                tit_chars=cb_bar_titchars
  
   IF (KEYWORD_SET(png)) THEN BEGIN
      png_file=folder+idlparam+'_'+namefile+'_spacetime.png'
      WRITE_PNG, png_file, TVRD(TRUE=1)
   ENDIF
        

;---------------------------------------------------------------------------------
  
;---------------------------------------------------------------------------------
;                                     END                                            
;---------------------------------------------------------------------------------

END
