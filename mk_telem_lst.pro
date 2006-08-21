PRO MK_TELEM_LST

; compile telemetry limit violations table for weekly report.
; tstart and tstop are of the form 20060626, yyyymmdd

outfile="telem.lst"
openw,OUT,outfile,/get_lun
files=findfile('/data/mta/www/ap_report/20060813/*/data/*_summ.fits')
if (n_elements(files) gt 1) then begin
  for ifiles=0, n_elements(files)-1 do begin
    ;print,files(ifiles) ; debug
    telem=mrdfits(files(ifiles),1)
    for itelem=0,n_elements(telem)-1 do begin
      name=strcompress(telem(itelem).name,/remove_all)
      printf,OUT,name
    endfor ;for itelem=0,n_elements(telem)-1 do begin
  endfor ; for (i=0, n_elements(files)-1) do begin
endif ; if (n_elements(files) gt 1) then begin
free_lun,OUT
end
