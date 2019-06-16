load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

fdir = "/home2/data/qiny/data/NEWCLDFRAC/new-cldfrac6/atm/hist/"
fn1 = "new-cldfrac6.cam.h0.0002-3.nc"



f1 = addfile(fdir+fn1,"r")

lon = f1->lon
lat = f1->lat

T0 = f1->T(0,0,:,:)
T = f1->T(0,:,:,:)		;time*lat*lon
Q = f1->Q(0,:,:,:)

CLOUD = f1->CLOUD(0,:,:,:)

Q = Q*1000.

CLOUD = CLOUD*100.


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

plot = gsn_csm_xy(wks,T(:,{-10},{270}),T&lev,res)

res@xyLineColors = (/"red"/)
plot1 = gsn_csm_xy(wks,T(:,{-10},{280}),T&lev,res)
overlay(plot,plot1)

draw(plot)
frame(wks)

end
