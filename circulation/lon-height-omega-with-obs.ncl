load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

load "./functions_zmmsf.ncl"
load "./functions_lat_interpolate.ncl"

begin

plvlO = (/30.,50.,70.,100.,150.,200.,250.,300.,400.,500.,600.,700., \
          775.,850.,925.,1000./)
plvlO@units = "mb" 
nplvlO = 16
interp = 2
p0 = 1000.
extrap = False

;***************file 1********************
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"

;fname1 = "F_2000_f09f09_MG1.5"
fname1 = "FC5_f09f09_MG15"

;fname2 = "new-cldfrac16-1d-MG15"
fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

fname3 = "ERAI_ANN_climo.nc"

append = ".cam.h0.ANN.nc"

compare = "Model"

f1 = addfile(fdir+fname1+fdir_append+fname1+append,"r")
f2 = addfile(fdir+fname2+fdir_append+fname2+append,"r")
f3 = addfile(fdir_obs+fname3,"r")

OMEGA_1 = f1->OMEGA(0,:,:,:)
OMEGA_2 = f2->OMEGA(0,:,:,:)
OMEGA_3 = f3->OMEGA(0,:,:,:)

printVarSummary(OMEGA_1)
printVarSummary(OMEGA_3)

hyam = f1->hyam
hybm = f1->hybm
ps_mod = f1->PS(0,:,:)

lev_mod = f1->lev
print(lev_mod)

lev_obs = f3->lev ; unit is hPa

lat1 = f1->lat
lon1 = f1->lon
lat2 = f2->lat
lon2 = f2->lon
lat3 = f3->lat
lon3 = f3->lon


; interpolate data

; for model: need to interpolate from hybrid level to fixed pressure level
omg_1_interp = vinth2p(OMEGA_1,hyam,hybm,plvlO,ps_mod,interp,p0,1,extrap)
omg_2_interp = vinth2p(OMEGA_2,hyam,hybm,plvlO,ps_mod,interp,p0,1,extrap)

; for observation: need to interpolate from one pressure level to another pressure level
omg_3_interp = int2p_n_Wrap(lev_obs(::-1),OMEGA_3(::-1,:,:),plvlO,1,0)



ydata = lev_lat_lon_interpolate(omg_1_interp,plvlO,lat1,lon1,omg_2_interp,lat2,lon2,omg_3_interp,lat3,lon3)

omg_1_final = ydata(0,:,{-10:10},:)
omg_2_final = ydata(1,:,{-10:10},:)
omg_3_final = ydata(2,:,{-10:10},:)


A = dim_avg_n_Wrap(omg_1_final,1)
B = dim_avg_n_Wrap(omg_2_final,1)
C = dim_avg_n_Wrap(omg_3_final,1)

A = A*864.
B = B*864.
printMinMax(A,False)
printMinMax(C,False)


data1 = A(:,:)          ; model data(lev,lat)
data2 = B(:,:)          ; model or obs data(lev,lat)
data3 = C(:,:)

data1!0 = "lev"
data1!1 = "lat"
data2!0 = "lev"
data2!1 = "lat"
data3!0 = "lev"
data3!1 = "lat"


diff_newdef = data2-data1
diff_newobs = data2-data3
diff_defobs = data1-data3

copy_VarCoords(data1,diff_newdef)
copy_VarCoords(data1,diff_newobs)
copy_VarCoords(data1,diff_defobs)


;************************create plot***************
wks = gsn_open_wks("pdf","figure/lon-height-omega-with-obs")
gsn_define_colormap(wks,"BlueRed")

plot = new(6,graphic)

res = True
res@trYReverse = True
res@gsnDraw = False
res@gsnFrame = False
res@gsnSpreadColors = True

res@tiYAxisString = "pressure(hPa)"

res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnFillOn = True
res@cnInfoLabelOn = False

res@gsnYAxisIrregular2Linear = True

res@vpHeightF = 0.3
res@vpWidthF = 0.7

;res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ExplicitLevels"
;res@lbOrientation = "vertical"

;res@gsnContourZeroLineThicknessF = 0.
;res@gsnContourNegLineDashPattern = 1


;res@cnLevels = (/-20,-10,-5,0,5,10,20,30,40,50,60,80,100,120,150/)
res@cnLevels = (/-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60/)

res@gsnRightString = "OMEGA500(hPa/day)"

res2 = res
;res2@cnLevels =(/-20,-15,-10,-8,-6,-4,-2,0,2,4,6,8,10,15,20/)
;res2@cnLevels =(/-50,-30,-10,-8,-6,-4,-2,0,2,4,6,8,10,30,50/)

res@gsnLeftString = "Park-RH (10S-10N)"
plot(0) = gsn_csm_contour(wks,data1,res)
res@gsnLeftString = "Gauss-PDF"
plot(2) = gsn_csm_contour(wks,data2,res)
res@gsnLeftString = "ERAI"
plot(4) = gsn_csm_contour(wks,data3,res)

res2@gsnLeftString = "RH-OBS"
plot(1) = gsn_csm_contour(wks,diff_defobs,res2)
res2@gsnLeftString = "PDF-OBS"
plot(3) = gsn_csm_contour(wks,diff_newobs,res2)

res2@cnLevels =(/-20,-15,-10,-8,-6,-4,-2,0,2,4,6,8,10,15,20/)
res2@gsnLeftString = "PDF-RH"
plot(5) = gsn_csm_contour(wks,diff_newdef,res2)



;gsn_panel(wks,(/plot(0),plot(1)/),(/1,2/),False)

gsn_panel(wks,plot,(/3,2/),False)

end
