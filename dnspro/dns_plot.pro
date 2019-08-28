
PRO DNS_PLOT, name,snap0=snap0,snapf=snapf,snapt=snapt, step=step,$
              keep_var=keep_var, svar=svar,$
                   ;Plot options
                   nwin=nwin, $
                   xsize=xsize, ysize=ysize, setplot=setplot,$
                   background=background, color=color,$
                   charthick=charthick, charsize=charsize, $
                   thick=thick, ticklen=ticklen, multi=multi,$
                   xthick=xthick, ythick=ythick, $
                   position=position, $
                   bar_pos=bar_pos, bar_titlepos=bar_titlepos, $
                   bar_orient=bar_orient, bar_charthick=bar_charthick, $
                   bar_thick=bar_thick, bar_charsize=bar_charsize,$
                   load=load, reverse_load=reverse_load, $
                   ; Saving options
                   dns_confi=dns_confi, save_dns_confi=save_dns_confi,$
                   namef=namef,$                   
                   folder=folder,movie=movie,png=png,$
                   ; Variable options
                   dim=dim,$
                   var_range=var_range,var_log=var_log,$
                   xmin=xmin, xmax=xmax, $
                   ymin=ymin, ymax=ymax, $
                   zmin=zmin, zmax=zmax, $
                   ixt=ixt,iyt=iyt,izt=izt, $
                   ix0=ix0,iy0=iy0,iz0=iz0, $
                   ixstep=ixstep, iystep=iystep, izstep=izstep,$
                   ixf=ixf,iyf=iyf,izf=izf
                   ; Oplot options

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                             INPUT PARAMETERS                                   
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;---------------------------------------------------------------------------------
; Basic parameters
;---------------------------------------------------------------------------------
  br_select_idlparam,idlparam
  IF (N_ELEMENTS(svar) EQ 0) THEN BEGIN  
     d=obj_new('br_data',idlparam)
  ENDIF
  br_getsnapind,idlparam,snaps
