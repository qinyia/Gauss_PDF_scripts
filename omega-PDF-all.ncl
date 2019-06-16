load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_read_file.ncl"
load "./functions_calculate.ncl"
load "./functions_plot.ncl"
load "./functions_discretize.ncl"


begin

fdir = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/"

OMEGA_old = read_omega(fdir,"F_2000_f09f09_MG1.5")
OMEGA_new = read_omega(fdir,"new-cldfrac14-1d")
OMEGA_old_500 = OMEGA_old(:,{500},:,:)
OMEGA_new_500 = OMEGA_new(:,{500},:,:)

;=======change unit from Pa/s to hPa/day
OMEGA_old_500 = OMEGA_old_500*24*3600/100.
OMEGA_new_500 = OMEGA_new_500*24*3600/100.


SWCF_old = read_SWCF(fdir,"F_2000_f09f09_MG1.5")
SWCF_new = read_SWCF(fdir,"new-cldfrac14-1d")

LWCF_old = read_LWCF(fdir,"F_2000_f09f09_MG1.5")
LWCF_new = read_LWCF(fdir,"new-cldfrac14-1d")

CLDLOW_old = read_CLDLOW(fdir,"F_2000_f09f09_MG1.5")
CLDLOW_new = read_CLDLOW(fdir,"new-cldfrac14-1d")
CLDLOW_old =CLDLOW_old*100.
CLDLOW_new = CLDLOW_new*100.

CLDMED_old = read_CLDMED(fdir,"F_2000_f09f09_MG1.5")
CLDMED_new = read_CLDMED(fdir,"new-cldfrac14-1d")
CLDMED_old = CLDMED_old*100.
CLDMED_new = CLDMED_new*100.

CLDHGH_old = read_CLDHGH(fdir,"F_2000_f09f09_MG1.5")
CLDHGH_new = read_CLDHGH(fdir,"new-cldfrac14-1d")
CLDHGH_old = CLDHGH_old*100.
CLDHGH_new = CLDHGH_new*100.

init = addfile(fdir+"F_2000_f09f09_MG1.5/atm/hist/F_2000_f09f09_MG1.5.cam.h0.0002-01.nc","r")

;======read observation data
fdir1 = "/home/lyl/WORK3/qinyi/data/ERAI/"
fdir2 = "/home/lyl/WORK3/qinyi/data/ISCCP/ftp.climserv.ipsl.polytechnique.fr/cfmip/ISCCP/old_ISCCP/"
fdir3 = "/home/lyl/WORK3/qinyi/data/CERES-EBAF/"


fn1 = "Omega_200001-201012_1deg.nc"
fn2 = "ISCCP_totlowmidhgh_cldcover_198307-200806-unit.nc"
fn3 = "CERES_EBAF-TOA_Ed2.8_Subset_200101-201001.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir2+fn2,"r")
f3 = addfile(fdir3+fn3,"r")

; CERES data starts from 2001
; so I also make other observation data start from 2001
; 2001-2008 = 8*12 = 96 months
OMEGA_obs = short2flt(f1->w(12:107,:,:,:))
;=======change unit from Pa/s to hPa/day
OMEGA_obs = OMEGA_obs*24*3600/100.
;======get 500hPa variables
OMEGA_obs_500 = OMEGA_obs(:,{500},:,:)

CLDLOW_obs = f2->lowcld(198:293,:,:)
CLDMED_obs = f2->midcld(198:293,:,:)
CLDHGH_obs = f2->highcld(198:293,:,:)

SWCF_obs = f3->toa_cre_sw_mon(:95,:,:)
LWCF_obs = f3->toa_cre_lw_mon(:95,:,:)

;=====pay attention to here! the raw data latitude is from positive
;=====to negative. Using (::-1) can flip this.
lat1 = f1->latitude(::-1)
lon1 = f1->longitude
lat2 = f2->lat
lon2 = f2->lon
lat3 = f3->lat
lon3 = f3->lon

; this is the model resolution.
lat0 = init->lat
lon0 = init->lon


dsize = dimsizes(OMEGA_obs)
ntime = dsize(0)

;======interpolate
;======here I directly use the ISCCP dataset set's resolution to interpolate.
;======because this dataset has 2 degree grid compared with other 1 degree grid.
;======should be careful if I change the OBS cloud dataset.

