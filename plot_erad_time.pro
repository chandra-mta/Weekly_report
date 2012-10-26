PRO PLOT_ERAD_TIME
set_plot,'z'
;device,set_resolution=[1040,1040]
device,set_resolution=[1040,520]
;!p.multi=[0,1,2,0,0]
!p.multi=[0,1,1,0,0]
fp_temp=mrdfits('dataseek_deahk_temp.0.fits',1)
alt=mrdfits('dataseek_avg.fits',1)

;fp_temp=mrdfits('PLOT_OCT1404/dataseek_deahk_temp.0.fits',1)
;alt=mrdfits('PLOT_OCT1404/dataseek_avg.fits',1)

;rdfloat,'/data/mta/DataSeeker/data/repository/earth_rad_ang.rdb',etime,tot_ang,p_ang,r_ang,skipline=2
rdfloat,'mk_rdb2.out',etime,tot_ang,p_ang,r_ang,skipline=2
;tot_ang=p_ang  ; matlab 09238 (installed 9/04/09) does not give tot_ang
;rdfloat,'/pool14/brad/earth_rad_ang.rdb',etime,tot_ang,p_ang,r_ang,skipline=2
;rdfloat,'./earth_rad_ang.rdb',etime,tot_ang,p_ang,r_ang,skipline=2
;rdfloat,'/pool14/brad/earth_rad_ang.rdb',etime,tot_ang,p_ang,r_ang,skipline=2
;etime=etime-86400.
;tot_ang=p_ang

fp_temp=fp_temp(where(fp_temp.deahk16_avg gt -150 and fp_temp.deahk16_avg lt 0))

;xmin=min(fp_temp.time)
xmin=466992063.

xmax=xmin+86400.*7.2
;xmax=max(fp_temp.time)
ymin=floor(min(fp_temp.deahk16_avg))-1.
ymax=ceil(max(fp_temp.deahk16_avg))

loadct,39

bcolor=0
lcolor=255
print,"XMIN ",xmin
plot,fp_temp.time,fp_temp.deahk16_avg,psym=2,symsize=0.6,backgr=bcolor,color=lcolor, $
   ytitle="Focal Plane Temp (degC)", $
   xtitle=" 2012",yrange=[ymin,ymax],xrange=[xmin,xmax], $
   xstyle=1,ystyle=1,ymargin=[6,4],xmargin=[10,6], $
   title="Focal Plane Temp and Sun Angles", $
   xtickv=[466992063,467164863,467337663,467510463], $
   xticks=3, $
   xtickn=["Oct19","Oct21","Oct23","Oct25"],xminor=12


;xyouts,0.985,0.75,"Angle (degrees)",align=0.5,orient=90,color=lcolor,/norm
xyouts,0.985,0.50,"Angle (degrees)",align=0.5,orient=90,color=lcolor,/norm
xyouts,xmax+5000,ymin,'0',color=lcolor,align=0,/data
xyouts,xmax+5000,ymin+45.*(ymax-ymin)/180.,'45',color=lcolor,align=0,/data
xyouts,xmax+5000,ymin+90.*(ymax-ymin)/180.,'90',color=lcolor,align=0,/data
xyouts,xmax+5000,ymin+135.*(ymax-ymin)/180.,'135',color=lcolor,align=0,/data
xyouts,xmax+5000,ymax,'180',color=lcolor,align=0,/data

print, "ALT range: ",min(alt.sc_altitude),max(alt.sc_altitude)
alt_range=max(alt.sc_altitude)-min(alt.sc_altitude)
alt_sc=(alt.sc_altitude-min(alt.sc_altitude))*(ymax-ymin)/alt_range+ymin
oplot,alt.time,alt_sc,color=200,linestyle=0,thick=2

sang_sc=(alt.pt_suncent_ang)*(ymax-ymin)/180+ymin
oplot,alt.time,sang_sc,color=240,linestyle=0,thick=2

;xyouts,0.15,0.51,"FP_temp",color=lcolor,/norm
;xyouts,0.30,0.51,"Sun angle",color=240,/norm
;xyouts,0.75,0.51,"Altitude",color=200,/norm
xyouts,0.15,0.01,"FP_temp",color=lcolor,/norm
xyouts,0.30,0.01,"Sun angle",color=240,/norm
xyouts,0.75,0.01,"Altitude",color=200,/norm

