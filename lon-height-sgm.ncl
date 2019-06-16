load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-fix/atm/hist/"
;fn1 = "new-cldfrac16-1d-MG15-fix.cam.h0.ANN.nc"

fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise-2-COSP/atm/hist/"
fn1 = "new-cldfrac16-1d-MG15-revise-2-COSP.cam.h0.ANN.nc"


;fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15/atm/hist/"
;fn1 = "new-cldfrac16-1d-MG15.cam.h0.ANN.nc"



f1 = addfile(fdir+fn1,"r")

lon = f1->lon
lat = f1->lat

T0 = f1->T(0,0,:,:)
PBLH = f1->PBLH(0,:,:)
sgm_tota = f1->sgm_tota(0,:,:,:)		;time*lat*lon
sgm_turb = f1->sgm_turb(0,:,:,:)		;time*lat*lon
sgm_shal = f1->sgm_shal(0,:,:,:)		;time*lat*lon

CLOUD = f1->CLOUD(0,:,:,:)

sgm_tota = sqrt(abs(sgm_tota))*1e3
sgm_turb = sqrt(abs(sgm_turb))*1e3
sgm_shal = sqrt(abs(sgm_shal))*1e3

printMinMax(sgm_shal,False)

CLOUD = CLOUD*100.

; convert PBLH height [m] into pressure[hPa]
P0 = 1000.0
gravit = 9.8
RD = 287.04

PBLH_pres = P0*exp(-gravit*PBLH/RD/T0)
copy_VarCoords(PBLH,PBLH_pres)

;create plot
wks = gsn_open_wks("x11","./figure/lon-height-sgm_tota-CLOUD")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
plot = new(3,graphic)

res = True
res@gsnDraw = False
res@gsnFrame = False
res@trYReverse = True
res@gsnSpreadColors = True
res@gsnSpreadColorStart = 2
res@gsnSpreadColorEnd = 160


res@cnLinesOn = False
res@cnFillOn = True

res@lbBoxLinesOn         = False     ; Turn off labelbar box lines

res@trYMinF = 750.

res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"

;res@tmXBTickSpacingF= 15.

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 0.05
res@cnMaxLevelValF = 0.5
res@cnLevelSpacingF = 0.05
res@gsnLeftString = ""
res@gsnRightString = ""

plot(0) = gsn_csm_contour(wks,sgm_tota(:,{-20},{240:280}),res)

sres = True
sres@gsnDraw = False
sres@gsnFrame = False
sres@cnLevelSelectionMode = "ExplicitLevels"
sres@cnLevelSelectionMode = "ManualLevels"
sres@cnMinLevelValF = 10.
sres@cnMaxLevelValF = 80.
sres@cnLevelSpacingF = 5.
sres@cnInfoLabelOn = False
sres@lbBoxLinesOn         = False     ; Turn off labelbar box lines

sres@gsnRightString = "20S"
sres@gsnLeftString = "(a) sgm_tota(shaded) - CLOUD"
plot_ov = gsn_csm_contour(wks,CLOUD(:,{-20},{240:280}),sres) 
overlay(plot(0),plot_ov)

lres = True
lres@gsnDraw = False
lres@gsnFrame = False
lres@xyLineThicknessF = 3.0
lres@xyLineColor = "Red"
lres@gsnLeftString = ""
lres@gsnRightString = ""

plot_ov = gsn_csm_xy(wks,lon({240:280}),PBLH_pres({-20},{240:280}),lres)
overlay(plot(0),plot_ov)

plot(1) = gsn_csm_contour(wks,sgm_turb(:,{-20},{240:280}),res)
sres@gsnRightString = "20S"
sres@gsnLeftString = "(b) sgm_turb(shaded) - CLOUD"
plot_ov = gsn_csm_contour(wks,CLOUD(:,{-20},{240:280}),sres) 
overlay(plot(1),plot_ov)
plot_ov = gsn_csm_xy(wks,lon({240:280}),PBLH_pres({-20},{240:280}),lres)
overlay(plot(1),plot_ov)

plot(2) = gsn_csm_contour(wks,sgm_shal(:,{-20},{240:280}),res)
sres@gsnRightString = "20S"
sres@gsnLeftString = "(c) sgm_shal(shaded) - CLOUD"
plot_ov = gsn_csm_contour(wks,CLOUD(:,{-20},{240:280}),sres) 
overlay(plot(2),plot_ov)
plot_ov = gsn_csm_xy(wks,lon({240:280}),PBLH_pres({-20},{240:280}),lres)
overlay(plot(2),plot_ov)


gsn_panel(wks,plot,(/1,3/),False)
end
