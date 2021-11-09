PRO DNS_COLORBAR,bar_range, nlev=nlev,$
                 varname=varname, $
                 log=log,  $
                 charthick=charthick,thick=thick,chars=chars,$
                 tit_charthick=tit_charthick, tit_chars=tit_chars,$
                 orient=orient, $
                 position=position,$
                 postitle=postitle

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
;
;                                  HELP
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

; Routine to draw a colorbar from F. Moreno-Insertis and Daniel Nobrega-Siverio
;
;     --> lev2vel is a 1D array with the levels to be shown in the colorbar, 
;         e.g., to plot a linear scale of nlev components between a and b: 
;                     lev2vel=findgen(nlev)*(b-a)/(nlev-1) + a
;     --> log: the axis is plotted logarithmically
;                     but then: lev2vel contains the logarithms, like:
;                     lev2vel=findgen(nlev)*(alog10(b)-alog10(a))/(nlev-1)
;                             + alog10(a)
;     --> orient: 'xtop', 'xbot', 'yleft', 'yright' 
;                                                   
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

 p_old=!p & x_old=!x & y_old=!y

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

 IF (NOT(KEYWORD_SET(nlev))) THEN nlev=256
 lev2vel = bar_range[0]+findgen(nlev)*(bar_range[1]-bar_range[0])/(nlev-1)
 colarr  = findgen(nlev)
 nn=320/nlev & nnlong=nn*nlev & nnshort = 5
 aa = findgen(nn*nlev,nnshort)
 FOR i=0,nlev-1 DO FOR jj=0,nn-1 DO FOR kk=0,nnshort-1 DO aa(i*nn+jj,kk)=lev2vel(i) 

 IF orient EQ 'yleft' OR orient EQ 'yright' THEN aa=transpose(aa)

 CONTOUR, aa, /noerase, nlev=nlev,lev=lev2vel,/fill, c_colors=colarr,$
          xst=5,yst=5, position=position,xtit=varname

 CASE orient OF
     'xtop': BEGIN 
               titposx=(position(2)-position(0))/2+position(0) 
               titposy = position(1) - (position(3)-position(1))/2     
             END    
     'xbot': BEGIN 
               titposx=(position(2)-position(0))/2+position(0) 
               titposy = position(1) - (position(3)-position(1))/2  
             END
    'yright': BEGIN 
                titposx=(position(2)-position(0))*1.3 +position(2) 
                titposy = position(1) + (position(3)-position(1))/2 
              END
    'yleft':  BEGIN 
                titposx=(position(2)-position(0))*1.3 +position(2) 
                titposy = position(1) + (position(3)-position(1))/2 
              END
 ENDCASE

 axcol=!P.color
 titposy=postitle[1]
 titposx=postitle[0]
 xyouts,titposx,titposy,varname, $
        col=axcol,charthick=tit_charthick,chars=tit_chars,/norm,alignment=0.5


 rang=[min(lev2vel),max(lev2vel)] & IF keyword_set(log) THEN rang=10^rang

 xlog=keyword_set(log) AND (orient EQ 'xtop'  OR orient EQ 'xbot')
 ylog=keyword_set(log) AND (orient EQ 'yleft' OR orient EQ 'yright')

 IF orient EQ 'yleft'  THEN BEGIN yax=0 & xr=[0,nnshort-1] & yr=rang & ENDIF
 IF orient EQ 'yright' THEN BEGIN yax=1 & xr=[0,nnshort-1] & yr=rang & ENDIF
 IF orient EQ 'xtop'   THEN BEGIN xax=1 & yr=[0,nnshort-1] & xr=rang & ENDIF
 IF orient EQ 'xbot'   THEN BEGIN xax=0 & yr=[0,nnshort-1] & xr=rang & ENDIF
    
 IF orient EQ 'xtop' OR orient EQ 'xbot' THEN $  
    axis,xax=xax, xr=xr, yr=yr,/xst,/yst,col=axcol,xlog=xlog,ylog=ylog, $
         charth=charthick,ticklen=-0.3,chars=chars,xthick=thick,ythick=thick

 IF orient EQ 'yleft' OR orient EQ 'yright' THEN $
    axis,yax=yax, xr=xr, yr=yr,/xst,/yst,col=axcol,xlog=xlog,ylog=ylog, $
         charth=charthick,ticklen=-0.4,chars=chars,xthick=thick,ythick=thick
    
 tickns=replicate(' ',60)

 IF orient NE 'yleft' THEN $ 
    axis,yax=0,col=axcol,ythick=thick,ytickname=tickns, $
         yticks=1,yminor=1,yticklen=0.0001

 IF orient NE 'yright' THEN $ 
    axis,yax=1,col=axcol,ythick=thick,ytickname=tickns, $
         yticks=1,yminor=1,yticklen=0.0001

 IF orient NE 'xbot' THEN $   
    axis,xax=0, col=axcol,xthick=thick,xtickname=tickns, $
         xticks=1,xminor=1,xticklen=0.0001

 IF orient NE 'xtop' THEN $  
    axis,xax=1,  col=axcol,xthick=thick,xtickname=tickns, $
         xticks=1,xminor=1,xticklen=0.0001


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

 !p=p_old & !x=x_old & !y=y_old

END
