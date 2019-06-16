load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir = "/home2/data/qiny/data/NEWCLDFRAC/new-cldfrac6/atm/hist/"
fn1 = "new-cldfrac6.cam.h0.0002-3.nc"

f1 = addfile(fdir+fn1,"r")

lon = f1->lon
lat = f1->lat

T0 = f1->T(0,0,:,:)
PBLH = f1->PBLH(0,:,:)
CONCLD = f1->CONCLD(0,:,:,:)		;time*lat*lon
AST = f1->AST(0,:,:,:)

CLOUD = f1->CLOUD(0,:,:,:)

CONCLD = CONCLD*100.
AST = AST*100.

CLOUD = CLOUD*100.

; convert PBLH height [m] into pressure[hPa]
P0 = 1000.0
gravit = 9.8
RD = 287.04

PBLH_pres = P0*exp(-gravit*PBLH/RD/T0)
copy_VarCoords(PBLH,PBLH_pres)

;create plot
wks = gsn_open_wks("pdf","./figure/lon-height-new-CONCLD-AST")
plot = new(2,graphic)

res = True
res@gsnDraw = False
res@gsnFrame = False
res@trYReverse = True
res@gsnSpreadColors = True
res@cnLinesOn = False
res@cnFillOn = True

res@lbBoxLinesOn         = False     ; Turn off labelbar box lines

res@trYMinF = 750.

res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"

res@tmXBTickSpacingF= 15.

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 0 
res@cnMaxLevelValF = 20. 
res@cnLevelSpacingF = 1.
res@gsnLeftString = ""
res@gsnRightString = ""

plot(0) = gsn_csm_contour(wks,CONCLD(:,{-10},{220:290}),res)

sres = True
sres@gsnDraw = False
sres@gsnFrame = False
sres@cnLevelSelectionMode = "ExplicitLevels"
sres@cnLevelSelectionMode = "ManualLevels"
sres@cnMinLevelValF = 0.
sres@cnMaxLevelValF = 100.
sres@cnLevelSpacingF = 5.
sres@cnInfoLabelOn = False
sres@lbBoxLinesOn         = False     ; Turn off labelbar box lines

sres@gsnRightString = "10S"
sres@gsnLeftString = "CONCLD(shaded) - AST"
plot_ov = gsn_csm_contour(wks,AST(:,{-10},{220:290}),sres) 
overlay(plot(0),plot_ov)

lres = True
lres@gsnDraw = False
lres@gsnFrame = False
lres@xyLineThicknessF = 3.0
lres@xyLineColor = "Red"
lres@gsnLeftString = ""
lres@gsnRightString = ""

plot_ov = gsn_csm_xy(wks,lon({220:290}),PBLH_pres({-10},{220:290}),lres)
overlay(plot(0),plot_ov)


plot(1) = gsn_csm_contour(wks,CONCLD(:,{-20},{220:290}),res)

sres@gsnRightString = "20S"
sres@gsnLeftString = "CONCLD(shaded) - AST"
plot_ov = gsn_csm_contour(wks,AST(:,{-20},{220:290}),sres) 
overlay(plot(1),plot_ov)

plot_ov = gsn_csm_xy(wks,lon({220:290}),PBLH_pres({-20},{220:290}),lres)
overlay(plot(1),plot_ov)


gsn_panel(wks,plot,(/1,2/),False)
end
