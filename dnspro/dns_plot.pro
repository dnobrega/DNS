
PRO DNS_PLOT, name,snap0=snap0,snapf=snapf,snapt=snapt,step=step,$
                   ; General plot options
                   nwin=nwin, multi=multi,$
                   xsize=xsize, ysize=ysize, setplot=setplot,$
                   charthick=charthick, charsize=charsize, $
                   thick=thick, ticklen=ticklen, $
                   xthick=xthick, ythick=ythick, $
                   position=position, $
                   isotropic=isotropic,$
                   load=load, reverse_load=reverse_load, $
                   ; Specific options for 1D plot
                   linestyle=linestyle, $
                   psym=psym, symsize=symsize, $
                   ; Specific options for 2D plots
                   smooth=smooth, $
                   bottom=bottom, top=top, $
                   find_min=find_min, find_max=find_max,$
                   save_min=save_min, save_max=save_max, $
		   min_filename=min_filename, max_filename=max_filename, $
                   ; Bar options for 2D plots
                   bar_pos=bar_pos, $
                   bar_titlepos=bar_titlepos,$
                   bar_titchart=bar_titchart,bar_titchars=bar_titchars,$
                   bar_orient=bar_orient, bar_charthick=bar_charthick, $
                   bar_thick=bar_thick, bar_charsize=bar_charsize,$
                   ; Saving options
                   dns_confi=dns_confi, save_dns_confi=save_dns_confi,$
                   namefile=namefile,$                   
                   folder=folder,movie=movie,png=png,$
                   save_dnsvar=save_dnsvar, save_dnsfolder=save_dnsfolder,$
                   ; Variable options
                   dim=dim,$
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
                   xshift=xshift, yshift=yshift,zshift=zshift,ishift=ishift, jshift=jshift,$
                   ; Oplot options
                   o_x=o_x, o_y=o_y, $
                   o_linestyle=o_linestyle, o_thick=o_thick, $
                   o_load=o_load, o_color=o_color, $
                   ; Contour options
                   c_var=c_var,$
                   c_levels=c_levels,c_load=c_load,c_color=c_color,$
                   c_thick=c_thick,c_linestyle=c_linestyle,c_labels=c_labels,$
                   c_charsize=c_charsize,c_charthick=c_charthick,$
                   c_save=c_save,c_filename=c_filename

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
  IF (NOT (KEYWORD_SET(dns_confi)))  THEN dns_confi="dns_confi"
  IF file_test(dns_confi+".sav")     THEN RESTORE, dns_confi+".sav" ELSE BEGIN

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

     ; Specific options for 1D plot 
     dlinestyle=0
     dpsym=0
     dsymsize=1

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

  ENDELSE

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

  ; Specific options for 1D plots  
  IF (N_ELEMENTS(linestyle) EQ 0)      THEN linestyle=dlinestyle
  IF (N_ELEMENTS(psym) EQ 0)           THEN psym=dpsym
  IF (N_ELEMENTS(symsize) EQ 0)        THEN symsize=dsymsize

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

  ; Save default values in DNS_CONFI file
  IF KEYWORD_SET(save_dns_confi)       THEN BEGIN

     ; General plot options
     dxsize=xsize
     dysize=ysize
     dcharthick=charthick
     dcharsize=charsize
     dthick=thick
     dticklen=ticklen
     dxthick=xthick
     dythick=ythick
     dposition=position
     dload=load
     dreverse_load=reverse_load
     disotropic=cb_isotropic

     ; Specific options for 1D plots  
     dlinestyle=linestyle
     dpsym=psym
     dsymsize=symsize

     ; Specific options for 2D plots  
     dbottom=cb_bottom
     dtop=cb_top
     dsmooth=cb_smooth

     ; Bar options for 2D plots 
     dbar_pos=cb_bar_pos
     dbar_titlepos=cb_bar_titlepos
     dbar_orient=cb_bar_orient
     dbar_charthick=cb_bar_charthick
     dbar_thick=cb_bar_thick
     dbar_charsize=cb_bar_charsize
     dbar_titchart=cb_bar_titchart
     dbar_titchars=cb_bar_titchars

     ;  Variable options  
     dswap=swap
     dunits=units

     ; Saving default values
     save, dnwin, $
           ; Gen opt
           dxsize, dysize, $
           dcharthick, dcharsize, $
           dthick, dticklen, $
           dxthick, dythick, $
           dposition, $
           dload, dreverse_load, $
           disotropic, $
           ; 1D
           dlinestyle, $
           dpsym, dsymsize, $
           ; 2D
           dbottom, dtop, $
           dsmooth, $
           ; Bar 2d
           dbar_pos,dbar_titlepos, $
           dbar_orient, dbar_charthick, $
           dbar_thick, dbar_charsize,$
           dbar_titchart,$
           dbar_titchars,$
           ; Var opt  
           dswap, dunits, $ 
           FILENAME=dns_confi+".sav"
  ENDIF


  IF (NOT (KEYWORD_SET(namefile)))     THEN namefile=name

