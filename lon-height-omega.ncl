load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

load "./functions_zmmsf.ncl"

begin
;***************file 1********************
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

fname1 = "F_2000_f09f09_MG1.5"
fname2 = "new-cldfrac16-1d-MG15"
fname3 = "omega" ; the temp. file for output

append = ".cam.h0.ANN.nc"

compare = "Model"

f1 = addfile(fdir+fname1+fdir_append+fname1+append,"r")
f2 = addfile(fdir+fname2+fdir_append+fname2+append,"r")

OMEGA_1 = f1->OMEGA(0,:,{-30:30},:)
OMEGA_2 = f2->OMEGA(0,:,{-30:30},:)

;OMEGA_1 = f1->OMEGA(0,:,{-10:10},:)
;OMEGA_2 = f2->OMEGA(0,:,{-10:10},:)



A = dim_avg_n_Wrap(OMEGA_1,1)
B = dim_avg_n_Wrap(OMEGA_2,1)

A = A*864.
B = B*864.

data1 = A(:,:)          ; model data(lev,lat)
data2 = B(:,:)          ; model or obs data(lev,lat)


data1!0 = "lev"
data1!1 = "lat"
data2!0 = "lev"
data2!1 = "lat"

diff = data2-data1
copy_VarCoords(data1,diff)



;************************create plot***************
wks = gsn_open_wks("x11","figure/plot_zmmsf")
gsn_define_colormap(wks,"BlueRed")

plot = new(3,graphic)

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

res@gsnRightString = "hPa/day"

res2 = res
;res2@cnLevels =(/-20,-15,-10,-8,-6,-4,-2,0,2,4,6,8,10,15,20/)

res@gsnLeftString = "Park-RH (5S-5N)"
plot(0) = gsn_csm_contour(wks,data1,res)
res@gsnLeftString = "Gauss-PDF"
plot(1) = gsn_csm_contour(wks,data2,res)
res2@gsnLeftString = "Gauss_PDF-Park_RH"
plot(2) = gsn_csm_contour(wks,diff,res2)

;gsn_panel(wks,(/plot(0),plot(1)/),(/1,2/),False)

gsn_panel(wks,plot,(/2,2/),False)

end
