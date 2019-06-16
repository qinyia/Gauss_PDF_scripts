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


CLDLIQ_old = f1->CLDLIQ(0,:,:,:)
CLDLIQ_new = f2->CLDLIQ(0,:,:,:)

MACPDT_old = f1->MACPDT(0,:,:,:)
MACPDT_new = f2->MACPDT(0,:,:,:)

MPDT_old = f1->MPDT(0,:,:,:)
MPDT_new = f2->MPDT(0,:,:,:)

ZMDT_old = f1->ZMDT(0,:,:,:)
ZMDT_new = f2->ZMDT(0,:,:,:)

CMFDT_old = f1->CMFDT(0,:,:,:)
CMFDT_new = f2->CMFDT(0,:,:,:)

CLDLIQ_old = CLDLIQ_old*1000.
CLDLIQ_new = CLDLIQ_new*1000.

MACPDT_old = MACPDT_old/1004*8.64e4
MACPDT_new = MACPDT_new/1004*8.64e4

MPDT_old = MPDT_old/1004*8.64e4
MPDT_new = MPDT_new/1004*8.64e4

CMFDT_old = CMFDT_old*8.64e4
CMFDT_new = CMFDT_new*8.64e4

ZMDT_old = ZMDT_old*8.64e4
ZMDT_new = ZMDT_new*8.64e4

printMinMax(ZMDT_old,False)
printMinMax(CMFDT_old,False)
printMinMax(MACPDT_old,False)
printMinMax(MPDT_old,False)


CLDLIQ_diff = CLDLIQ_new - CLDLIQ_old
copy_VarCoords(CLDLIQ_old,CLDLIQ_diff)
printMinMax(CLDLIQ_diff,False)

MACPDT_diff = MACPDT_new - MACPDT_old
copy_VarCoords(MACPDT_old,MACPDT_diff)
printMinMax(MACPDT_diff,False)

MPDT_diff = MPDT_new - MPDT_old
copy_VarCoords(MPDT_old,MPDT_diff)
printMinMax(MPDT_diff,False)

CMFDT_diff = CMFDT_new - CMFDT_old
copy_VarCoords(CMFDT_old,CMFDT_diff)
printMinMax(CMFDT_diff,False)

ZMDT_diff = ZMDT_new - ZMDT_old
copy_VarCoords(ZMDT_old,ZMDT_diff)
printMinMax(ZMDT_diff,False)


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
wks = gsn_open_wks("pdf","./figure/lon-height-CLDLIQ-Tend-10N")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
;gsn_define_colormap(wks,"BlueRed")

plot = new(4,graphic)

res = True
res@gsnDraw = False
res@gsnFrame = False
res@trYReverse = True
res@gsnSpreadColors = True
res@gsnSpreadColorStart = 2
res@gsnSpreadColorEnd = 150

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

lres@xyLineColor = "blue"

lres2 = lres
lres2@xyLineColor = "green"

res@tiMainString = "Along 10N"
res@gsnLeftString = "Default(shaded)"

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = -5.
res@cnMaxLevelValF = 5.
res@cnLevelSpacingF = 0.5

res2 = res

res2@cnFillOn = False
res2@cnLinesOn = True
res2@cnInfoLabelOn = False
res2@cnLineLabelsOn = True

res2@gsnContourZeroLineThicknessF = 3.

res2@cnLevelSelectionMode = "ManualLevels"
res2@cnMinLevelValF = -5.
res2@cnMaxLevelValF = 5.
res2@cnLevelSpacingF = 0.5
res2@gsnContourZeroLineThicknessF = 0.0

res2@gsnRightString = "ZMDT(contour)"
res2@gsnLeftString = ""

;plot(0) = gsn_csm_contour(wks,CLDLIQ_diff(:,{10},{0:350}),res)
plot(0) = gsn_csm_contour(wks,ZMDT_old(:,{10},{0:350}),res)

plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_old({10},{0:350}),lres)
overlay(plot(0),plot_ov1)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_new({10},{0:350}),lres2)
overlay(plot(0),plot_ov1)

plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(ZMDT_diff(:,{10},{0:350}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)
overlay(plot(0),plot_ov2)

draw(plot(0))
frame(wks)


res2@gsnRightString = "CMFDT(contour)"
res2@gsnLeftString = ""

plot(1) = gsn_csm_contour(wks,CMFDT_old(:,{10},{0:350}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_old({10},{0:350}),lres)
overlay(plot(1),plot_ov1)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_new({10},{0:350}),lres2)
overlay(plot(1),plot_ov1)

plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(CMFDT_diff(:,{10},{0:350}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)
overlay(plot(1),plot_ov2)
draw(plot(1))
frame(wks)



res2@gsnRightString = "MACPDT(contour)"
res2@gsnLeftString = ""
plot(2) = gsn_csm_contour(wks,MACPDT_old(:,{10},{0:350}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_old({10},{0:350}),lres)
overlay(plot(2),plot_ov1)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_new({10},{0:350}),lres2)
overlay(plot(2),plot_ov1)

plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(MACPDT_diff(:,{10},{0:350}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)
overlay(plot(2),plot_ov2)
draw(plot(2))
frame(wks)



res2@gsnRightString = "MPDT(contour)"
res2@gsnLeftString = ""
plot(3) = gsn_csm_contour(wks,MPDT_old(:,{10},{0:350}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_old({10},{0:350}),lres)
overlay(plot(3),plot_ov1)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_new({10},{0:350}),lres2)
overlay(plot(3),plot_ov1)

plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(MPDT_diff(:,{10},{0:350}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)
overlay(plot(3),plot_ov2)
draw(plot(3))
frame(wks)



gsn_panel(wks,plot,(/2,2/),False)

end
