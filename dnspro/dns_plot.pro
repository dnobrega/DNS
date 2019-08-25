
PRO DNS_PLOT, name,snap0=snap0,snapf=snapf,snapt=snapt, step=step,$
                   ;Plot options
                   nwin=nwin, $
                   xsize=xsize, ysize=ysize, setplot=setplot,$
                   pbackground=pbackground, pcolor=pcolor,$
                   pcharthick=pcharthick, pcharsize=pcharsize, $
                   pthick=pthick, pticklen=pticklen, pmulti=pmulti,$
                   xthick=xthick, ythick=ythick, $
                   position=position, $
                   bar_pos=bar_pos, bar_titlepos=bar_titlepos, $
                   bar_orient=bar_orient, bar_charthick=bar_charthick, $
                   bar_thick=bar_thick, bar_charsize=bar_charsize,$
                   load=load, reverse=reverse, $
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
  d=obj_new('br_data',idlparam)
  br_getsnapind,idlparam,snaps
;---------------------------------------------------------------------------------
; Configuration file
;---------------------------------------------------------------------------------
  IF (NOT (KEYWORD_SET(dns_confi)))    THEN dns_confi="dns_confi"
  IF file_test(dns_confi+".sav") THEN RESTORE, dns_confi+".sav"
;---------------------------------------------------------------------------------
; Default values
;---------------------------------------------------------------------------------
  IF (NOT (KEYWORD_SET(swap)))         THEN swap=0  
  IF (NOT (KEYWORD_SET(dim)))          THEN dim='xz'
  IF (NOT (KEYWORD_SET(xsize)))        THEN xsize=800
  IF (NOT (KEYWORD_SET(ysize)))        THEN ysize=600                 
  IF (NOT (KEYWORD_SET(pbackground)))  THEN pbackground=255
  IF (NOT (KEYWORD_SET(pcolor)))       THEN pcolor=255
  IF (NOT (KEYWORD_SET(pcharthick)))   THEN pcharthick=2.0
  IF (NOT (KEYWORD_SET(pcharsize)))    THEN pcharsize=2.0
  IF (NOT (KEYWORD_SET(pthick)))       THEN pthick=2.0
  IF (NOT (KEYWORD_SET(pticklen)))     THEN pticklen=-0.02
  IF (NOT (KEYWORD_SET(pmulti)))       THEN pmulti=0
  IF (NOT (KEYWORD_SET(xthick)))       THEN xthick=2.0
  IF (NOT (KEYWORD_SET(ythick)))       THEN ythick=2.0
  IF (NOT (KEYWORD_SET(position)))     THEN position=[0.14, 0.12, 0.88, 0.74]
  IF (NOT (KEYWORD_SET(bar_pos)))      THEN BEGIN
     bar_pos =  fltarr(4)
     bar_pos(0)=position(0)
     bar_pos(1)=position(3)+0.09
     bar_pos(2)=position(2)
     bar_pos(3)=bar_pos(1)+0.02
  ENDIF
  IF (NOT (KEYWORD_SET(bar_titlepos))) THEN bar_titlepos=[0.94,0.43]
  IF (NOT (KEYWORD_SET(bar_orient)))   THEN bar_orient="xtop"
  IF (NOT (KEYWORD_SET(bar_charthick)))THEN bar_charthick=pcharthick-0.5
  IF (NOT (KEYWORD_SET(bar_thick)))    THEN bar_thick=pcharthick
  IF (NOT (KEYWORD_SET(bar_charsize))) THEN bar_charsize=pcharsize
  IF (NOT (KEYWORD_SET(bar_titchart))) THEN bar_titchart=pcharthick-0.5
  IF (NOT (KEYWORD_SET(bar_titchars))) THEN bar_titchars=pcharsize
  IF (N_ELEMENTS(load) EQ 0)           THEN MYCOLOR
  IF (NOT (KEYWORD_SET(nwin)))         THEN nwin=0
  IF (NOT (KEYWORD_SET(namefile)))     THEN namefile=name
  IF KEYWORD_SET(save_dns_confi)       THEN BEGIN
     save, swap, nwin, $ 
           xsize, ysize, $
           pbackground, pcolor,$
           pcharthick, pcharsize, $
           pthick, pticklen, pmulti,$
           xthick, ythick, $
           position, $
           bar_pos, bar_titlepos, $
           bar_orient, bar_charthick, $
           bar_thick, bar_charsize,$
           bar_titchart,$
           bar_titchars,$
           load, reverse, $
           FILENAME=dns_confi+".sav"
  ENDIF

;---------------------------------------------------------------------------------
  SPAWN, 'echo $DNS_PROJECTS', projects
  IF (NOT (KEYWORD_SET(folder)))       THEN folder=projects+'/Plots/'+idlparam+'/' 
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
  IF (NOT KEYWORD_SET(setplot)) THEN BEGIN
     SET_PLOT, 'X'
     DEVICE, DECOMPOSED=0, RETAIN=2
     WINDOW, nwin, XSIZE=xsize,YSIZE=ysize
  ENDIF ELSE BEGIN
     SET_PLOT,'Z'
     DEVICE, SET_RESOLUTION=[xsize,ysize],SET_PIXEL_DEPTH=24,DECOMPOSED=0
  ENDELSE
;---------------------------------------------------------------------------------     
  !P.Background=pbackground
  !P.color=pcolor
  !P.charthick=pcharthick
  !P.charsize=pcharsize
  !P.thick=pthick
  !P.ticklen=pticklen
  !P.MULTI=pmulti
  !x.thick=xthick
  !y.thick=ythick
  !P.position=position      
;---------------------------------------------------------------------------------
  IF (N_ELEMENTS(load) NE 0) THEN BEGIN
     IF load LT 0 THEN BEGIN
        RESTORE, "/Users/dnobrega/Bifrost/IDL/data/ancillary/bluewhitered.sav"
        tvlct, r,g,b
     ENDIF ELSE LOADCT,load,/SILENT
  ENDIF
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
            dns_var,d,name,snaps,swap,var,$
                    var_title=var_title, var_range=var_range, var_log=var_log,$
                    ixt=ixt,iyt=iyt,izt=izt, $                   
                    ix0=ix0,iy0=iy0,iz0=iz0, $
                    ixstep=ixstep, iystep=iystep, izstep=izstep,$
                    ixf=ixf,iyf=iyf,izf=izf,$
                    im0=im0, imf=imf, imstep=imstep,$
                    sim3d=sim3d, mm=mm, dim=dim

            IF (KEYWORD_SET(sim3d)) THEN BEGIN
               FOR m=im0,imf,imstep DO BEGIN
                   IF (dim EQ "yz") THEN var_plot = reform(var(m,*,*))
                   IF (dim EQ "xz") THEN var_plot = reform(var(*,m,*))
                   IF (dim EQ "xy") THEN var_plot = reform(var(*,*,m))
                   dns_2dplot, d,var_plot,dim, $
                               mm=mm+m, coord=coord,$
                               var_title=var_title, var_range=var_range, var_log=var_log,  $
                               xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
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
                           var_title=var_title, var_range=var_range, var_log=var_log,  $
                           xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
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