OMEGA_obs_500_interp = linint2(lon1,lat1,OMEGA_obs_500(:,::-1,:),False,lon2,lat2,0)
OMEGA_old_500_interp = linint2(lon0,lat0,OMEGA_old_500,False,lon2,lat2,0)
OMEGA_new_500_interp = linint2(lon0,lat0,OMEGA_new_500,False,lon2,lat2,0)
copy_VarCoords(CLDLOW_obs,OMEGA_obs_500_interp)
copy_VarCoords(CLDLOW_obs,OMEGA_old_500_interp)
copy_VarCoords(CLDLOW_obs,OMEGA_new_500_interp)

CLDLOW_obs_interp = linint2(lon2,lat2,CLDLOW_obs,False,lon2,lat2,0)
CLDLOW_old_interp = linint2(lon0,lat0,CLDLOW_old,False,lon2,lat2,0)
CLDLOW_new_interp = linint2(lon0,lat0,CLDLOW_new,False,lon2,lat2,0)
copy_VarCoords(CLDLOW_obs,CLDLOW_obs_interp)
copy_VarCoords(CLDLOW_obs,CLDLOW_old_interp)
copy_VarCoords(CLDLOW_obs,CLDLOW_new_interp)

CLDMED_obs_interp = linint2(lon2,lat2,CLDMED_obs,False,lon2,lat2,0)
CLDMED_old_interp = linint2(lon0,lat0,CLDMED_old,False,lon2,lat2,0)
CLDMED_new_interp = linint2(lon0,lat0,CLDMED_new,False,lon2,lat2,0)
copy_VarCoords(CLDLOW_obs,CLDMED_obs_interp)
copy_VarCoords(CLDLOW_obs,CLDMED_old_interp)
copy_VarCoords(CLDLOW_obs,CLDMED_new_interp)

CLDHGH_obs_interp = linint2(lon2,lat2,CLDHGH_obs,False,lon2,lat2,0)
CLDHGH_old_interp = linint2(lon0,lat0,CLDHGH_old,False,lon2,lat2,0)
CLDHGH_new_interp = linint2(lon0,lat0,CLDHGH_new,False,lon2,lat2,0)
copy_VarCoords(CLDLOW_obs,CLDHGH_obs_interp)
copy_VarCoords(CLDLOW_obs,CLDHGH_old_interp)
copy_VarCoords(CLDLOW_obs,CLDHGH_new_interp)

SWCF_obs_interp = linint2(lon3,lat3,SWCF_obs,False,lon2,lat2,0)
SWCF_old_interp = linint2(lon0,lat0,SWCF_old,False,lon2,lat2,0)
SWCF_new_interp = linint2(lon0,lat0,SWCF_new,False,lon2,lat2,0)
copy_VarCoords(CLDLOW_obs,SWCF_obs_interp)
copy_VarCoords(CLDLOW_obs,SWCF_old_interp)
copy_VarCoords(CLDLOW_obs,SWCF_new_interp)

LWCF_obs_interp = linint2(lon3,lat3,LWCF_obs,False,lon2,lat2,0)
LWCF_old_interp = linint2(lon0,lat0,LWCF_old,False,lon2,lat2,0)
LWCF_new_interp = linint2(lon0,lat0,LWCF_new,False,lon2,lat2,0)
copy_VarCoords(CLDLOW_obs,LWCF_obs_interp)
copy_VarCoords(CLDLOW_obs,LWCF_old_interp)
copy_VarCoords(CLDLOW_obs,LWCF_new_interp)

;=======tropical regions

OMEGA_obs_500_tropic = OMEGA_obs_500_interp(:,{-30:30},:)
OMEGA_old_500_tropic = OMEGA_old_500_interp(:,{-30:30},:)
OMEGA_new_500_tropic = OMEGA_new_500_interp(:,{-30:30},:)


SWCF_obs_tropic = SWCF_obs_interp(:,{-30:30},:)
SWCF_old_tropic = SWCF_old_interp(:,{-30:30},:)
SWCF_new_tropic = SWCF_new_interp(:,{-30:30},:)

LWCF_obs_tropic = LWCF_obs_interp(:,{-30:30},:)
LWCF_old_tropic = LWCF_old_interp(:,{-30:30},:)
LWCF_new_tropic = LWCF_new_interp(:,{-30:30},:)

CLDLOW_obs_tropic = CLDLOW_obs_interp(:,{-30:30},:)
CLDLOW_old_tropic = CLDLOW_old_interp(:,{-30:30},:)
CLDLOW_new_tropic = CLDLOW_new_interp(:,{-30:30},:)

CLDMED_obs_tropic = CLDMED_obs_interp(:,{-30:30},:)
CLDMED_old_tropic = CLDMED_old_interp(:,{-30:30},:)
CLDMED_new_tropic = CLDMED_new_interp(:,{-30:30},:)