;---------------------------------------------------------------------------------
; Default values
;---------------------------------------------------------------------------------
  IF (NOT (KEYWORD_SET(dns_confi)))    THEN dns_confi="dns_confi"
  IF file_test(dns_confi+".sav") THEN RESTORE, dns_confi+".sav" ELSE BEGIN
     dswap=0
     dxsize=600
     dysize=600
     dbackground=255
     dcolor=255
     dcharthick=2.0
     dcharsize=2.0
     dthick=2.0
     dticklen=-0.02
     dmulti=0
     dxthick=2.0
     dythick=2.0
     dposition=[0.14, 0.12, 0.88, 0.74]
     dbar_pos =  fltarr(4)
     dbar_pos(0)=dposition(0)
     dbar_pos(1)=dposition(3)+0.09
     dbar_pos(2)=dposition(2)
     dbar_pos(3)=dbar_pos(1)+0.02
     dbar_titlepos=[0.43,0.94]
     dbar_orient="xtop"
     dbar_charthick=dcharthick-0.5
     dbar_thick=dcharthick
     dbar_charsize=dcharsize
     dbar_titchart=dcharthick-0.5
     dbar_titchars=dcharsize
     dload=39
     dreverse_load=0
     dnwin=0
  ENDELSE

  IF (NOT (KEYWORD_SET(swap)))         THEN swap=dswap  
  IF (NOT (KEYWORD_SET(xsize)))        THEN xsize=dxsize
  IF (NOT (KEYWORD_SET(ysize)))        THEN ysize=dysize              
  IF (NOT (KEYWORD_SET(background)))   THEN background=dbackground
  IF (NOT (KEYWORD_SET(color)))        THEN color=dcolor
  IF (NOT (KEYWORD_SET(charthick)))    THEN charthick=dcharthick
  IF (NOT (KEYWORD_SET(charsize)))     THEN charsize=dcharsize
  IF (NOT (KEYWORD_SET(thick)))        THEN thick=dthick
  IF (NOT (KEYWORD_SET(ticklen)))      THEN ticklen=dticklen
  IF (NOT (KEYWORD_SET(multi)))        THEN multi=dmulti
  IF (NOT (KEYWORD_SET(xthick)))       THEN xthick=dxthick
  IF (NOT (KEYWORD_SET(ythick)))       THEN ythick=dythick
  IF (NOT (KEYWORD_SET(position)))     THEN position=dposition
  IF (NOT (KEYWORD_SET(bar_pos)))      THEN BEGIN
     bar_pos =  fltarr(4)
     bar_pos(0)=position(0)
     bar_pos(1)=position(3)+0.09
     bar_pos(2)=position(2)
     bar_pos(3)=bar_pos(1)+0.02
  ENDIF
  IF (NOT (KEYWORD_SET(bar_titlepos))) THEN bar_titlepos=dbar_titlepos
  IF (NOT (KEYWORD_SET(bar_orient)))   THEN bar_orient=dbar_orient
  IF (NOT (KEYWORD_SET(bar_charthick)))THEN bar_charthick=dbar_charthick
  IF (NOT (KEYWORD_SET(bar_thick)))    THEN bar_thick=dbar_thick
  IF (NOT (KEYWORD_SET(bar_charsize))) THEN bar_charsize=dbar_charsize
  IF (NOT (KEYWORD_SET(bar_titchart))) THEN bar_titchart=dbar_titchart
  IF (NOT (KEYWORD_SET(bar_titchars))) THEN bar_titchars=dbar_titchars
  IF (N_ELEMENTS(load) EQ 0)           THEN load=dload
  IF (N_ELEMENTS(reverse_load) EQ 0)        THEN reverse_load=dreverse_load
  IF (NOT (KEYWORD_SET(nwin)))         THEN nwin=dnwin

  IF KEYWORD_SET(save_dns_confi)       THEN BEGIN
     dswap=swap
     dxsize=xsize
     dysize=ysize
     dbackground=background
     dcolor=color
     dcharthick=charthick
     dcharsize=charsize
     dthick=thick
     dticklen=ticklen
     dmulti=multi
     dxthick=xthick
     dythick=ythick
     dposition=position
     dbar_titlepos=bar_titlepos
     dbar_orient=bar_orient
     dbar_charthick=bar_charthick
     dbar_thick=bar_charthick
     dbar_charsize=bar_charsize
     dbar_titchart=bar_titchart
     dbar_titchars=bar_titchars
     dload=load
     dreverse_load=reverse_load
     dnwin=nwin
     save, dswap, $ 
           dxsize, dysize, $
           dbackground, dcolor,$
           dcharthick, dcharsize, $
           dthick, dticklen, dmulti,$
           dxthick, dythick, $
           dposition, $
           dbar_titlepos, $
           dbar_orient, dbar_charthick, $
           dbar_thick, dbar_charsize,$
           dbar_titchart,$
           dbar_titchars,$
           dload, dreverse_load, dnwin, $
           FILENAME=dns_confi+".sav"
  ENDIF

  IF (NOT (KEYWORD_SET(dim)))          THEN dim='xz'
  IF (NOT (KEYWORD_SET(namefile)))     THEN namefile=name

;---------------------------------------------------------------------------------
  SPAWN, 'echo $DNS_PROJECTS', projects
  IF (NOT (KEYWORD_SET(folder)))       THEN folder=projects+'/Plots/'+idlparam+'/' 
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
     DEVICE, DECOMPOSED=0, RETAIN=2
     WINDOW, nwin, XSIZE=xsize,YSIZE=ysize
  ENDIF ELSE BEGIN
     SET_PLOT,'Z'
     DEVICE, SET_RESOLUTION=[xsize,ysize],SET_PIXEL_DEPTH=24,DECOMPOSED=0
  ENDELSE
;---------------------------------------------------------------------------------     
  load, load
  !P.Background=background
  !P.color=color
  !P.charthick=charthick
  !P.charsize=charsize
  !P.thick=thick
  !P.ticklen=ticklen
  !P.MULTI=multi
  !x.thick=xthick
  !y.thick=ythick
  !P.position=position      
;---------------------------------------------------------------------------------
  tvlct, rgb, /get
  IF reverse_load EQ 1 THEN BEGIN 
     help, rgb
     rgb=REVERSE(rgb,1)
     rgb(0,*)=255
     rgb(255,*)=0
     !P.Background=0
     !P.color=255
  ENDIF ELSE BEGIN
     rgb(0,*)=0
     rgb(255,*)=255
     !P.Background=255
     !P.color=0
  ENDELSE
  tvlct, rgb
;---------------------------------------------------------------------------------
  IF (KEYWORD_SET(movie)) THEN BEGIN
     video=IDLffVideoWrite(folder+idlparam+'_'+namefile+'_'+dim+'.mp4')
     stream=video.AddVideoStream(xsize,ysize,10,BIT_RATE=24E5)
  ENDIF
;---------------------------------------------------------------------------------  

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                                 MAIN
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