;plot,fp_temp.time,fp_temp.deahk16_avg,psym=2,symsize=0.6,backgr=bcolor,color=lcolor, $
;   ytitle="Focal Plane Temp (degC)", $
;   xtitle=" 2012",yrange=[ymin,ymax],xrange=[xmin,xmax], $
;   ;xtitle=" 2011",yrange=[-123,-106],xrange=[xmin,xmax], $
;   xstyle=1,ystyle=1,ymargin=[6,4],xmargin=[10,6], $
;   title="Focal Plane Temp and Earth Angles", $
;   xtickv=[465177596,465350396,465523196,465695996], $
;   xticks=3, $
;   xtickn=["Sep28","Sep30","Oct02","Oct04"],xminor=12
;
;xyouts,0.985,0.25,"Angle (degrees)",align=0.5,orient=90,color=lcolor,/norm
;xyouts,xmax+5000,ymin,'-180',color=lcolor,align=0,/data
;xyouts,xmax+5000,ymin+45.*(ymax-ymin)/180.,'-90',color=lcolor,align=0,/data
;xyouts,xmax+5000,ymin+90.*(ymax-ymin)/180.,'0',color=lcolor,align=0,/data
;xyouts,xmax+5000,ymin+135.*(ymax-ymin)/180.,'90',color=lcolor,align=0,/data
;xyouts,xmax+5000,ymax,'180',color=lcolor,align=0,/data

;;alt_range=max(alt.sc_altitude)-min(alt.sc_altitude)
;;alt_sc=(alt.sc_altitude-min(alt.sc_altitude))*(ymax-ymin)/alt_range+ymin
;;oplot,alt.time,alt_sc,color=200,linestyle=0,thick=2

;pang_sc=(p_ang+180)*(ymax-ymin)/360+ymin
;oplot,etime,pang_sc,color=140,linestyle=0,thick=2
;rang_sc=(r_ang+180)*(ymax-ymin)/360+ymin
;oplot,etime,rang_sc,color=100,linestyle=0,thick=2

;xyouts,0.15,0.01,"FP_temp",color=lcolor,/norm
;xyouts,0.45,0.01,"Earth pitch",color=140,/norm
;xyouts,0.6,0.01,"Earth roll",color=100,/norm
;;xyouts,0.75,0.01,"Altitude",color=200,/norm

write_gif,'plot_erad_time.gif',tvrd()

; find temp peaks
for i=0,n_elements(fp_temp)-1 do begin
  peak=0 ; no peak yet
  if (fp_temp(i).deahk16_avg gt -118.6) then begin
    tstart=fp_temp(i).time
    max_temp=fp_temp(i).deahk16_avg
    max_time=fp_temp(i).time
    while (fp_temp(i).deahk16_avg gt -118.6 and $
           i lt n_elements(fp_temp)-2) do begin
      i=i+1
      if (fp_temp(i).deahk16_avg gt max_temp) then begin
        max_temp=fp_temp(i).deahk16_avg
        max_time=fp_temp(i).time
      endif
    endwhile
    tstop=fp_temp(i).time
    print, "<tr align=center><td>",cxtime(max_time,'sec','doy'),"</td><td>",max_temp,"</td><td>",(tstop-tstart)/86400.,"</td><td align=left>&#160</td></tr>"
    ;print, cxtime(max_time,'sec','doy'),max_temp,(tstop-tstart)/86400., $
      ;format='("<tr style=\"text-align:center\"><td>",F6.2,"</td><td>",F7.2,"</td><td>",F5.2,"</td><td style=\"text-align:left\">&#160</td></tr>")'
      ;format='("<tr style=\"text-align:center\"><td>",F6.2,"</td><td>",F7.2,"</td><td>",F5.2,"</td><td>&#160</td></tr>")'
  endif ; if (fp_temp(i).deahk16_avg gt -119.2) then begin
endfor ; for i=0,n_elements(fp_temp)-1 do begin

end
