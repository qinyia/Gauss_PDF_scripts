load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/FC5_f09f09_MG15/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15/atm/hist/"

fn1 = "FC5_f09f09_MG15.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15.cam.h0.ANN.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")

lon1 = f1->lon
lat1 = f1->lat


CLOUD_old = f1->CLOUD(0,:,:,:)
CLOUD_new = f2->CLOUD(0,:,:,:)

T_old = f1->CLDLIQ(0,:,:,:)
T_new = f2->CLDLIQ(0,:,:,:)

CLOUD_diff = CLOUD_new - CLOUD_old
copy_VarCoords(CLOUD_old,CLOUD_diff)
printMinMax(CLOUD_diff,False)

T_diff = T_new - T_old
T_diff = T_diff*1000.
copy_VarCoords(T_old,T_diff)
printMinMax(T_diff,False)



PBLH_old = f1->PBLH(0,:,:)
PBLH_new = f2->PBLH(0,:,:)

T0_old = f1->T(0,0,:,:)
T0_new = f2->T(0,0,:,:)

;=====================================
;=====================================
; convert PBLH height [m] into pressure[hPa]
P0 = 1000.0
gravit = 9.8
RD = 287.04
PBLH_pres_old = P0*exp(-gravit*PBLH_old/RD/T0_old)
copy_VarCoords(PBLH_old,PBLH_pres_old)

PBLH_pres_new = P0*exp(-gravit*PBLH_new/RD/T0_new)
copy_VarCoords(PBLH_new,PBLH_pres_new)



;create plot
wks = gsn_open_wks("x11","./figure/lon-height-CLOUD-T-diff-tropics")
;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
gsn_define_colormap(wks,"BlueRed")

plot = new(2,graphic)

res = True
res@gsnDraw = False
res@gsnFrame = False
res@trYReverse = True
;res@gsnSpreadColors = True
;res@gsnSpreadColorStart = 2
;res@gsnSpreadColorEnd = 100

res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnFillOn = True
;res@cnlbLabelStride = 4
;res@lbLabelBarOn = False

res@lbBoxLinesOn         = False     ; Turn off labelbar box lines

res@cnInfoLabelOn = False

res@trYMinF = 500.


res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"


res@gsnRightString = ""
res@gsnLeftString = ""

;=======================================
lres = True
lres@gsnDraw = False
lres@gsnFrame = False
lres@xyLineThicknessF = 3.5 
lres@gsnLeftString = ""
lres@gsnRightString = ""

;lres@xyLineColor = "red"


res@tiMainString = "Along 10N"
res@gsnLeftString = "CLOUD(shaded)"

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = -0.2
res@cnMaxLevelValF = 0.2
res@cnLevelSpacingF = 0.02

plot(0) = gsn_csm_contour(wks,CLOUD_diff(:,{-20},{240:285}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({240:285}),PBLH_pres_old({-20},{240:285}),lres)
overlay(plot(0),plot_ov1)

res2 = res

res2@cnFillOn = False
res2@cnLinesOn = True
res2@cnInfoLabelOn = False
res2@cnLineLabelsOn = True

res2@gsnRightString = "CLDLIQ(contour)"
res2@gsnLeftString = ""


res2@cnLevelSelectionMode = "ManualLevels"
res2@cnMinLevelValF = 0.
res2@cnMaxLevelValF = 0.01
res2@cnLevelSpacingF = 0.001

res2@gsnContourZeroLineThicknessF = 3.

;res2@cnLineColor = "yellow"

;plot_ov2 = gsn_csm_contour(wks,T_diff(:,{-20},{240:285}),res2)
plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(T_diff(:,{-20},{240:285}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)

overlay(plot(0),plot_ov2)

draw(plot)
frame(wks)



end