CLDHGH_obs_tropic = CLDHGH_obs_interp(:,{-30:30},:)
CLDHGH_old_tropic = CLDHGH_old_interp(:,{-30:30},:)
CLDHGH_new_tropic = CLDHGH_new_interp(:,{-30:30},:)


;=======change from multi-dimensions to one-dimension
OMEGA_obs_oned = ndtooned(OMEGA_obs_500_tropic)
OMEGA_old_oned = ndtooned(OMEGA_old_500_tropic)
OMEGA_new_oned = ndtooned(OMEGA_new_500_tropic)

SWCF_obs_oned = ndtooned(SWCF_obs_tropic)
SWCF_old_oned = ndtooned(SWCF_old_tropic)
SWCF_new_oned = ndtooned(SWCF_new_tropic)

LWCF_obs_oned = ndtooned(LWCF_obs_tropic)
LWCF_old_oned = ndtooned(LWCF_old_tropic)
LWCF_new_oned = ndtooned(LWCF_new_tropic)

CLDLOW_obs_oned = ndtooned(CLDLOW_obs_tropic)
CLDLOW_old_oned = ndtooned(CLDLOW_old_tropic)
CLDLOW_new_oned = ndtooned(CLDLOW_new_tropic)

CLDMED_obs_oned = ndtooned(CLDMED_obs_tropic)
CLDMED_old_oned = ndtooned(CLDMED_old_tropic)
CLDMED_new_oned = ndtooned(CLDMED_new_tropic)

CLDHGH_obs_oned = ndtooned(CLDHGH_obs_tropic)
CLDHGH_old_oned = ndtooned(CLDHGH_old_tropic)
CLDHGH_new_oned = ndtooned(CLDHGH_new_tropic)

;========calculate the PDF of omega
ap = pdfx(OMEGA_old_oned, 100, False)
bp = pdfx(OMEGA_new_oned, 100, False)
cp = pdfx(OMEGA_obs_oned, 100, False)

nBin = ap@nbins
nVar = 3

print(ap@bin_spacing)
print(bp@bin_spacing)
print(cp@bin_spacing)

total_num = dimsizes(SWCF_old_oned)

;==========according to the omega bins to caculate the composition of others
;==========***_dis (nline,total_num,nBin)
SWCF_dis = new((/nVar,total_num,nBin/),float)
LWCF_dis = new((/nVar,total_num,nBin/),float)
CLDLOW_dis = new((/nVar,total_num,nBin/),float)
CLDMED_dis = new((/nVar,total_num,nBin/),float)
CLDHGH_dis = new((/nVar,total_num,nBin/),float)

SWCF_dis(0,:,:) = discretize(OMEGA_old_oned,SWCF_old_oned,nBin,total_num)
SWCF_dis(1,:,:) = discretize(OMEGA_new_oned,SWCF_new_oned,nBin,total_num)
SWCF_dis(2,:,:) = discretize(OMEGA_obs_oned,SWCF_obs_oned,nBin,total_num)

LWCF_dis(0,:,:) = discretize(OMEGA_old_oned,LWCF_old_oned,nBin,total_num)
LWCF_dis(1,:,:) = discretize(OMEGA_new_oned,LWCF_new_oned,nBin,total_num)
LWCF_dis(2,:,:) = discretize(OMEGA_obs_oned,LWCF_obs_oned,nBin,total_num)

CLDLOW_dis(0,:,:) = discretize(OMEGA_old_oned,CLDLOW_old_oned,nBin,total_num)
CLDLOW_dis(1,:,:) = discretize(OMEGA_new_oned,CLDLOW_new_oned,nBin,total_num)
CLDLOW_dis(2,:,:) = discretize(OMEGA_obs_oned,CLDLOW_obs_oned,nBin,total_num)

CLDLOW_dis@_FillValue = -1000.

CLDMED_dis(0,:,:) = discretize(OMEGA_old_oned,CLDMED_old_oned,nBin,total_num)
CLDMED_dis(1,:,:) = discretize(OMEGA_new_oned,CLDMED_new_oned,nBin,total_num)
CLDMED_dis(2,:,:) = discretize(OMEGA_obs_oned,CLDMED_obs_oned,nBin,total_num)

CLDHGH_dis(0,:,:) = discretize(OMEGA_old_oned,CLDHGH_old_oned,nBin,total_num)
CLDHGH_dis(1,:,:) = discretize(OMEGA_new_oned,CLDHGH_new_oned,nBin,total_num)
CLDHGH_dis(2,:,:) = discretize(OMEGA_obs_oned,CLDHGH_obs_oned,nBin,total_num)

