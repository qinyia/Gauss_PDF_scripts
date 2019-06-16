load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir1 = "/home2/data/qiny/data/AMIP/F_2000_CAM5_f19f19.def/atm/hist/"
fn1 = "F_2000_CAM5_f19f19.def.cam.h0.0002-3.nc"

fdir2 = "/home2/data/qiny/data/NEWCLDFRAC/new-cldfrac6/atm/hist/"
fn2 = "new-cldfrac6.cam.h0.0002-3.nc"



f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")

lon = f1->lon
lat = f1->lat

T1 = f1->T(0,:,:,:)		;time*lat*lon
Q1 = f1->Q(0,:,:,:)

T2 = f2->T(0,:,:,:)		;time*lat*lon
Q2 = f2->Q(0,:,:,:)



Q1 = Q1*1000.
Q2 = Q2*1000.


;create plot
wks = gsn_open_wks("x11","./figure/lon-height-def-T-Q")

res = True
res@trYReverse = True
res@gsnFrame = False
res@gsnDraw = False

res@trYMinF = 750.

res@trXMinF = 280.
res@trXMaxF = 300.

;res@gsnYAxisIrregular2Linear = True
res@tiYAxisString = "Pressure(hPa)"

res@tmXBTickSpacingF= 15.

plot = gsn_csm_xy(wks,T1(:,{-20},{275}),T1&lev,res)

res@xyLineColors = (/"red"/)
plot1 = gsn_csm_xy(wks,T2(:,{-20},{275}),T2&lev,res)
overlay(plot,plot1)

draw(plot)
frame(wks)

end
