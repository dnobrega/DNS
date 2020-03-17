
PRO DNS_PLOT, name,snap0=snap0,snapf=snapf,snapt=snapt, step=step,$
              keep_var=keep_var, svar=svar,$
                   ;Plot options
                   nwin=nwin, $
                   xsize=xsize, ysize=ysize, setplot=setplot,$
                   charthick=charthick, charsize=charsize, $
                   thick=thick, ticklen=ticklen, $
                   xthick=xthick, ythick=ythick, $
                   position=position, $
                   bar_pos=bar_pos, $
                   bar_titlepos=bar_titlepos,$
                   bar_titchart=bar_titchart,bar_titchars=bar_titchars,$
                   bar_orient=bar_orient, bar_charthick=bar_charthick, $
                   bar_thick=bar_thick, bar_charsize=bar_charsize,$
                   load=load, reverse_load=reverse_load, $
                   bottom=bottom, top=top, smooth=smooth,$
                   nosquare=nosquare,$
                   ; Saving options
                   dns_confi=dns_confi, save_dns_confi=save_dns_confi,$
                   namefile=namefile,$                   
                   folder=folder,movie=movie,png=png,$
                   save_dnsvar=save_dnsvar, save_dnsfolder=save_dnsfolder,$
                   ; Variable options
                   dim=dim,$
                   var_range=var_range,var_log=var_log, var_title=var_title,$
                   xmin=xmin, xmax=xmax, $
                   ymin=ymin, ymax=ymax, $
                   zmin=zmin, zmax=zmax, $
                   ixt=ixt,iyt=iyt,izt=izt, $
                   ix0=ix0,iy0=iy0,iz0=iz0, $
                   ixstep=ixstep, iystep=iystep, izstep=izstep,$
                   ixf=ixf,iyf=iyf,izf=izf,$
                   xshift=xshift, yshift=yshift,zshift=zshift,ishift=ishift, jshift=jshift,$
                   ; Oplot options
                   oline=oline, ostyle=ostyle, othick=othick, ocolor=ocolor,$
                   ox=ox, oy=oy, $
                   ; Contour options
                   c_var=c_var,$
                   c_levels=c_levels,c_load=c_load,c_colors=c_colors,$
                   c_thick=c_thick, c_linestyle=c_linestyle

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
     dcharthick=2.0
     dcharsize=2.0
     dthick=2.0
     dticklen=-0.02
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
     dbottom=0
     dtop=255
     dnosquare=1
     dsmooth=0
     dnwin=0
  ENDELSE

  IF (NOT (KEYWORD_SET(swap)))         THEN swap=dswap  
  IF (NOT (KEYWORD_SET(xsize)))        THEN xsize=dxsize
  IF (NOT (KEYWORD_SET(ysize)))        THEN ysize=dysize              
  IF (NOT (KEYWORD_SET(charthick)))    THEN charthick=dcharthick
  IF (NOT (KEYWORD_SET(charsize)))     THEN charsize=dcharsize
  IF (NOT (KEYWORD_SET(thick)))        THEN thick=dthick
  IF (NOT (KEYWORD_SET(ticklen)))      THEN ticklen=dticklen
  IF (NOT (KEYWORD_SET(xthick)))       THEN xthick=dxthick
  IF (NOT (KEYWORD_SET(ythick)))       THEN ythick=dythick
  IF (NOT (KEYWORD_SET(position)))     THEN position=dposition
  IF (NOT (KEYWORD_SET(bar_pos)))      THEN bar_pos=dbar_pos
  IF (NOT (KEYWORD_SET(bar_titlepos))) THEN bar_titlepos=dbar_titlepos
  IF (NOT (KEYWORD_SET(bar_orient)))   THEN bar_orient=dbar_orient
  IF (NOT (KEYWORD_SET(bar_charthick)))THEN bar_charthick=dbar_charthick
  IF (NOT (KEYWORD_SET(bar_thick)))    THEN bar_thick=dbar_thick
  IF (NOT (KEYWORD_SET(bar_charsize))) THEN bar_charsize=dbar_charsize
  IF (NOT (KEYWORD_SET(bar_titchart))) THEN bar_titchart=dbar_titchart
  IF (NOT (KEYWORD_SET(bar_titchars))) THEN bar_titchars=dbar_titchars
  IF (N_ELEMENTS(load) EQ 0)           THEN load=dload
  IF (N_ELEMENTS(reverse_load) EQ 0)   THEN reverse_load=dreverse_load
  IF (N_ELEMENTS(bottom) EQ 0)         THEN bottom=dbottom
  IF (N_ELEMENTS(top) EQ 0)            THEN top=dtop
  IF (N_ELEMENTS(nosquare) EQ 0)       THEN nosquare=1
  IF (N_ELEMENTS(smooth) EQ 0)         THEN smooth=dsmooth
  IF (NOT (KEYWORD_SET(nwin)))         THEN nwin=dnwin

  IF KEYWORD_SET(save_dns_confi)       THEN BEGIN
     dswap=swap
     dxsize=xsize
     dysize=ysize
     dcharthick=charthick
     dcharsize=charsize
     dthick=thick
     dticklen=ticklen
     dxthick=xthick
     dythick=ythick
     dposition=position
     dbar_pos=bar_pos
     dbar_titlepos=bar_titlepos
     dbar_orient=bar_orient
     dbar_charthick=bar_charthick
     dbar_thick=bar_charthick
     dbar_charsize=bar_charsize
     dbar_titchart=bar_titchart
     dbar_titchars=bar_titchars
     dload=load
     dreverse_load=reverse_load
     dbottom=bottom
     dtop=top
     dnosquare=nosquare
     dsmooth=smooth
     dnwin=nwin
     save, dswap, $ 
           dxsize, dysize, $
           dcharthick, dcharsize, $
           dthick, dticklen, $
           dxthick, dythick, $
           dposition, $
           dbar_pos,dbar_titlepos, $
           dbar_orient, dbar_charthick, $
           dbar_thick, dbar_charsize,$
           dbar_titchart,$
           dbar_titchars,$
           dload, dreverse_load, dbottom, dtop, $
           dnosquare,dsmooth,dnwin, $
           FILENAME=dns_confi+".sav"
  ENDIF

  IF (NOT (KEYWORD_SET(dim)))          THEN dim='xz'
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
     IF (!D.WINDOW NE nwin) THEN BEGIN
        DEVICE, DECOMPOSED=0, RETAIN=2
        WINDOW, nwin, XSIZE=xsize,YSIZE=ysize
     ENDIF
  ENDIF ELSE BEGIN
     IF (setplot EQ 1) THEN BEGIN 
        SET_PLOT,'Z'
        DEVICE, SET_RESOLUTION=[xsize,ysize],SET_PIXEL_DEPTH=24,DECOMPOSED=0
     ENDIF
  ENDELSE
