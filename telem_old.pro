PRO TELEM, tstart,tstop

; compile telemetry limit violations table for weekly report.
; tstart and tstop are of the form 20060626, yyyymmdd

outfile="telem.txt"
readcol,"telem.lst",msids,format='a'
maxarr=strarr(9,n_elements(msids))
maxarr(8,*)=0 ; mark all as no violations found yet
maxarr(0,*)=msids 
minarr=maxarr

date=tstart
day=1
while (date le tstop) do begin
  date_str=strcompress(string(date),/remove_all)
  ;print,"x"+date_str+"x" ; debug
  ;files=file_search('/data/mta/www/mp_reports/'+date_str+'20060620/*/data/*_summ.fits')
  ;files=findfile('/data/mta/www/mp_reports/'+date_str+'/*/data/*_summ.fits')
  files=findfile('/data/mta/www/ap_report/'+date_str+'/*/data/*_summ.fits')
  ;files=find_file('/data/mta/www/mp_reports/20060618/*/data/*_summ.fits')
  if (n_elements(files) gt 1) then begin
    for ifiles=0, n_elements(files)-1 do begin
      ;print,files(ifiles) ; debug
      telem=mrdfits(files(ifiles),1)
      for itelem=0,n_elements(telem)-1 do begin
        if (telem(itelem).yellow gt 0 or telem(itelem).red gt 0) then begin
   
          name=strcompress(telem(itelem).name,/remove_all)
          b=where(maxarr(0,*) eq name,bnum)
          ;b=where(maxarr(0,*) eq "HKP27V",bnum)
          ;print, telem(itelem).name,telem(itelem).max,bnum
          if (bnum eq 1) then begin
            viol=telem(itelem).max
            maxarr(day,b(0))=string(viol,format='(F7.2)')
            maxarr(8,b(0))=1
            viol=telem(itelem).min
            minarr(day,b(0))=string(viol,format='(F7.2)')
            minarr(8,b(0))=1
          endif
        endif
      endfor ;for itelem=0,n_elements(telem)-1 do begin
    endfor ; for (i=0, n_elements(files)-1) do begin
  endif ; if (n_elements(files) gt 1) then begin
  date=date+1
  day=day+1
  if (date eq 20060732) then date=20060801
endwhile ; while (date le tstop) do begin

;print,maxarr
;print,"x"+maxarr(0,0)+"x"
;print,maxarr(0,9)
openw,OUNIT,outfile,/get_lun
for iout=0,n_elements(maxarr(0,*))-1 do begin
  if (maxarr(8,iout) eq 1) then begin
    b=where(maxarr(*,iout) eq "", bnum)
    if (bnum ge 1) then maxarr(b,iout)="x"
    b=where(minarr(*,iout) eq "", bnum)
    if (bnum ge 1) then minarr(b,iout)="x"
    viols=strjoin(minarr(1:7,iout)," | ")
    printf, ounit, minarr(0,iout), " | ",viols
    viols=strjoin(maxarr(1:7,iout)," | ")
    printf, ounit, maxarr(0,iout), " | ",viols
  endif
endfor ; for iout=0,n_elements(maxarr(0,*))-1 do begin
free_lun,OUNIT
help
end
