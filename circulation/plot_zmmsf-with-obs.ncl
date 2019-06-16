load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

load "./functions_zmmsf.ncl"
load "./functions_lat_interpolate.ncl"


begin
;***************file 1********************
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"
fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"


fname1 = "FC5_f09f09_MG15"
;fname2 = "new-cldfrac16-1d-MG15-revise"
fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

fname3 = "ERAI_ANN_climo.nc"

append = ".cam.h0.ANN.nc"

f1 = addfile(fdir+fname1+fdir_append+fname1+append,"r")
f2 = addfile(fdir+fname2+fdir_append+fname2+append,"r")
f3 = addfile(fdir_obs+fname3,"r")

vwind_1 = f1->V(0,:,:,:)
vwind_2 = f2->V(0,:,:,:)
vwind_3 = f3->V(0,:,:,:)

hyam = f1->hyam
hybm = f1->hybm
ps_mod = f1->PS(0,:,:) ; unit is Pa
ps_obs = f3->PS(0,:,:) ;unit is hPa
ps_obs = ps_obs*100.

lev_mod = f1->lev
lev_obs = f3->lev ; unit is hPa

lat1 = f1->lat
lon1 = f1->lon
lat2 = f2->lat
lon2 = f2->lon
lat3 = f3->lat
lon3 = f3->lon

; interpolate data

; for model: need to interpolate from hybrid level to fixed pressure level
vwind_1_interp = vinth2p(vwind_1,hyam,hybm,plvlO,ps_mod,interp,p0,1,extrap)
vwind_2_interp = vinth2p(vwind_2,hyam,hybm,plvlO,ps_mod,interp,p0,1,extrap)
; for observation: need to interpolate from one pressure level to another pressure level
vwind_3_interp = int2p_n_Wrap(lev_obs(::-1),vwind_3(::-1,:,:),plvlO,1,0)

printVarSummary(vwind_1_interp)
printVarSummary(vwind_3_interp)

; horizontal interpolation of v wind
ydata = lev_lat_lon_interpolate(vwind_1_interp,plvlO,lat1,lon1,vwind_2_interp,lat2,lon2,vwind_3_interp,lat3,lon3)

vwind_1_final = ydata(0,:,:,:)
vwind_2_final = ydata(1,:,:,:)
vwind_3_final = ydata(2,:,:,:)


; horizontal interpolation of ps
xdata = lat_lon_interpolate(ps_mod,lat1,lon1,ps_mod,lat2,lon2,ps_obs,lat3,lon3)

ps_1_final = xdata(0,:,:)
ps_2_final = xdata(1,:,:)
ps_3_final = xdata(2,:,:)


presPa = plvlO*100.
presPa@units = "Pa"

; directly copy coordinate
zmmsf_1 = vwind_1_final(:,:,0)
zmmsf_2 = vwind_2_final(:,:,0)
zmmsf_3 = vwind_3_final(:,:,0)

zmmsf_1 = zonal_mpsi(vwind_1_final,vwind_1_final&lat,presPa,ps_1_final)
zmmsf_2 = zonal_mpsi(vwind_2_final,vwind_2_final&lat,presPa,ps_2_final)
zmmsf_3 = zonal_mpsi(vwind_3_final,vwind_3_final&lat,presPa,ps_3_final)

zmmsf_1 = (/zmmsf_1/1.e9/)      ; scaled for plots
zmmsf_1@long_name = "Merid stream function"
zmmsf_1@units = "kg/s x 10~S~9~N~"

zmmsf_2 = (/zmmsf_2/1.e9/)      ; scaled for plots
zmmsf_2@long_name = "Merid stream function"
zmmsf_2@units = "kg/s x 10~S~9~N~"

zmmsf_3 = (/zmmsf_3/1.e9/)      ; scaled for plots
zmmsf_3@long_name = "Merid stream function"
zmmsf_3@units = "kg/s x 10~S~9~N~"

printVarSummary(zmmsf_1)

data1 = zmmsf_1(::-1,:)          ; model data(lev,lat)
data2 = zmmsf_2(::-1,:)          ; model or obs data(lev,lat)
data3 = zmmsf_3(::-1,:)


data1!0 = "lev"
data1!1 = "lat"
data2!0 = "lev"
data2!1 = "lat"
data3!0 = "lev"
data3!1 = "lat"

printMinMax(data1,False)
printMinMax(data3,False)



diff_newdef = data2-data1
diff_newobs = data2-data3
diff_defobs = data1-data3
copy_VarCoords(data1,diff_newdef)
copy_VarCoords(data1,diff_newobs)
copy_VarCoords(data1,diff_defobs)

printMinMax(diff_newdef,False)
printMinMax(diff_newobs,False)


;************************create plot***************
wks = gsn_open_wks("pdf","figure/plot_zmmsf-with-obs")
gsn_define_colormap(wks,"BlueRed")

plot = new(6,graphic)

res = True
res@trYReverse = True
res@gsnDraw = False
res@gsnFrame = False
res@tiYAxisString = "pressure(hPa)"

res@gsnYAxisIrregular2Linear = True

res@gsnLeftString = ""
res@gsnRightString = ""

;res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ExplicitLevels"
;res@lbOrientation = "vertical"

res@gsnContourZeroLineThicknessF = 0.

res@gsnContourNegLineDashPattern = 1

res@trXMinF = -40.
res@trXMaxF = 40.


res2 = res
res2@cnLinesOn = False
res2@cnLineLabelsOn = False
res2@cnFillOn = True
res2@cnInfoLabelOn = False

res2@cnLevelSelectionMode = "ExplicitLevels"
res2@cnLevels = (/-10,-8,-6,-5,0,5,6,8,10/)

res@gsnLeftString = "RH"
plot(0) = gsn_csm_contour(wks,data1,res)
res@gsnLeftString = "PDF"
plot(1) = gsn_csm_contour(wks,data2,res)
res@gsnLeftString = "ERAI"
plot(2) = gsn_csm_contour(wks,data3,res)

res@gsnLeftString = "RH-OBS"
plot(3) = gsn_csm_contour(wks,diff_defobs,res2)
plot1 = gsn_csm_contour(wks,data3,res)
overlay(plot(3),plot1)

res@gsnLeftString = "PDF-OBS"
plot(4) = gsn_csm_contour(wks,diff_newobs,res2)
plot1 = gsn_csm_contour(wks,data3,res)
overlay(plot(4),plot1)

res@gsnLeftString = "PDF-RH"
plot(5) = gsn_csm_contour(wks,diff_newdef,res2)
plot1 = gsn_csm_contour(wks,data3,res)
overlay(plot(5),plot1)

gsn_panel(wks,plot,(/2,3/),False)

end