;---------------------------------------------------------------------------------     
  load, load
  !P.charthick=charthick
  !P.charsize=charsize
  !P.thick=thick
  !P.ticklen=ticklen
  !x.thick=xthick
  !y.thick=ythick
  !P.position=position      
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
     video=IDLffVideoWrite(folder+idlparam+'_'+namefile+'_'+dim+'.mp4')
     stream=video.AddVideoStream(xsize,ysize,10,BIT_RATE=24E5)
  ENDIF
;---------------------------------------------------------------------------------  

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
;
;                                 MAIN
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  FOR k=snap0,snapf,step DO BEGIN
     IF (N_ELEMENTS(svar) EQ 0) THEN BEGIN
        dns_var,d,name,k,swap,var,$
                var_title=var_title, var_range=var_range, var_log=var_log,$
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
        IF (KEYWORD_SET(keep_var)) THEN BEGIN
           svar={d:d,var:var, $
                 bar_title:bar_title,bar_range:var_range, bar_log:bar_log,$
                 im0:im0, imf:imf, imstep:imstep,$
                 dim:dim}
        ENDIF
     ENDIF ELSE BEGIN
        d=svar.d
        var=svar.var
        IF (NOT KEYWORD_SET(var_title)) THEN bar_title=svar.bar_title ELSE bar_title=var_title
        IF (NOT KEYWORD_SET(var_range)) THEN var_range=svar.bar_range 
        IF (N_ELEMENTS(var_log) EQ 0)   THEN bar_log=svar.bar_log     ELSE bar_log=var_log
        im0=svar.im0 & imf=svar.imf & imstep=svar.imstep
        dim=svar.dim
     ENDELSE
     
     FOR m=im0,imf,imstep DO BEGIN
        IF (dim EQ "yz") THEN var_plot = reform(var(m,*,*))
        IF (dim EQ "xz") THEN var_plot = reform(var(*,m,*))
        IF (dim EQ "xy") THEN var_plot = reform(var(*,*,m))
        dns_2dplot, d,k,var_plot,dim, $
                    xx=xx, yy=yy, zz=zz,$
                    xtitle=xtitle, ytitle=ytitle, title=title(m),$
                    xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,zmin=zmin,zmax=zmax,$
                    ishift=ishift,jshift=jshift,$
                    bar_name=bar_title, var_range=var_range, bar_log=bar_log,  $
                    bar_pos=bar_pos, bar_titlepos=bar_titlepos, $
                    bar_orient=bar_orient, bar_charthick=bar_charthick, $
                    bar_thick=bar_thick, bar_charsize=bar_charsize, $
                    bar_titchart=bar_titchart, bar_titchars=bar_titchars,$
                    bottom=bottom, top=top, smooth=smooth,$
                    nosquare=nosquare,$
                    oline=oline,$
                    ostyle=ostyle, othick=othick, ocolor=ocolor,$
                    ox=ox, oy=oy
        
        IF (N_ELEMENTS(c_var) GT 0) THEN BEGIN
           DNS_CONTOUR, d, k, 0, $
                        c_var, c_levels,$
                        dim=dim, xx=xx,y=yy,$
                        ishift=ishift, jshift=jshift,$
                        ixt=ixt,iyt=iyt,izt=izt,$
                        c_load=c_load,$
                        c_colors=c_colors,$
                        c_thick=c_thick, $
                        c_linestyle=c_linestyle
        ENDIF
        
        wait, 0.0001
        IF (KEYWORD_SET(png)) THEN $
           WRITE_PNG,folder+idlparam+'_'+namefile+'_'+dim+'_'+STRTRIM(k,2)+'_('+STRCOMPRESS(title(m),/remove_all)+').png', TVRD(TRUE=1)
        IF (KEYWORD_SET(movie)) THEN $
           makingmp4=video.Put(stream,TVRD(TRUE=1))
        
     ENDFOR
  ENDFOR
;---------------------------------------------------------------------------------
  
  IF (KEYWORD_SET(movie)) THEN video.cleanup 
  
;---------------------------------------------------------------------------------
;                                     END                                            
;---------------------------------------------------------------------------------

END
