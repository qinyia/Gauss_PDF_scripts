load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_read_file.ncl"
load "./functions_calculate.ncl"
load "./functions_plot.ncl"
load "./functions_discretize.ncl"
load "./functions_lat_interpolate.ncl"


begin

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

dsize = dimsizes(OMEGA_obs)
ntime = dsize(0)

;======get 500hPa variables
OMEGA_obs_500 = OMEGA_obs(:,{500},:,:)


;======interpolate
ydata = time_lat_lon_interpolate(OMEGA_obs_500(:,::-1,:),ntime,lat1,lon1,CLDLOW_obs,lat2,lon2,SWCF_obs,lat3,lon3)
OMEGA_obs_500_interp = ydata(0,:,:,:)
CLDLOW_obs_interp = ydata(1,:,:,:)
SWCF_obs_interp = ydata(2,:,:,:)

ydata = time_lat_lon_interpolate(OMEGA_obs_500(:,::-1,:),ntime,lat1,lon1,CLDMED_obs,lat2,lon2,LWCF_obs,lat3,lon3)
CLDMED_obs_interp = ydata(1,:,:,:)
LWCF_obs_interp = ydata(2,:,:,:)

ydata = time_lat_lon_interpolate(OMEGA_obs_500(:,::-1,:),ntime,lat1,lon1,CLDHGH_obs,lat2,lon2,LWCF_obs,lat3,lon3)
CLDHGH_obs_interp = ydata(1,:,:,:)


OMEGA_obs_500_tropic = OMEGA_obs_500_interp(:,{-30:30},:)

;=======change unit from Pa/s to hPa/day
OMEGA_obs_500_tropic = OMEGA_obs_500_tropic*24*3600/100.


SWCF_obs_tropic = SWCF_obs_interp(:,{-30:30},:)
LWCF_obs_tropic = LWCF_obs_interp(:,{-30:30},:)
CLDLOW_obs_tropic = CLDLOW_obs_interp(:,{-30:30},:)
CLDMED_obs_tropic = CLDMED_obs_interp(:,{-30:30},:)
CLDHGH_obs_tropic = CLDHGH_obs_interp(:,{-30:30},:)


;=======change from multi-dimensions to one-dimension
OMEGA_obs_oned = ndtooned(OMEGA_obs_500_tropic)
SWCF_obs_oned = ndtooned(SWCF_obs_tropic)
LWCF_obs_oned = ndtooned(LWCF_obs_tropic)
CLDLOW_obs_oned = ndtooned(CLDLOW_obs_tropic)
CLDMED_obs_oned = ndtooned(CLDMED_obs_tropic)
CLDHGH_obs_oned = ndtooned(CLDHGH_obs_tropic)

;========calculate the PDF of omega
ap = pdfx(OMEGA_obs_oned, 100, False)

nBin = ap@nbins
nVar = 1

print(ap@bin_spacing)

total_num = dimsizes(OMEGA_obs_oned)

;==========according to the omega bins to caculate the composition of others
;==========***_dis (nline,total_num,nBin)
SWCF_dis = new((/nVar,total_num,nBin/),float)
LWCF_dis = new((/nVar,total_num,nBin/),float)
CLDLOW_dis = new((/nVar,total_num,nBin/),float)
CLDMED_dis = new((/nVar,total_num,nBin/),float)
CLDHGH_dis = new((/nVar,total_num,nBin/),float)

SWCF_dis(0,:,:) = discretize(OMEGA_obs_oned,SWCF_obs_oned,nBin,total_num)

LWCF_dis(0,:,:) = discretize(OMEGA_obs_oned,LWCF_obs_oned,nBin,total_num)

CLDLOW_dis(0,:,:) = discretize(OMEGA_obs_oned,CLDLOW_obs_oned,nBin,total_num)

CLDMED_dis(0,:,:) = discretize(OMEGA_obs_oned,CLDMED_obs_oned,nBin,total_num)

CLDHGH_dis(0,:,:) = discretize(OMEGA_obs_oned,CLDHGH_obs_oned,nBin,total_num)


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


yy = new((/nVar,nBin/),typeof(ap))
yy(0,:) = (/ap/)

thickness = (/2.0,2.0/)
colors = (/"blue","red"/)
labels = (/"CAM_obs","CAM_new"/)

;create plot
wks = gsn_open_wks("pdf","./figure/omega-PDF-obs")
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

res@tiXAxisString = "omega500 (hPa/day)"

res@tiYAxisString = "Normalized PDF of Omega (hPa/day)"
plot1(0) = gsn_csm_xy(wks,xx,yy,res)

;============draw other variables according to the omega bins

res2 = True
res2@gsnFrame = False
res2@gsnDraw = False
res2@trXMaxF = 90.0
res2@trXMinF = -90.0

res2@tiYAxisString = "SWCF (W/m~S~2~N~)"
plot1(1) = add_error_bar(wks,res2,xx,SWCF_final,nVar,nBin,colors)

res2@tiYAxisString = "LWCF (W/m~S~2~N~)"
plot1(2) = add_error_bar(wks,res2,xx,LWCF_final,nVar,nBin,colors)

pres = True
pres@amJust = "TopLeft"
pres@gsnPanelFigureStrings = (/"(a)","(b)","(c)"/)

gsn_panel(wks,plot1,(/3,1/),pres)

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
gsn_panel(wks,plot2,(/3,1/),pres)

plot(0) = plot1(0)
plot(1) = plot2(0)
plot(2) = plot1(1)
plot(3) = plot2(1)
plot(4) = plot1(2)
plot(5) = plot2(2)

gsn_panel(wks,plot,(/3,2/),False)


end