;=========calculate mean and standard deviation
;=========0: average mean; 1: standard deviation

SWCF_final = new((/2,nVar,nBin/),float)
LWCF_final = new((/2,nVar,nBin/),float)
CLDLOW_final = new((/2,nVar,nBin/),float)
CLDMED_final = new((/2,nVar,nBin/),float)
CLDHGH_final = new((/2,nVar,nBin/),float)

SWCF_final = ave_std(SWCF_dis,nVar,total_num,nBin)
LWCF_final = ave_std(LWCF_dis,nVar,total_num,nBin)
CLDLOW_final = ave_std(CLDLOW_dis,nVar,total_num,nBin)
CLDMED_final = ave_std(CLDMED_dis,nVar,total_num,nBin)
CLDHGH_final = ave_std(CLDHGH_dis,nVar,total_num,nBin)

;=================

xx = new((/nVar,nBin/),typeof(ap))
xx(0,:) = ap@bin_center
xx(1,:) = bp@bin_center
xx(2,:) = cp@bin_center

yy = new((/nVar,nBin/),typeof(ap))
yy(0,:) = (/ap/)
yy(1,:) = (/bp/)
yy(2,:) = (/cp/)

thickness = (/2.0,2.0,2.0/)
colors = (/"blue","red","black"/)
labels = (/"CAM_old","CAM_new","OBS"/)

;create plot
wks = gsn_open_wks("x11","./figure/omega-PDF-all")
plot = new(6,graphic)
plot1 = new(3,graphic)
plot2 = new(3,graphic)


res = True
res@xyLineThicknesses = thickness
res@xyLineColors = colors

res@gsnDraw = False
res@gsnFrame = False

res@pmLegendDisplayMode    = "Always"            ; turn on legend
res@pmLegendSide           = "Top"               ; Change location of 
res@pmLegendParallelPosF   = .85                 ; move units right
res@pmLegendOrthogonalPosF = -0.4                ; move units down
res@pmLegendWidthF         = 0.125               ; Change width and
res@pmLegendHeightF        = 0.15                ; height of legend.
res@lgPerimOn              = True                ; turn off/on box around
res@lgLabelFontHeightF     = .015                ; label font height
res@xyExplicitLegendLabels = labels			     ; create explicit labels

res@trXMaxF = 90.0
res@trXMinF = -90.0

res@xyLineThicknesses = (/3.0,3.0,3.0/)
res@tiXAxisString = "omega500 (hPa/day)"

res@tiYAxisString = "Normalized PDF of Omega (hPa/day)"
plot1(0) = gsn_csm_xy(wks,xx,yy,res)

;============draw other variables according to the omega bins

res2 = True
res2@gsnFrame = False
res2@gsnDraw = False
res2@trXMaxF = 90.0
res2@trXMinF = -90.0

res2@xyLineThicknesses = (/3.0,3.0,3.0/)

res2@tiYAxisString = "SWCF (W/m~S~2~N~)"
plot1(1) = add_error_bar(wks,res2,xx,SWCF_final,nVar,nBin,colors)

res2@tiYAxisString = "LWCF (W/m~S~2~N~)"
plot1(2) = add_error_bar(wks,res2,xx,LWCF_final,nVar,nBin,colors)

pres = True
pres@amJust = "TopLeft"
pres@gsnPanelFigureStrings = (/"(a)","(b)","(c)"/)

;gsn_panel(wks,plot1,(/3,1/),pres)

delete(res2@tiXAxisString)
res2@tiYAxisString = "CLDLOW (%)"
plot2(0) = add_error_bar(wks,res2,xx,CLDLOW_final,nVar,nBin,colors)

res2@tiYAxisString = "CLDMED (%)"
plot2(1) = add_error_bar(wks,res2,xx,CLDMED_final,nVar,nBin,colors)

res2@tiXAxisString = "omega500 (hPa/day)"
res2@tiYAxisString = "CLDHGH (%)"
plot2(2) = add_error_bar(wks,res2,xx,CLDHGH_final,nVar,nBin,colors)

pres@amJust = "TopRight"
pres@gsnPanelFigureStrings = (/"(d)","(e)","(f)"/)
;gsn_panel(wks,plot2,(/3,1/),pres)

pres2 = True
pres2@gsnPanelYWhiteSpacePercent = 5.0
pres2@gsnPanelXWhiteSpacePercent = 5.0

plot(0) = plot1(0)
plot(1) = plot2(0)
plot(2) = plot1(1)
plot(3) = plot2(1)
plot(4) = plot1(2)
plot(5) = plot2(2)

gsn_panel(wks,plot,(/3,2/),pres2)


end
