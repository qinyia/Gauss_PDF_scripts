load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "./functions_discretize.ncl"
load "./functions_read_file.ncl"
load "./functions_calculate.ncl"
load "./functions_plot.ncl"


;======Main Codes
begin

;=========read observation
fdir1 = "/home/lyl/WORK3/qinyi/data/ERAI/"
fdir2 = "/home/lyl/WORK3/qinyi/data/ISCCP/ftp.climserv.ipsl.polytechnique.fr/cfmip/ISCCP/old_ISCCP/"
fn1 = "RH_200001-201012_1deg.nc"
fn2 = "PBLH_200001-201012_1deg.nc"
fn3 = "ISCCP_totlowmidhgh_cldcover_198307-200806-unit.nc"

f1 = addfile(fdir1+fn1,"r")
f2 = addfile(fdir1+fn2,"r")
f3 = addfile(fdir2+fn3,"r")

RELHUM_obs = short2flt(f1->r(24:,:,:,:))
PBLH_obs = short2flt(f2->blh(24:,:,:))
CLDLOW_obs = f3->lowcld(192:,:,:)

RELHUM_obs_1000 = RELHUM_obs(:,{1000},:,:)
PBLH_obs = PBLH_obs/1000.

lat1 = f1->latitude
lat2 = f2->latitude
lat3 = f3->lat

nlat1 = dimsizes(lat1)
nlat2 = dimsizes(lat2)
nlat3 = dimsizes(lat3)

rad = 4.0*atan(1.0)/180.0
clat1 = cos(lat1*rad)
clat2 = cos(lat2*rad)
clat3 = cos(lat3*rad)
copy_VarCoords(lat1,clat1)
copy_VarCoords(lat2,clat2)
copy_VarCoords(lat3,clat3)

;==========Area Mean
;===== Four areas
;===Californian (20–30N, 120–130W)
RELHUM_obs_Cal = wgt_areaave(RELHUM_obs_1000(:,{20:30},{230:240}),clat1({20:30}),1.0,1)

PBLH_obs_Cal = wgt_areaave(PBLH_obs(:,{20:30},{230:240}),clat2({20:30}),1.0,1)

CLDLOW_obs_Cal = wgt_areaave(CLDLOW_obs(:,{20:30},{-130:-120}),clat3({20:30}),1.0,1)



;===Peruvian    (10–20S, 80–90W)
RELHUM_obs_Per = wgt_areaave(RELHUM_obs_1000(:,{-20:-10},{270:280}),clat1({-20:-10}),1.0,1)

PBLH_obs_Per = wgt_areaave(PBLH_obs(:,{-20:-10},{270:280}),clat2({-20:-10}),1.0,1)

CLDLOW_obs_Per = wgt_areaave(CLDLOW_obs(:,{-20:-10},{-90:-80}),clat3({-20:-10}),1.0,1)

;===Namibian    (10–20S, 0 –10E)
RELHUM_obs_Nam = wgt_areaave(RELHUM_obs_1000(:,{-20:-10},{0:10}),clat1({-20:-10}),1.0,1)

PBLH_obs_Nam = wgt_areaave(PBLH_obs(:,{-20:-10},{0:10}),clat2({-20:-10}),1.0,1)

CLDLOW_obs_Nam = wgt_areaave(CLDLOW_obs(:,{-20:-10},{0:10}),clat3({-20:-10}),1.0,1)


;===Australian  (25–35S, 95–105E)
RELHUM_obs_Aus = wgt_areaave(RELHUM_obs_1000(:,{-35:-25},{95:105}),clat1({-35:-25}),1.0,1)

PBLH_obs_Aus = wgt_areaave(PBLH_obs(:,{-35:-25},{95:105}),clat2({-35:-25}),1.0,1)

CLDLOW_obs_Aus = wgt_areaave(CLDLOW_obs(:,{-35:-25},{95:105}),clat3({-35:-25}),1.0,1)


;===Canarian    (15–25N, 25–35W)
RELHUM_obs_Can = wgt_areaave(RELHUM_obs_1000(:,{15:25},{325:335}),clat1({15:25}),1.0,1)

PBLH_obs_Can = wgt_areaave(PBLH_obs(:,{15:25},{325:335}),clat2({15:25}),1.0,1)

CLDLOW_obs_Can = wgt_areaave(CLDLOW_obs(:,{15:25},{-35:-25}),clat3({15:25}),1.0,1)


total_num = dimsizes(CLDLOW_obs_Cal)
;=====use to specify the colors for different cloud fraction regimes
levels = ispan(0,100,10)

nlevels = dimsizes(levels)

labels = new(nlevels,string)
labels = ""
labels(0::1) = "" + ispan(0,100,10)

;======span the default 256 color map for the markers
nstep = 256/nlevels
colors = ispan(2,256,nstep)

markers = new((/total_num/),float)
do i=0,total_num-1
	markers(i) = 16
end do


;==========================================================
;===========================================================
wks = gsn_open_wks("x11","./figure/PBLH-RH-single")

plot = new(5,graphic)

res = True

;res@gsnMaximize = True
res@gsnDraw = False
res@gsnFrame = False

res@trXMinF = 0.
res@trXMaxF = 1.2
res@trYMinF = 60.
res@trYMaxF = 100.

res@xyMarkLineMode = "Markers"
;res@xyMarkerSizeF = 0.03
res@xyMarkerThicknessF = 3.0
res@xyMarkers = markers
res@xyMarkerColor = "White"

res@tiYAxisString = "Relative Humidity (%)"
res@tiMainString = "CAM_obs Californian"
plot(0) = add_PBLH_RH(wks,res,PBLH_obs_Cal,RELHUM_obs_Cal,CLDLOW_obs_Cal,total_num,levels,nlevels,colors,markers,labels)
delete(res@tiYAxisString)
res@tiMainString = "CAM_obs Peruvian"
plot(1) = add_PBLH_RH(wks,res,PBLH_obs_Per,RELHUM_obs_Per,CLDLOW_obs_Per,total_num,levels,nlevels,colors,markers,labels)
res@tiMainString = "CAM_obs Namibian"
plot(2) = add_PBLH_RH(wks,res,PBLH_obs_Nam,RELHUM_obs_Nam,CLDLOW_obs_Nam,total_num,levels,nlevels,colors,markers,labels)
res@tiMainString = "CAM_obs Australian"
plot(3) = add_PBLH_RH(wks,res,PBLH_obs_Aus,RELHUM_obs_Aus,CLDLOW_obs_Aus,total_num,levels,nlevels,colors,markers,labels)
res@tiMainString = "CAM_obs Canarian"
plot(4) = add_PBLH_RH(wks,res,PBLH_obs_Can,RELHUM_obs_Can,CLDLOW_obs_Can,total_num,levels,nlevels,colors,markers,labels)

;=====add custom labelbar
lbres = True
lbres@lbPerimOn = False
lbres@lbOrientation = "Horizontal"
lbres@vpWidthF = 0.7
lbres@vpHeightF = 0.05
lbres@lbLabelFontHeightF = 0.012
lbres@lbLabelAlignment = "InteriorEdges"
lbres@lbMonoFillPattern = True
lbres@lbFillColors = colors


;labelbar = attach_labelbar(wks,plot,labels,colors)

;drawNDCGrid(wks)

gsn_labelbar_ndc(wks,nlevels+1,labels,0.15,0.1,lbres)

gsn_panel(wks,plot,(/1,5/),False)


end
