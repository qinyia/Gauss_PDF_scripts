load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt2-vocals/run/hourmean/"
;fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-shalcld-output2/run/hourmean/"

fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-revise-2/run/hourmean/"

;fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt2-vocals-add-new-offline/run/hourmean/"

fn1 = "day03-mean.nc"
fn2 = "day03-mean.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")

lon1 = f1->lon
lat1 = f1->lat
lev = f1->lev



CLOUD_old = f2->alst_def(0,:,:,:)
CLOUD_new = f2->QQ_out1(0,:,:,:)

sgm_tota = f2->sgm_tota(0,:,:,:)

sgm_tota = sqrt(abs(sgm_tota))*1000.

;CLOUD_old = f1->CLOUD(0,:,:,:)
;CLOUD_new = f2->CLOUD(0,:,:,:)

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
wks = gsn_open_wks("pdf","./figure/lon-height-QQ-alst_def-diff-20S-capt-add-def")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
;gsn_define_colormap(wks,"BlueRed")
;gsn_define_colormap(wks,"MPL_Blues")
;gsn_define_colormap(wks,"MPL_gist_yarg")
;gsn_define_colormap(wks,"WhiteBlue")

plot = new(3,graphic)

res = True
res@gsnDraw = False
res@gsnFrame = False
res@trYReverse = True
;res@gsnSpreadColors = True
res@gsnSpreadColorStart = 2
res@gsnSpreadColorEnd = 100
res@vpWidthF = 0.75
res@vpHeightF = 0.5
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnFillOn = True
res@lbLabelStride = 5
;res@lbLabelBarOn = False
res@lbBoxLinesOn         = False     ; Turn off labelbar box lines
res@cnInfoLabelOn = False
res@trYMinF = 700.
res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"
res@gsnRightString = ""
res@gsnLeftString = ""
res@tmXBMode        = "Explicit"            
res@tmXBValues      = (/240,250,260,270,280,290/)
res@tmXBLabels      = (/"120W","110W","100W","90W","80W","70W"/) 
res@tmXBMinorValues = ispan(240,290,5)
res@tiMainString = "Along 20S"
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 0.01
res@cnMaxLevelValF = 0.21
res@cnLevelSpacingF = 0.01

plot(0) = gsn_csm_contour(wks,CLOUD_diff(:,{-20},{240:290}),res)

;=======================================
lres = True
lres@gsnDraw = False
lres@gsnFrame = False
lres@xyLineThicknessF = 3.5 
lres@gsnLeftString = ""
lres@gsnRightString = ""
lres@xyLineColor = "red"

; add PBL height
plot_ov1 = gsn_csm_xy(wks,lon1({240:290}),PBLH_pres_old({-20},{240:290}),lres)
overlay(plot(0),plot_ov1)
lres@xyDashPattern = (/1/)
plot_ov2 = gsn_csm_xy(wks,lon1({240:290}),PBLH_pres_new({-20},{240:290}),lres)
overlay(plot(0),plot_ov2)

;===============================
res2 = res
res2@cnFillOn = False
res2@cnLinesOn = True
res2@cnInfoLabelOn = False
;res2@cnLineLabelsOn = True
res2@gsnLeftString = ""
res2@cnLevelSelectionMode = "ManualLevels"
res2@cnMinLevelValF = 0.1
res2@cnMaxLevelValF = 0.5
res2@cnLevelSpacingF = 0.1
;res2@cnLineColor = "black"
res2@cnLineColor = "grey"
res2@cnLineThicknessF = 3.0

plot_ov2 = gsn_csm_contour(wks,CLOUD_old(:,{-20},{240:290}),res2)
;plot(1) = gsn_csm_contour(wks,CLOUD_old(:,{-20},{240:290}),res2)

overlay(plot(0),plot_ov2)


res2@cnLineColor = "blue"
res2@cnLineThicknessF = 3.0
res2@cnLineDashPattern = 1.0

res2@cnLevelSelectionMode = "ManualLevels"
res2@cnMinLevelValF = 0.05
res2@cnMaxLevelValF = 0.2
res2@cnLevelSpacingF = 0.05

plot_ov3 = gsn_csm_contour(wks,sgm_tota(:,{-20},{240:290}),res2)
overlay(plot(0),plot_ov3)

;======================
xmarkers = (/265,275,285/)
ymarkers = (/lev(28),lev(28),lev(28)/)

pmres = True
pmres@gsMarkerIndex = (/12,12,12/)
pmres@gsMarkerSizeF = 0.02
pmres@gsMarkerColor = "black"
pmres@gsMarkerThicknessF = 2.0

dum1 = gsn_add_polymarker(wks,plot(0),xmarkers,ymarkers,pmres)


gsn_panel(wks,plot,(/2,1/),False)

draw(plot)
frame(wks)



end
