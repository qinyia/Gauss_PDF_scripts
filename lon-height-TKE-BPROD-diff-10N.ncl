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


TKE_old = f1->TKE(0,:,:,:)
TKE_new = f2->TKE(0,:,:,:)

BPROD_old = f1->BPROD(0,:,:,:)
BPROD_new = f2->BPROD(0,:,:,:)

BPROD_old = BPROD_old*1000.
BPROD_new = BPROD_new*1000.

TKE_diff = TKE_new - TKE_old
copy_VarCoords(TKE_old,TKE_diff)
printMinMax(TKE_diff,False)

BPROD_diff = BPROD_new - BPROD_old
copy_VarCoords(BPROD_old,BPROD_diff)
printMinMax(BPROD_diff,False)


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
wks = gsn_open_wks("pdf","./figure/lon-height-TKE-BPROD-diff-new-10N")
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


;res@gsnLeftString = "(a) CAM5-Old"
res@gsnLeftString = "TKE(shaded)"

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = -0.2
res@cnMaxLevelValF = 0.2
res@cnLevelSpacingF = 0.02

plot(0) = gsn_csm_contour(wks,TKE_diff(:,{10},{0:350}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({0:350}),PBLH_pres_old({10},{0:350}),lres)
overlay(plot(0),plot_ov1)

res2 = res

res2@cnFillOn = False
res2@cnLinesOn = True
res2@cnInfoLabelOn = False
res2@cnLineLabelsOn = True

res2@gsnRightString = "BPROD(contour)"
res2@gsnLeftString = ""


;res2@cnLevelSelectionMode = "ManualLevels"
;res2@cnMinLevelValF = -0.2
;res2@cnMaxLevelValF = 0.2
;res2@cnLevelSpacingF = 0.05

res2@gsnContourZeroLineThicknessF = 0.


plot_ov2 = gsn_csm_contour(wks,smth9_Wrap(BPROD_diff(:,{10},{0:350}),0.50,0.0,False),res2)
plot_ov2 = ZeroNegDashLineContour (plot_ov2)

overlay(plot(0),plot_ov2)

draw(plot)
frame(wks)



end
