load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/FC5_f09f09_MG15_COSP/atm/hist/"
;fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise-2-COSP/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15-revise-COSP/atm/hist/"

; should add observed dataset
fdir3 = "/home/lyl/WORK3/qinyi/data/calipso/temp/"

fn1 = "FC5_f09f09_MG15_COSP.cam.h0.ANN.nc"
;fn2 = "new-cldfrac16-1d-MG15-revise-2-COSP.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-1d-MG15-revise-COSP.cam.h0.ANN.nc"

fn3 = "clcalipso_obs4MIPs_CALIOP_L3_CALIPSO-GOCCP-v2.1_clm.nc"


f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")
f3 = addfile(fdir3+fn3,"r")

lon1 = f1->lon
lat1 = f1->lat
lev = f1->lev
cosp_ht = f1->cosp_ht ; units: m

lon2 = f3->lon
lat2 = f3->lat
alt = f3->alt40 ; units : m


cld_old = f1->CLD_CAL(0,:,:,:)
cld_new = f2->CLD_CAL(0,:,:,:)
cld_obs = f3->clcalipso(0,:,:,:)
printMinMax(cld_old,False)
printMinMax(cld_new,False)
printMinMax(cld_obs,False)

;cld_old = cld_old*100.
;cld_new = cld_new*100.
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
Pres_obs = P0*exp(-gravit*alt/RD/T)
Pres_mod = P0*exp(-gravit*cosp_ht/RD/T)
;print(Pres)

cld_obs!0 = "lev"
cld_obs&lev = Pres_obs
cld_obs&lev@units = "hPa"

cld_old!0 = "lev"
cld_old&lev = Pres_mod
cld_old&lev@units = "hPa"

cld_new!0 = "lev"
cld_new&lev = Pres_mod
cld_new&lev@units = "hPa"



printVarSummary(cld_obs)




;create plot
wks = gsn_open_wks("pdf","./figure/lon-height-cloud-all-revise-2-COSP")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
plot = new(9,graphic)

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
res@trYMaxF = lev(29)

res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"

res@tmXBTickSpacingF= 10.

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 5. 
res@cnMaxLevelValF = 70.
res@cnLevelSpacingF = 5.

;res@gsnRightString = "%"
res@gsnRightString = ""

;=======================================
lres = True
lres@gsnDraw = False
lres@gsnFrame = False
lres@xyLineThicknessF = 4.0 
lres@gsnLeftString = ""
lres@gsnRightString = ""

res@gsnLeftStringFontHeightF = 0.03

res@gsnLeftString = "(a)RH-Off Peru"
plot(0) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_old(:,{-20:-10},{240:280}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({240:280}),dim_avg_n_Wrap(pblh_pres_old({-20:-10},{240:280}),0),lres)
;overlay(plot(0),plot_ov1)

res@gsnLeftString = "(b)PDF-off Peru"
plot(1) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_new(:,{-20:-10},{240:280}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({240:280}),dim_avg_n_Wrap(pblh_pres_new({-20:-10},{240:280}),0),lres)
;overlay(plot(1),plot_ov1)

res@gsnLeftString = "(c)Obs-off Peru"
plot(2) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_obs(:,{-20:-10},{240:280}),1),res)

;==========
res@gsnLeftString = "(d) RH-off California"
plot(3) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_old(:,{20:30},{200:240}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({200:240}),dim_avg_n_Wrap(pblh_pres_old({20:30},{200:240}),0),lres)
;overlay(plot(3),plot_ov1)

res@gsnLeftString = "(e) PDF-off California"
plot(4) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_new(:,{20:30},{200:240}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({200:240}),dim_avg_n_Wrap(pblh_pres_new({20:30},{200:240}),0),lres)
;overlay(plot(4),plot_ov1)

res@gsnLeftString = "(f) Obs-off California"
plot(5) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_obs(:,{20:30},{200:240}),1),res)

;=============

res@gsnLeftString = "(g) RH-off Namibia"
plot(6) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_old(:,{-20:-10},{330:360}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({330:360}),dim_avg_n_Wrap(pblh_pres_old({-20:-10},{330:360}),0),lres)
;overlay(plot(6),plot_ov1)

res@gsnLeftString = "(h) PDF-off Namibia"
plot(7) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_new(:,{-20:-10},{330:360}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({330:360}),dim_avg_n_Wrap(pblh_pres_new({-20:-10},{330:360}),0),lres)
;overlay(plot(7),plot_ov1)

res@gsnLeftString = "(i) Obs-off Namibia"
plot(8) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_obs(:,{-20:-10},{330:360}),1),res)





resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
;resPanel@gsnMaximize     = True                 ; fill up the page
gsn_panel(wks,plot,(/3,3/),resPanel)

end
