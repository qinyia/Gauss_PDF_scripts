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


CIN_old = f1->CIN(0,:,:)
CIN_new = f2->CIN(0,:,:)

printMinMax(CIN_old,False)
exit

T_old = f1->T(0,:,:,:)
T_new = f2->T(0,:,:,:)

CIN_diff = CIN_new - CIN_old
copy_VarCoords(CIN_old,CIN_diff)
printMinMax(CIN_diff,False)

T_diff = T_new - T_old
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
wks = gsn_open_wks("pdf","./figure/lon-height-CIN-T-diff-20S")
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

;res@tmXBTickSpacingF= 10.
;
;res@tmXBMode        = "Explicit"	
;res@tmXBValues      = (/240,250,260,270,280,285/)
;res@tmXBLabels      = (/"120W","110W","100W","90W","80W","75W"/) 
;res@tmXBMinorValues = ispan(240,285,5)

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


res@gsnLeftString = "CIN(shaded)"

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = -0.2
res@cnMaxLevelValF = 0.2
res@cnLevelSpacingF = 0.02

plot(0) = gsn_csm_contour(wks,CIN_diff(:,{-20},{0:350}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_old({-20},{0:350}),lres)
overlay(plot(0),plot_ov1)

res2 = res

res2@cnFillOn = False
res2@cnLinesOn = True
res2@cnInfoLabelOn = False
res2@cnLineLabelsOn = True

res2@gsnRightString = "T(contour)"
res2@gsnLeftString = ""


res2@cnLevelSelectionMode = "ManualLevels"
res2@cnMinLevelValF = -1.
res2@cnMaxLevelValF = 1.
res2@cnLevelSpacingF = 0.2

res2@gsnContourZeroLineThicknessF = 3.

;res2@cnLineColor = "yellow"

;plot_ov2 = gsn_csm_contour(wks,T_diff(:,{-20},{0:350}),res2)
plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(T_diff(:,{-20},{0:350}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)

overlay(plot(0),plot_ov2)

draw(plot)
frame(wks)



end
