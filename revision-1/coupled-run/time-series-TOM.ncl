

begin

casename=(/"his_200","B1850C5_f19g16_mac2"/)

;casename=(/"BC5_f19g16","BC5_f19g16_mac2"/)

ncase=dimsizes(casename)

TS = new((/dimsizes(casename),12/),float)
FLNT = new((/dimsizes(casename),12/),float)
FSNT = new((/dimsizes(casename),12/),float)
RESTOM = new((/dimsizes(casename),12/),float)
RESSURF = new((/dimsizes(casename),12/),float)
RESDIFF = new((/dimsizes(casename),12/),float)

do icase=0,ncase-1

staryear="0001"
endyear="0012"

fdir = "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision/data/output/"+casename(icase)+"/"

fnam = casename(icase)+"."+staryear+"-"+endyear+".glob.avg.ann.mean.nc"

fil = addfile(fdir+fnam,"r")

TS_tmp       = fil->TS
FSNT_tmp     = fil->FSNT
FLNT_tmp     = fil->FLNT
FSNS_tmp     = fil->FSNS
FLNS_tmp     = fil->FLNS
LHFLX_tmp    = fil->LHFLX
SHFLX_tmp    = fil->SHFLX
 QFLX_tmp    = fil->QFLX
PRECC_tmp    = fil->PRECC
PRECL_tmp    = fil->PRECL
PRECSC_tmp   = fil->PRECSC
PRECSL_tmp   = fil->PRECSL

Lv = 2.501e6                   ; J/kg
Lf = 3.337e5                   ; J/kg
LHFLX_new = (/(Lv+Lf)*QFLX_tmp - Lf*1.e3*(PRECC_tmp+PRECL_tmp-PRECSC_tmp-PRECSL_tmp)/)

restom_tmp = FSNT_tmp-FLNT_tmp
ressuf_tmp = FSNS_tmp-FLNS_tmp-LHFLX_new-SHFLX_tmp

resdiff_tmp = restom_tmp-ressuf_tmp

TS(icase,:) = TS_tmp
FLNT(icase,:) = FLNT_tmp
FSNT(icase,:) = FSNT_tmp
RESTOM(icase,:) = restom_tmp
RESSURF(icase,:) = ressuf_tmp
RESDIFF(icase,:) = resdiff_tmp

end do

time = fil->time

xaxis = fspan(1,dimsizes(time),dimsizes(time))

FLNT!1 = "time"
FLNT&time = xaxis

FSNT!1 = "time"
FSNT&time = xaxis

RESTOM!1 = "time"
RESTOM&time = xaxis

RESSURF!1 = "time"
RESSURF&time = xaxis

;wks = gsn_open_wks("x11",casename+"-time-series-ann-"+staryear+"-"+endyear)
wks = gsn_open_wks("x11","B1850C5-f19g16-mac2-def-time-series-"+staryear+"-"+endyear)

plot = new(6,graphic)

res = True

res@gsnDraw = False
res@gsnFrame = False

res@vpWidthF = 0.7
res@vpHeightF = 0.3

res@trXMinF = 1.
res@trXMaxF = 12.

res@tmXBMode = "Explicit"
res@tmXBValues = xaxis
res@tmXBLabels = (/xaxis/)

res@xyLineThicknessF = 3.0
res@xyLineColors = (/"red","blue"/)
res@xyMarkLineMode = "MarkLines"
;res@xyMarkLineMode = "Lines"

res@trYMaxF = 242.
res@trYMinF = 235.

res@tiYAxisString = "FSNT&FLNT"

res@xyDashPattern = 0
plot(0) = gsn_xy(wks,xaxis,FSNT,res)

res@xyDashPattern = 2
plot1 = gsn_xy(wks,xaxis,FLNT,res)
overlay(plot(0),plot1)

delete(res@trYMaxF)
delete(res@trYMinF)


res@tiYAxisString = "RESTOM"
plot(1) = gsn_y(wks,RESTOM,res)
plot2 = gsn_y(wks,RESSURF,res)
overlay(plot(1),plot2)


gsn_panel(wks,plot,(/1,1/),False)



end
