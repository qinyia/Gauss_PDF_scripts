load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
fdir = "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision-1/data/output/"
fdir_append = ""

fname1 = "FC5_f09f09_MG15_COSP"
fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

append = ".cam.h0.ANN.nc"

f1 = addfile(fdir+fname1+"/"+fname1+append,"r")
f2 = addfile(fdir+fname2+"/"+fname2+append,"r")

CLDLOW = f1->CLDLOW		;time*lat*lon
sgm_turb = f2->sgm_tota(0,{912},:,:)
sgm_shal = f2->sgm_shal(0,{912},:,:)
sgm_deep = f2->sgm_turb(0,{912},:,:)

var0 = sqrt(sgm_turb)
var0 = var0*1000.


var1 = sqrt(abs(sgm_shal))
var1 = var1*1000.

var2 = sqrt(abs(sgm_deep))
var2 = var2*1000.

copy_VarCoords(sgm_turb,var0)
copy_VarCoords(sgm_shal,var1)
copy_VarCoords(sgm_deep,var2)

;========directly output subgrid scale variance: sgmqt
;sgmqt = f2->sgmqt(0,{912},:,:)
;sgmqt = sgmqt*1000.
;printVarSummary(sgmqt)
;sgmqt@units = "g/kg"



;create plot
wks = gsn_open_wks("eps","../figure/fig8-lat-lon-sgm-revised-2-912hPa-eps")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

;plot= new(6,graphic)

res = True

res@gsnFrame = False
res@gsnDraw = False

res@gsnSpreadColors = True
res@gsnSpreadColorStart = 2
res@gsnSpreadColorEnd = 150

res@cnLinesOn = False
res@cnFillOn = True

res@mpMinLonF = 0
res@mpMaxLonF = 360
res@mpCenterLonF = 180

res@lbLabelStride = 5.

;res@gsnRightString = "g/kg"
res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 2.
res@cnMinLevelValF       = 0.
res@cnLevelSpacingF      = 0.1

res@gsnRightString = ""
res@gsnLeftStringFontHeightF = 0.025

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMinLevelValF       = 0.
res@cnMaxLevelValF       = 0.4
res@cnLevelSpacingF      = 0.02


res@gsnLeftString = "(a) ~F33~s~F~_tota~"
plot2 = gsn_csm_contour_map_ce(wks,var0,res)

res@gsnLeftString = "(b) ~F33~s~F~_shal~"
plot3 = gsn_csm_contour_map_ce(wks,var1,res)


res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 0.3
res@cnMinLevelValF       = 0.
res@cnLevelSpacingF      = 0.02

res@gsnLeftString = "(c) ~F33~s~F~_turb~"
plot4 = gsn_csm_contour_map_ce(wks,var2,res)

pres = True
;pres@gsnPanelRowSpec = True                   ; tell panel what order to plot

gsn_panel(wks,(/plot2,plot3,plot4/),(/3,1/),pres)


end
