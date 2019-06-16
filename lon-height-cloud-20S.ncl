load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/FC5_f09f09_MG15/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise/atm/hist/"
; should add observed dataset
fdir3 = "/home/lyl/WORK3/qinyi/data/calipso/temp/"

fn1 = "FC5_f09f09_MG15.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15-revise.cam.h0.ANN.nc"
fn3 = "clcalipso_obs4MIPs_CALIOP_L3_CALIPSO-GOCCP-v2.1_clm.nc"


f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")
f3 = addfile(fdir3+fn3,"r")

lon1 = f1->lon
lat1 = f1->lat

lon2 = f3->lon
lat2 = f3->lat
alt = f3->alt40


cld_old = f1->CLOUD(0,:,:,:)
cld_new = f2->CLOUD(0,:,:,:)
cld_obs = f3->clcalipso(0,:,:,:)

cld_old = cld_old*100.
cld_new = cld_new*100.
cld_obs = cld_obs*100.

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

;=====================================
;=====================================

;form an standard temperature profile
T0 = 288.15	;K
lapse = -0.0065	;K/m
T = T0+lapse*alt

;; convert height [m] into pressure[hPa]
P0 = 1000.0
gravit = 9.8
RD = 287.04
Pres = P0*exp(-gravit*alt/RD/T)
;print(Pres)

cld_obs!0 = "lev"
cld_obs&lev = Pres
cld_obs&lev@units = "hPa"

printVarSummary(cld_obs)




;create plot
wks = gsn_open_wks("x11","./figure/lon-height-cloud")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
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

res@trYMinF = 700.

res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"

res@tmXBTickSpacingF= 10.

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 10. 
res@cnMaxLevelValF = 80. 
res@cnLevelSpacingF = 5.

res@tmXBMode        = "Explicit"	
res@tmXBValues      = (/240,250,260,270,280,285/)
res@tmXBLabels      = (/"120W","110W","100W","90W","80W",""/) 
res@tmXBMinorValues = ispan(240,285,5)
;=======================================
lres = True
lres@gsnDraw = False
lres@gsnFrame = False
lres@xyLineThicknessF = 2.0 
lres@gsnLeftString = ""
lres@gsnRightString = ""

res@gsnLeftStringFontHeightF = 0.03

res@gsnLeftString = "(a) RH"

plot(0) = gsn_csm_contour(wks,cld_old(:,{-20},{240:285}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({240:285}),pblh_pres_old({-20},{240:285}),lres)
overlay(plot(0),plot_ov1)

res@gsnLeftString = "(b) PDF"
plot(1) = gsn_csm_contour(wks,cld_new(:,{-20},{240:285}),res)
plot_ov1 = gsn_csm_xy(wks,lon1({240:285}),pblh_pres_new({-20},{240:285}),lres)
overlay(plot(1),plot_ov1)

res@gsnLeftString = "(c) CALIPSO"
plot(2) = gsn_csm_contour(wks,cld_obs(:,{-20},{240:285}),res)


resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
resPanel@gsnMaximize     = True                 ; fill up the page
gsn_panel(wks,plot,(/3,1/),resPanel)

end