;---------------------------------------------------------------------------------
  SPAWN, 'echo $DNS_PROJECTS', projects
  IF (NOT (KEYWORD_SET(folder)))       THEN folder=projects+'/'+idlparam+'/' 
  file_mkdir,folder
;---------------------------------------------------------------------------------
  IF NOT (KEYWORD_SET(snap0)) THEN snap0=MIN(snaps) 
  IF NOT (KEYWORD_SET(snapf)) THEN snapf=MAX(snaps)
  IF NOT (KEYWORD_SET(step))  THEN step=1 
  IF N_ELEMENTS(snapt) NE 0 THEN BEGIN
     snap0=snapt & snapf=snapt
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

;---------------------------------------------------------------------------------
  IF (KEYWORD_SET(movie)) THEN BEGIN
     video=IDLffVideoWrite(folder+idlparam+'_'+namefile+'.mp4')
     stream=video.AddVideoStream(xsize,ysize,10,BIT_RATE=24E5)
  ENDIF
;---------------------------------------------------------------------------------  

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                                 MAIN
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

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
                dim=dim, $
                xx=xx, yy=yy, zz=zz,$
                xshift=xshift, yshift=yshift, zshift=zshift, $
                xtitle=xtitle, ytitle=ytitle, title=title,$
                bar_log=bar_log, bar_title=bar_title,$
                save_dnsvar=save_dnsvar, save_dnsfolder=save_dnsfolder

     IF STRLEN(dim) EQ 2 THEN BEGIN
     
        FOR m=im0,imf,imstep DO BEGIN
           IF (dim EQ "yz") THEN var_plot = reform(var(m,*,*))
           IF (dim EQ "xz") THEN var_plot = reform(var(*,m,*))
           IF (dim EQ "xy") THEN var_plot = reform(var(*,*,m))
           dns_2dplot, d,k,var_plot,dim, $
                       var_minmax=var_minmax,$
                       showminmax=showminmax, $
                       bifrost_coord=bifrost_coord,$
                       xx=xx, yy=yy, zz=zz,$
                       xtitle=xtitle, ytitle=ytitle, title=title(m),$
                       xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                       ishift=ishift,jshift=jshift,$
                       position=position,$
                       bar_name=bar_title, var_range=var_range, bar_log=bar_log, $
                       find_min=find_min, find_max=find_max, $
                       save_min=save_min, save_max=save_max, $
                       min_filename=min_filename, max_filename=max_filename, $
                       var_name=name


           IF (N_ELEMENTS(o_x) + N_ELEMENTS(o_y) GT 0) THEN BEGIN
              DNS_OPLOT_LINE, o_x=o_x, o_y=o_y, $
                              o_linestyle=o_linestyle, o_thick=o_thick, o_color=o_color, $
                              o_load=o_load
           ENDIF

           
           IF (N_ELEMENTS(c_var) GT 0) THEN BEGIN
              DNS_CONTOUR, d, k, m, 0,$
                           c_var, c_levels,$
                           units=units,$
                           xmin=xmin,xmax=xmax,$
                           ymin=ymin,ymax=ymax,$
                           zmin=zmin,zmax=zmax,$
                           dim=dim, xx=xx,yy=yy,$
                           ishift=ishift, jshift=jshift,$
                           ixt=ixt,iyt=iyt,izt=izt,$
                           c_load=c_load,$
                           c_color=c_color,$
                           c_thick=c_thick, $
                           c_linestyle=c_linestyle, $
                           c_labels=c_labels, $
                           c_charsize=c_charsize, $
                           c_charthick=c_charthick, $
                           c_save=c_save,c_filename=c_filename
           ENDIF

           wait, 0.0001
           IF (KEYWORD_SET(png)) THEN BEGIN
              png_file=folder+idlparam+'_'+namefile+'_'+dim+'_'+STRTRIM(k,2)+'_'+repstr(STRCOMPRESS(title(m))," ", "_")+'.png'
              WRITE_PNG, png_file, TVRD(TRUE=1)
           ENDIF
           IF (KEYWORD_SET(movie)) THEN $
              makingmp4=video.Put(stream,TVRD(TRUE=1))
        
        ENDFOR

     ENDIF        

     IF (STRLEN(dim) EQ 1) THEN BEGIN
        sizevar=size(var)
        FOR im=ix0,ixf,ixstep DO BEGIN
           FOR jm=iy0,iyf,iystep DO BEGIN
              IF (dim EQ "x") THEN BEGIN
                 var_plot = reform(var(*,jm,im))
                 IF (sizevar(2) GT 1) THEN BEGIN
                    IF (sizevar(3) GT 1) $ 
                    THEN title_1d = (title.title1)[im]+(title.title2)[jm] $
                    ELSE title_1d = title[im]
                 ENDIF ELSE title_1d = title[im]
              ENDIF
              IF (dim EQ "y") THEN BEGIN
                 var_plot = reform(var(im,*,jm))        
                 IF (sizevar(3) GT 1) THEN BEGIN
                    IF (sizevar(1) GT 1) $
                    THEN title_1d = (title.title1)[im]+(title.title2)[jm] $
                    ELSE title_1d = title[im]
                 ENDIF ELSE title_1d = title[im]
              ENDIF
              IF (dim EQ "z") THEN BEGIN
                 var_plot = reform(var(im,jm,*))
                 IF (sizevar(1) GT 1) THEN BEGIN
                    IF (sizevar(2) GT 1) $
                    THEN title_1d = (title.title1)[im]+(title.title2)[jm] $
                    ELSE title_1d = title[im]
                 ENDIF ELSE title_1d = title[im]
              ENDIF

              dns_1dplot, d,k,var_plot,dim, $
                          var_minmax=var_minmax, $
                          showminmax=showminmax, $
                          bifrost_coord=bifrost_coord,$
                          bar_log=bar_log, $
                          xx=xx, yy=yy, zz=zz,$
                          xtitle=xtitle, ytitle=ytitle, title=title_1d,$
                          xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                          ishift=ishift,$
                          position=position,$
                          var_range=var_range, $
                          isotropic=isotropic, $
                          linestyle=linestyle, $
                          psym=psym, symsize=symsize

              IF (N_ELEMENTS(o_x) + N_ELEMENTS(o_y) GT 0) THEN BEGIN
                 DNS_OPLOT_LINE, o_x=o_x, o_y=o_y, $
                                 o_linestyle=o_linestyle, o_thick=o_thick, o_color=o_color, $
                                 o_load=o_load
              ENDIF
              
              wait, 0.0001
              IF (KEYWORD_SET(png)) THEN BEGIN
                 png_file=folder+idlparam+'_'+namefile+'_'+dim+'_'+STRTRIM(k,2)+'_'+repstr(STRCOMPRESS(title_1d)," ", "_")+'.png'
                 WRITE_PNG, png_file, TVRD(TRUE=1)
              ENDIF
              IF (KEYWORD_SET(movie)) THEN $
                 makingmp4=video.Put(stream,TVRD(TRUE=1))
           ENDFOR
        ENDFOR
        

     ENDIF


  ENDFOR
;---------------------------------------------------------------------------------
  
  IF (KEYWORD_SET(movie)) THEN video.cleanup 
  
;---------------------------------------------------------------------------------
;                                     END                                            
;---------------------------------------------------------------------------------

END
