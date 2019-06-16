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

MACPDLIQ_old = f1->MACPDLIQ(0,:,:,:)
MACPDLIQ_new = f2->MACPDLIQ(0,:,:,:)

MPDLIQ_old = f1->MPDLIQ(0,:,:,:)
MPDLIQ_new = f2->MPDLIQ(0,:,:,:)

ZMDLIQ_old = f1->ZMDLIQ(0,:,:,:)
ZMDLIQ_new = f2->ZMDLIQ(0,:,:,:)

CMFDLIQ_old = f1->CMFDLIQ(0,:,:,:)
CMFDLIQ_new = f2->CMFDLIQ(0,:,:,:)

CLDLIQ_old = CLDLIQ_old*1000.
CLDLIQ_new = CLDLIQ_new*1000.

MACPDLIQ_old = MACPDLIQ_old*1000*8.64e4
MACPDLIQ_new = MACPDLIQ_new*1000*8.64e4

MPDLIQ_old = MPDLIQ_old*1000*8.64e4
MPDLIQ_new = MPDLIQ_new*1000*8.64e4

CMFDLIQ_old = CMFDLIQ_old*1000*8.64e4
CMFDLIQ_new = CMFDLIQ_new*1000*8.64e4

ZMDLIQ_old = ZMDLIQ_old*1000*8.64e4
ZMDLIQ_new = ZMDLIQ_new*1000*8.64e4

printMinMax(ZMDLIQ_old,False)
printMinMax(CMFDLIQ_old,False)
printMinMax(MACPDLIQ_old,False)
printMinMax(MPDLIQ_old,False)


CLDLIQ_diff = CLDLIQ_new - CLDLIQ_old
copy_VarCoords(CLDLIQ_old,CLDLIQ_diff)
printMinMax(CLDLIQ_diff,False)

MACPDLIQ_diff = MACPDLIQ_new - MACPDLIQ_old
copy_VarCoords(MACPDLIQ_old,MACPDLIQ_diff)
printMinMax(MACPDLIQ_diff,False)

MPDLIQ_diff = MPDLIQ_new - MPDLIQ_old
copy_VarCoords(MPDLIQ_old,MPDLIQ_diff)
printMinMax(MPDLIQ_diff,False)

CMFDLIQ_diff = CMFDLIQ_new - CMFDLIQ_old
copy_VarCoords(CMFDLIQ_old,CMFDLIQ_diff)
printMinMax(CMFDLIQ_diff,False)

ZMDLIQ_diff = ZMDLIQ_new - ZMDLIQ_old
copy_VarCoords(ZMDLIQ_old,ZMDLIQ_diff)
printMinMax(ZMDLIQ_diff,False)


PBLH_old = f1->PBLH(0,:,:)
PBLH_new = f2->PBLH(0,:,:)

T0_old = f1->T(0,0,:,:)
T0_new = f2->T(0,0,:,:)

;=====================================
;=====================================
; convert PBLH height [m] into pressure[hPa]
P0 = 1000
gravit = 9.8
RD = 287.04
PBLH_pres_old = P0*exp(-gravit*PBLH_old/RD/T0_old)
copy_VarCoords(PBLH_old,PBLH_pres_old)

PBLH_pres_new = P0*exp(-gravit*PBLH_new/RD/T0_new)
copy_VarCoords(PBLH_new,PBLH_pres_new)



;create plot
wks = gsn_open_wks("x11","./figure/lon-height-CLDLIQ-Tend-10N")
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
res@cnMinLevelValF = -1.
res@cnMaxLevelValF = 1.
res@cnLevelSpacingF = 0.1

res2 = res

res2@cnFillOn = False
res2@cnLinesOn = True
res2@cnInfoLabelOn = False
res2@cnLineLabelsOn = True

res2@gsnContourZeroLineThicknessF = 0.

;res2@cnLevelSelectionMode = "ManualLevels"
;res2@cnMinLevelValF = -2.
;res2@cnMaxLevelValF = 2.
;res2@cnLevelSpacingF = 0.2


res2@gsnRightString = "ZMDLIQ(contour)"
res2@gsnLeftString = ""
;plot(0) = gsn_csm_contour(wks,CLDLIQ_diff(:,{10},{0:350}),res)
plot(0) = gsn_csm_contour(wks,ZMDLIQ_old(:,{10},{0:350}),res)

plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_old({10},{0:350}),lres)
overlay(plot(0),plot_ov1)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_new({10},{0:350}),lres2)
overlay(plot(0),plot_ov1)

plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(ZMDLIQ_diff(:,{10},{0:350}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)
overlay(plot(0),plot_ov2)

draw(plot(0))
frame(wks)


res2@gsnRightString = "CMFDLIQ(contour)"
res2@gsnLeftString = ""

plot(1) = gsn_csm_contour(wks,CMFDLIQ_old(:,{10},{0:350}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_old({10},{0:350}),lres)
overlay(plot(1),plot_ov1)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_new({10},{0:350}),lres2)
overlay(plot(1),plot_ov1)

plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(CMFDLIQ_diff(:,{10},{0:350}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)
overlay(plot(1),plot_ov2)
draw(plot(1))
frame(wks)



res2@gsnRightString = "MACPDLIQ(contour)"
res2@gsnLeftString = ""
plot(2) = gsn_csm_contour(wks,MACPDLIQ_old(:,{10},{0:350}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_old({10},{0:350}),lres)
overlay(plot(2),plot_ov1)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_new({10},{0:350}),lres2)
overlay(plot(2),plot_ov1)

plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(MACPDLIQ_diff(:,{10},{0:350}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)
overlay(plot(2),plot_ov2)
draw(plot(2))
frame(wks)



res2@gsnRightString = "MPDLIQ(contour)"
res2@gsnLeftString = ""
plot(3) = gsn_csm_contour(wks,MPDLIQ_old(:,{10},{0:350}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_old({10},{0:350}),lres)
overlay(plot(3),plot_ov1)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_new({10},{0:350}),lres2)
overlay(plot(3),plot_ov1)

plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(MPDLIQ_diff(:,{10},{0:350}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)
overlay(plot(3),plot_ov2)
draw(plot(3))
frame(wks)



gsn_panel(wks,plot,(/2,2/),False)

end
