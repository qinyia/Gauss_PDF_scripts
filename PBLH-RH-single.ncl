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

;==========read data and calculate RH and PBLH
fdir = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/"

RELHUM_old = read_RELHUM(fdir,"F_2000_f09f09_MG1.5")
RELHUM_new = read_RELHUM(fdir,"new-cldfrac14-1d")

RELHUM_old_1000 = RELHUM_old(:,29,:,:)
RELHUM_new_1000 = RELHUM_new(:,29,:,:)

CLDLOW_old = read_CLDLOW(fdir,"F_2000_f09f09_MG1.5")
CLDLOW_new = read_CLDLOW(fdir,"new-cldfrac14-1d")

CLDLOW_old = CLDLOW_old*100.
CLDLOW_new = CLDLOW_new*100.

PBLH_old = read_PBLH(fdir,"F_2000_f09f09_MG1.5")
PBLH_new = read_PBLH(fdir,"new-cldfrac14-1d")

PBLH_old = PBLH_old/1000.
PBLH_new = PBLH_new/1000.


a = addfile(fdir+"F_2000_f09f09_MG1.5/atm/hist/F_2000_f09f09_MG1.5.cam.h0.0002-01.nc","r")
gw1 = a->gw


;==========Area Mean
;===== Four areas
;===Californian (20–30N, 120–130W)
RELHUM_old_Cal = wgt_areaave(RELHUM_old_1000(:,{20:30},{230:240}),gw1({20:30}),1.0,1)
RELHUM_new_Cal = wgt_areaave(RELHUM_new_1000(:,{20:30},{230:240}),gw1({20:30}),1.0,1)

PBLH_old_Cal = wgt_areaave(PBLH_old(:,{20:30},{230:240}),gw1({20:30}),1.0,1)
PBLH_new_Cal = wgt_areaave(PBLH_new(:,{20:30},{230:240}),gw1({20:30}),1.0,1)

CLDLOW_old_Cal = wgt_areaave(CLDLOW_old(:,{20:30},{230:240}),gw1({20:30}),1.0,1)
CLDLOW_new_Cal = wgt_areaave(CLDLOW_new(:,{20:30},{230:240}),gw1({20:30}),1.0,1)

;===Peruvian    (10–20S, 80–90W)
RELHUM_old_Per = wgt_areaave(RELHUM_old_1000(:,{-20:-10},{270:280}),gw1({-20:-10}),1.0,1)
RELHUM_new_Per = wgt_areaave(RELHUM_new_1000(:,{-20:-10},{270:280}),gw1({-20:-10}),1.0,1)

PBLH_old_Per = wgt_areaave(PBLH_old(:,{-20:-10},{270:280}),gw1({-20:-10}),1.0,1)
PBLH_new_Per = wgt_areaave(PBLH_new(:,{-20:-10},{270:280}),gw1({-20:-10}),1.0,1)

CLDLOW_old_Per = wgt_areaave(CLDLOW_old(:,{-20:-10},{270:280}),gw1({-20:-10}),1.0,1)
CLDLOW_new_Per = wgt_areaave(CLDLOW_new(:,{-20:-10},{270:280}),gw1({-20:-10}),1.0,1)

;===Namibian    (10–20S, 0 –10E)
RELHUM_old_Nam = wgt_areaave(RELHUM_old_1000(:,{-20:-10},{0:10}),gw1({-20:-10}),1.0,1)
RELHUM_new_Nam = wgt_areaave(RELHUM_new_1000(:,{-20:-10},{0:10}),gw1({-20:-10}),1.0,1)

PBLH_old_Nam = wgt_areaave(PBLH_old(:,{-20:-10},{0:10}),gw1({-20:-10}),1.0,1)
PBLH_new_Nam = wgt_areaave(PBLH_new(:,{-20:-10},{0:10}),gw1({-20:-10}),1.0,1)

CLDLOW_old_Nam = wgt_areaave(CLDLOW_old(:,{-20:-10},{0:10}),gw1({-20:-10}),1.0,1)
CLDLOW_new_Nam = wgt_areaave(CLDLOW_new(:,{-20:-10},{0:10}),gw1({-20:-10}),1.0,1)


;===Australian  (25–35S, 95–105E)
RELHUM_old_Aus = wgt_areaave(RELHUM_old_1000(:,{-35:-25},{255:265}),gw1({-35:-25}),1.0,1)
RELHUM_new_Aus = wgt_areaave(RELHUM_new_1000(:,{-35:-25},{255:265}),gw1({-35:-25}),1.0,1)

