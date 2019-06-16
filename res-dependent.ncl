load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-1d-MG15/atm/hist/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/new-cldfrac16-2d-MG15/atm/hist/"

fn1 = "new-cldfrac16-1d-MG15.cam.h0.ANN.nc"
fn2 = "new-cldfrac16-2d-MG15.cam.h0.ANN.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")

lon1 = f1->lon
lat1 = f1->lat

lon2 = f2->lon
lat2 = f2->lat

CLDLOW1 = f1->CLDLOW		;time*lat*lon
CLDLOW2 = f2->CLDLOW

CLDLOW1 = CLDLOW1*100.
CLDLOW2 = CLDLOW2*100.

tmpcld = linint2(lon1,lat1,CLDLOW1,True,lon2,lat2,0)

printVarSummary(tmpcld)

diff_cld = tmpcld-CLDLOW2
copy_VarCoords(CLDLOW2,diff_cld)



;create plot
wks = gsn_open_wks("pdf","./figure/res-dependent")
;plot= new(6,graphic)

res = True
;res@gsnFrame = False
;res@gsnDraw = False
res@gsnSpreadColors = True
res@cnLinesOn = False
res@cnFillOn = True

res@mpMinLonF = 0
res@mpMaxLonF = 360
res@mpCenterLonF = 180

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 20        ; min level
res@cnMinLevelValF       = -20
res@cnLevelSpacingF      = 5

res@tiMainString = "Low Cloud Diff b/t 1deg and 2deg"
res@gsnRightString = "%"
plot = gsn_csm_contour_map_ce(wks,diff_cld(0,:,:),res)


;gsn_panel(wks,plot,(/3,2/),False)

end
