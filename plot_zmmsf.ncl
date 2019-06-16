load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

load "./functions_zmmsf.ncl"


begin
;***************file 1********************
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

fname1 = "F_2000_f09f09_MG1.5"
;fname1 = "new-cldfrac16-1d-MG15-revise"

fname2 = "new-cldfrac16-1d-MG15-revise"


append = ".cam.h0.ANN.nc"

f1 = addfile(fdir+fname1+fdir_append+fname1+append,"r")
f2 = addfile(fdir+fname2+fdir_append+fname2+append,"r")

A= vertical_ZMMSF(f1,f2)
B= vertical_ZMMSF(f2,f2)

printMinMax(A,False)
printMinMax(B,False)
printVarSummary(A)
exit


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
res@tiYAxisString = "pressure(hPa)"

res@gsnYAxisIrregular2Linear = True

res@gsnLeftString = ""
res@gsnRightString = ""

;res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ExplicitLevels"
res@lbOrientation = "vertical"

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

plot(0) = gsn_csm_contour(wks,data1,res)
plot(1) = gsn_csm_contour(wks,data2,res)
plot(2) = gsn_csm_contour(wks,diff,res2)


plot1 = gsn_csm_contour(wks,data1,res)

overlay(plot(2),plot1)

gsn_panel(wks,plot,(/2,2/),False)

end
