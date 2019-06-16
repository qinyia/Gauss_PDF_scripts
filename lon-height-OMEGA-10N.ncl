load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir1 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/F_2000_f09f09_MG1.5/atm/hist/"
fdir2 = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/new-cldfrac15-1d/atm/hist/"

fn1 = "F_2000_f09f09_MG1.5.cam.h0.ANN.nc"
fn2 = "new-cldfrac15-1d.cam.h0.ANN.nc"


f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")

lon1 = f1->lon
lat1 = f1->lat


OMEGA_old = f1->OMEGA(0,:,:,:)
OMEGA_new = f2->OMEGA(0,:,:,:)

OMEGA_diff = OMEGA_new - OMEGA_old
copy_VarCoords(OMEGA_old,OMEGA_diff)

pblh_old = f1->PBLH(0,:,:)
pblh_new = f2->PBLH(0,:,:)

T0_old = f1->T(0,0,:,:)
T0_new = f2->T(0,0,:,:)

;=====================================
;=====================================
; convert pblh height [m] into pressure[hPa]
P0 = 1000.0
gravit = 9.8
RD = 287.04
pblh_pres_old = P0*exp(-gravit*pblh_old/RD/T0_old)
copy_VarCoords(pblh_old,pblh_pres_old)

pblh_pres_new = P0*exp(-gravit*pblh_new/RD/T0_new)
copy_VarCoords(pblh_new,pblh_pres_new)



;create plot
wks = gsn_open_wks("pdf","./figure/lon-height-OMEGA-10N")
;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
gsn_define_colormap(wks,"BlueRed")

plot = new(3,graphic)

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
res@lbLabelBarOn = False

res@lbBoxLinesOn         = False     ; Turn off labelbar box lines

res@cnInfoLabelOn = False

res@trYMinF = 500.

res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"


res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = -0.05
res@cnMaxLevelValF = 0.05
res@cnLevelSpacingF = 0.005

;=======================================
lres = True
lres@gsnDraw = False
lres@gsnFrame = False
lres@xyLineThicknessF = 2.0 
lres@gsnLeftString = ""
lres@gsnRightString = ""


res@gsnLeftString = "(a) CAM5-Old"

plot1 = gsn_csm_contour(wks,OMEGA_old(:,{10},{100:160}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({100:160}),pblh_pres_old({10},{100:160}),lres)
overlay(plot1,plot_ov1)

res@gsnLeftString = "(b) CAM5-New"
plot2 = gsn_csm_contour(wks,OMEGA_new(:,{10},{100:160}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({100:160}),pblh_pres_new({10},{100:160}),lres)
overlay(plot2,plot_ov1)

resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
;resPanel@gsnMaximize     = True                 ; fill up the page
gsn_panel(wks,(/plot1,plot2/),(/1,2/),resPanel)


res@gsnLeftString = "New-Old"

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = -0.01
res@cnMaxLevelValF = 0.01
res@cnLevelSpacingF = 0.001

res@lbLabelBarOn = True

plot3 = gsn_csm_contour(wks,OMEGA_diff(:,{10},{100:160}),res)

draw(plot3)
frame(wks)

end