;---------------------------------------------------------------------------------
; 2D PLOTS
;---------------------------------------------------------------------------------
  IF (STRLEN(dim) EQ 2) THEN BEGIN
      FOR k=snap0,snapf,step DO BEGIN
            IF (N_ELEMENTS(svar) EQ 0) THEN BEGIN
               dns_var,d,name,k,swap,var,$
                       var_title=var_title, var_range=var_range, var_log=var_log,$
                       ixt=ixt,iyt=iyt,izt=izt, $                   
                       ix0=ix0,iy0=iy0,iz0=iz0, $
                       ixstep=ixstep, iystep=iystep, izstep=izstep,$
                       ixf=ixf,iyf=iyf,izf=izf,$
                       im0=im0, imf=imf, imstep=imstep,$
                       sim3d=sim3d, mm=mm, dim=dim, $
                       bar_range=bar_range
               IF (KEYWORD_SET(keep_var)) THEN BEGIN
                  IF (sim3d EQ 1) THEN BEGIN
                     svar={d:d,var:var, $
                           var_title:var_title,bar_range:bar_range, var_log:var_log,$
                           im0:im0, imf:imf, imstep:imstep,$
                           sim3d:sim3d, mm:mm, dim:dim}
                  ENDIF ELSE BEGIN
                     svar={d:d,var:var, $
                           var_title:var_title,bar_range:bar_range, var_log:var_log,$
                           sim3d:sim3d,dim:dim}
                  ENDELSE
               ENDIF
            ENDIF ELSE BEGIN
               d=svar.d
               var=svar.var
               var_title=svar.var_title
               IF (NOT KEYWORD_SET(bar_range)) THEN bar_range=svar.bar_range
               IF (N_ELEMENTS(var_log) EQ 0) THEN  var_log=svar.var_log
               IF (svar.sim3d EQ 1) THEN BEGIN
                  im0=svar.im0 & imf=svar.imf & imstep=svar.imstep
                  sim3d=svar.sim3d &  mm=svar.mm 
               ENDIF ELSE sim3d=svar.sim3d
               dim=svar.dim
            ENDELSE
            IF (sim3d EQ 1) THEN BEGIN
               FOR m=im0,imf,imstep DO BEGIN
                   IF (dim EQ "yz") THEN var_plot = reform(var(m,*,*))
                   IF (dim EQ "xz") THEN var_plot = reform(var(*,m,*))
                   IF (dim EQ "xy") THEN var_plot = reform(var(*,*,m))
                   dns_2dplot, d,var_plot,dim, $
                               mm=mm+m, coord=coord,$
                               xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                               bar_name=var_title, bar_range=bar_range, bar_log=var_log,  $
                               bar_pos=bar_pos, bar_titlepos=bar_titlepos, $
                               bar_orient=bar_orient, bar_charthick=bar_charthick, $
                               bar_thick=bar_thick, bar_charsize=bar_charsize, $
                               bar_titchart=bar_titchart, bar_titchars=bar_titchars
                   wait, 0.0001
                   IF (KEYWORD_SET(png)) THEN $
                      WRITE_PNG,folder+idlparam+'_'+namefile+'_'+STRTRIM(k,2)+'_'+dim+'_'+'i'+coord+STRTRIM(mm+m,2)+'.png', TVRD(TRUE=1)
                   IF (KEYWORD_SET(movie)) THEN $
                      makingmp4=video.Put(stream,TVRD(TRUE=1))
                ENDFOR
            ENDIF ELSE BEGIN
               dns_2dplot, d,var,dim, $
                           xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                           bar_name=var_title, bar_range=bar_range, bar_log=var_log,  $
                           bar_pos=bar_pos, bar_titlepos=bar_titlepos, $
                           bar_orient=bar_orient, bar_charthick=bar_charthick, $
                           bar_thick=bar_thick, bar_charsize=bar_charsize, $
                           bar_titchart=bar_titchart, bar_titchars=bar_titchars
               IF (KEYWORD_SET(png)) THEN $
                  WRITE_PNG,folder+idlparam+'_'+namefile+'_'+STRTRIM(k,2)+'_'+dim+'.png', TVRD(TRUE=1)
               IF (KEYWORD_SET(movie)) THEN $
                  makingmp4=video.Put(stream,TVRD(TRUE=1))               
            ENDELSE
         ENDFOR
   ENDIF
;---------------------------------------------------------------------------------

IF (KEYWORD_SET(movie)) THEN video.cleanup 

;---------------------------------------------------------------------------------
;                                     END                                            
;---------------------------------------------------------------------------------

END