PBLH_old_Aus = wgt_areaave(PBLH_old(:,{-35:-25},{255:265}),gw1({-35:-25}),1.0,1)
PBLH_new_Aus = wgt_areaave(PBLH_new(:,{-35:-25},{255:265}),gw1({-35:-25}),1.0,1)

CLDLOW_old_Aus = wgt_areaave(CLDLOW_old(:,{-35:-25},{255:265}),gw1({-35:-25}),1.0,1)
CLDLOW_new_Aus = wgt_areaave(CLDLOW_new(:,{-35:-25},{255:265}),gw1({-35:-25}),1.0,1)


;===Canarian    (15–25N, 25–35W)
RELHUM_old_Can = wgt_areaave(RELHUM_old_1000(:,{15:25},{325:335}),gw1({15:25}),1.0,1)
RELHUM_new_Can = wgt_areaave(RELHUM_new_1000(:,{15:25},{325:335}),gw1({15:25}),1.0,1)

PBLH_old_Can = wgt_areaave(PBLH_old(:,{15:25},{325:335}),gw1({15:25}),1.0,1)
PBLH_new_Can = wgt_areaave(PBLH_new(:,{15:25},{325:335}),gw1({15:25}),1.0,1)

CLDLOW_old_Can = wgt_areaave(CLDLOW_old(:,{15:25},{325:335}),gw1({15:25}),1.0,1)
CLDLOW_new_Can = wgt_areaave(CLDLOW_new(:,{15:25},{325:335}),gw1({15:25}),1.0,1)


total_num = dimsizes(CLDLOW_old_Cal)
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
wks = gsn_open_wks("pdf","./figure/PBLH-RH-single")

plot = new(10,graphic)

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
res@tiMainString = "CAM_old Californian"
plot(0) = add_PBLH_RH(wks,res,PBLH_old_Cal,RELHUM_old_Cal,CLDLOW_old_Cal,total_num,levels,nlevels,colors,markers,labels)
delete(res@tiYAxisString)
res@tiMainString = "CAM_old Peruvian"
plot(1) = add_PBLH_RH(wks,res,PBLH_old_Per,RELHUM_old_Per,CLDLOW_old_Per,total_num,levels,nlevels,colors,markers,labels)
res@tiMainString = "CAM_old Namibian"
plot(2) = add_PBLH_RH(wks,res,PBLH_old_Nam,RELHUM_old_Nam,CLDLOW_old_Nam,total_num,levels,nlevels,colors,markers,labels)
res@tiMainString = "CAM_old Australian"
plot(3) = add_PBLH_RH(wks,res,PBLH_old_Aus,RELHUM_old_Aus,CLDLOW_old_Aus,total_num,levels,nlevels,colors,markers,labels)
res@tiMainString = "CAM_old Canarian"
plot(4) = add_PBLH_RH(wks,res,PBLH_old_Can,RELHUM_old_Can,CLDLOW_old_Can,total_num,levels,nlevels,colors,markers,labels)

res@tiXAxisString = "PBLH (km)"
res@tiYAxisString = "Relative Humidity (%)"
res@tiMainString = "CAM_new Californian"
plot(5) = add_PBLH_RH(wks,res,PBLH_new_Cal,RELHUM_new_Cal,CLDLOW_new_Cal,total_num,levels,nlevels,colors,markers,labels)
delete(res@tiYAxisString)
res@tiMainString = "CAM_new Peruvian"
plot(6) = add_PBLH_RH(wks,res,PBLH_new_Per,RELHUM_new_Per,CLDLOW_new_Per,total_num,levels,nlevels,colors,markers,labels)
res@tiMainString = "CAM_new Namibian"
plot(7) = add_PBLH_RH(wks,res,PBLH_new_Nam,RELHUM_new_Nam,CLDLOW_new_Nam,total_num,levels,nlevels,colors,markers,labels)
res@tiMainString = "CAM_new Australian"
plot(8) = add_PBLH_RH(wks,res,PBLH_new_Aus,RELHUM_new_Aus,CLDLOW_new_Aus,total_num,levels,nlevels,colors,markers,labels)
res@tiMainString = "CAM_new Canarian"
plot(9) = add_PBLH_RH(wks,res,PBLH_new_Can,RELHUM_new_Can,CLDLOW_new_Can,total_num,levels,nlevels,colors,markers,labels)

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

gsn_panel(wks,plot,(/2,5/),False)


end
