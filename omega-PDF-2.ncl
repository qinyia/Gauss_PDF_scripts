load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_read_file.ncl"
load "./functions_calculate.ncl"
load "./functions_plot.ncl"
load "./functions_discretize.ncl"


begin

fdir = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/"

OMEGA_old = read_omega(fdir,"F_MG1.5_f09f09")
OMEGA_new = read_omega(fdir,"new-cldfrac7-1d")
OMEGA_old_500 = OMEGA_old(:,{500},{-30:30},:)
OMEGA_new_500 = OMEGA_new(:,{500},{-30:30},:)

;=======change unit from Pa/s to hPa/day
OMEGA_old_500 = OMEGA_old_500*24*3600/100.
OMEGA_new_500 = OMEGA_new_500*24*3600/100.


SWCF_old = read_SWCF(fdir,"F_MG1.5_f09f09")
SWCF_new = read_SWCF(fdir,"new-cldfrac7-1d")
SWCF_old_500 = SWCF_old(:,{-30:30},:)
SWCF_new_500 = SWCF_new(:,{-30:30},:)

LWCF_old = read_LWCF(fdir,"F_MG1.5_f09f09")
LWCF_new = read_LWCF(fdir,"new-cldfrac7-1d")
LWCF_old_500 = LWCF_old(:,{-30:30},:)
LWCF_new_500 = LWCF_new(:,{-30:30},:)

CLDLOW_old = read_CLDLOW(fdir,"F_MG1.5_f09f09")
CLDLOW_new = read_CLDLOW(fdir,"new-cldfrac7-1d")
CLDLOW_old =CLDLOW_old*100.
CLDLOW_new = CLDLOW_new*100.
CLDLOW_old_500 = CLDLOW_old(:,{-30:30},:)
CLDLOW_new_500 = CLDLOW_new(:,{-30:30},:)

CLDMED_old = read_CLDMED(fdir,"F_MG1.5_f09f09")
CLDMED_new = read_CLDMED(fdir,"new-cldfrac7-1d")
CLDMED_old = CLDMED_old*100.
CLDMED_new = CLDMED_new*100.
CLDMED_old_500 = CLDMED_old(:,{-30:30},:)
CLDMED_new_500 = CLDMED_new(:,{-30:30},:)

CLDHGH_old = read_CLDHGH(fdir,"F_MG1.5_f09f09")
CLDHGH_new = read_CLDHGH(fdir,"new-cldfrac7-1d")
CLDHGH_old = CLDHGH_old*100.
CLDHGH_new = CLDHGH_new*100.
CLDHGH_old_500 = CLDHGH_old(:,{-30:30},:)
CLDHGH_new_500 = CLDHGH_new(:,{-30:30},:)


;=======change from multi-dimensions to one-dimension
OMEGA_old_oned = ndtooned(OMEGA_old_500)
OMEGA_new_oned = ndtooned(OMEGA_new_500)

SWCF_old_oned = ndtooned(SWCF_old_500)
SWCF_new_oned = ndtooned(SWCF_new_500)

LWCF_old_oned = ndtooned(LWCF_old_500)
LWCF_new_oned = ndtooned(LWCF_new_500)

CLDLOW_old_oned = ndtooned(CLDLOW_old_500)
CLDLOW_new_oned = ndtooned(CLDLOW_new_500)

CLDMED_old_oned = ndtooned(CLDMED_old_500)
CLDMED_new_oned = ndtooned(CLDMED_new_500)

CLDHGH_old_oned = ndtooned(CLDHGH_old_500)
CLDHGH_new_oned = ndtooned(CLDHGH_new_500)

;========calculate the PDF of omega
ap = pdfx(OMEGA_old_oned, 100, False)
bp = pdfx(OMEGA_new_oned, 100, False)

nBin = ap@nbins
nVar = 2

print(ap@bin_spacing)
print(bp@bin_spacing)

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

LWCF_dis(0,:,:) = discretize(OMEGA_old_oned,LWCF_old_oned,nBin,total_num)
LWCF_dis(1,:,:) = discretize(OMEGA_new_oned,LWCF_new_oned,nBin,total_num)

CLDLOW_dis(0,:,:) = discretize(OMEGA_old_oned,CLDLOW_old_oned,nBin,total_num)
CLDLOW_dis(1,:,:) = discretize(OMEGA_new_oned,CLDLOW_new_oned,nBin,total_num)

CLDMED_dis(0,:,:) = discretize(OMEGA_old_oned,CLDMED_old_oned,nBin,total_num)
CLDMED_dis(1,:,:) = discretize(OMEGA_new_oned,CLDMED_new_oned,nBin,total_num)

CLDHGH_dis(0,:,:) = discretize(OMEGA_old_oned,CLDHGH_old_oned,nBin,total_num)
CLDHGH_dis(1,:,:) = discretize(OMEGA_new_oned,CLDHGH_new_oned,nBin,total_num)

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


yy = new((/nVar,nBin/),typeof(ap))
yy(0,:) = (/ap/)
yy(1,:) = (/bp/)

thickness = (/2.0,2.0/)
colors = (/"blue","red"/)
labels = (/"CAM_old","CAM_new"/)

;create plot
wks = gsn_open_wks("x11","./figure/omega-PDF-2")
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
