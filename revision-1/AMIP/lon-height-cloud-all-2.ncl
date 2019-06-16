load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_lat_interpolate.ncl"

begin

fdir = "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision-1/data/output/"
fdir_append = ""

fdir_obs = "/home/lyl/WORK3/qinyi/data/calipso/temp/"

fname1 = "FC5_f09f09_MG15_COSP"

fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

fname3 = "clcalipso_obs4MIPs_CALIOP_L3_CALIPSO-GOCCP-v2.1_clm.nc"

append = ".cam.h0.ANN.nc"

f1 = addfile(fdir+fname1+"/"+fname1+append,"r")
f2 = addfile(fdir+fname2+"/"+fname2+append,"r")
f3 = addfile(fdir_obs+fname3,"r")

lon1 = f1->lon
lat1 = f1->lat
lev = f1->lev
cosp_ht = f1->cosp_ht ; units: m

lat_old = lat1
lon_old = lon1

lat_new = lat1
lon_new = lon1

lon2 = f3->lon
lat2 = f3->lat
alt = f3->alt40 ; units : m

lat_obs = lat2
lon_obs = lon2


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
printVarSummary(cld_new)


; regrid data into the same grid resolution
cloud_regrid = lev_lat_lon_interpolate(cld_obs,Pres_obs,lat_obs,lon_obs,cld_old,lat_old,lon_old,cld_new,lat_new,lon_new)

cld_obs_regrid = cloud_regrid(0,:,:,:)
cld_old_regrid = cloud_regrid(1,:,:,:)
cld_new_regrid = cloud_regrid(2,:,:,:)

printVarSummary(cld_old_regrid)
printVarSummary(cld_obs_regrid)


; regrid from 1~359 to 0~360: lon chagnes from 180 to 181
newlat = lat_obs
newlon = fspan(0.,360,181)
newlat@units = "degree_north"
newlon@units = "degree_east"

cld_obs_regrid_1 = linint2_Wrap(lon_obs,lat_obs,cld_obs_regrid,True,newlon,newlat,0)
cld_obs_regrid_1!1 = "lat"
cld_obs_regrid_1!2 = "lon"

cld_old_regrid_1 = linint2_Wrap(lon_obs,lat_obs,cld_old_regrid,True,newlon,newlat,0)
cld_old_regrid_1!1 = "lat"
cld_old_regrid_1!2 = "lon"

cld_new_regrid_1 = linint2_Wrap(lon_obs,lat_obs,cld_new_regrid,True,newlon,newlat,0)
cld_new_regrid_1!1 = "lat"
cld_new_regrid_1!2 = "lon"

printVarSummary(cld_new_regrid_1)

;create plot
wks = gsn_open_wks("eps","../figure/fig10-lon-height-cloud-all-revise-2-COSP-eps")
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

res2 = True

;plot1 = gsn_csm_contour_map_ce(wks,cld_old_regrid_1(25,:,:),res2)
;plot2 = gsn_csm_contour_map_ce(wks,cld_obs_regrid_1(25,:,:),res2)


;=======================================
lres = True
lres@gsnDraw = False
lres@gsnFrame = False
lres@xyLineThicknessF = 4.0 
lres@gsnLeftString = ""
lres@gsnRightString = ""

res@gsnLeftStringFontHeightF = 0.03

;res@trXMinF = 240.
;res@trXMaxF = 280.

res@gsnLeftString = "(a)RH-Off Peru"
plot(0) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_old_regrid_1(:,{-20:-10},{239:281}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({239:281}),dim_avg_n_Wrap(pblh_pres_old({-20:-10},{239:281}),0),lres)
;overlay(plot(0),plot_ov1)

res@gsnLeftString = "(b)PDF-off Peru"
plot(1) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_new_regrid_1(:,{-20:-10},{239:281}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({239:281}),dim_avg_n_Wrap(pblh_pres_new({-20:-10},{239:281}),0),lres)
;overlay(plot(1),plot_ov1)

res@gsnLeftString = "(c)Obs-off Peru"
plot(2) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_obs_regrid_1(:,{-20:-10},{239:281}),1),res)

;==========
;res@trXMinF = 200.
;res@trXMaxF = 240.

res@gsnLeftString = "(d) RH-off California"
plot(3) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_old_regrid_1(:,{20:30},{199:241}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({199:241}),dim_avg_n_Wrap(pblh_pres_old({20:30},{199:241}),0),lres)
;overlay(plot(3),plot_ov1)

res@gsnLeftString = "(e) PDF-off California"
plot(4) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_new_regrid_1(:,{20:30},{199:241}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({199:241}),dim_avg_n_Wrap(pblh_pres_new({20:30},{199:241}),0),lres)
;overlay(plot(4),plot_ov1)

res@gsnLeftString = "(f) Obs-off California"
plot(5) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_obs_regrid_1(:,{20:30},{199:241}),1),res)

;=============
;res@trXMinF = 330.
;res@trXMaxF = 358.


res@gsnLeftString = "(g) RH-off Namibia"
plot(6) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_old_regrid_1(:,{-20:-10},{329:360}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({329:360}),dim_avg_n_Wrap(pblh_pres_old({-20:-10},{329:360}),0),lres)
;overlay(plot(6),plot_ov1)

res@gsnLeftString = "(h) PDF-off Namibia"
plot(7) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_new_regrid_1(:,{-20:-10},{329:360}),1),res)
;plot_ov1 = gsn_csm_xy(wks,lon1({329:360}),dim_avg_n_Wrap(pblh_pres_new({-20:-10},{329:360}),0),lres)
;overlay(plot(7),plot_ov1)

res@gsnLeftString = "(i) Obs-off Namibia"
plot(8) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_obs_regrid_1(:,{-20:-10},{329:360}),1),res)



resPanel                 = True                 ; panel mods desired
resPanel@gsnPanelLabelBar= True                 ; label bar on panel
;resPanel@gsnMaximize     = True                 ; fill up the page
gsn_panel(wks,plot,(/3,3/),resPanel)

end
