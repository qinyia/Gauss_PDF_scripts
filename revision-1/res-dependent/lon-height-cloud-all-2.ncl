load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision/ncl-function/functions_regrid.ncl"

begin

fdir1 = "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision/data/output/"
fdir2 = "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision/data/output/"

fname1 = "new-cldfrac16-1d-MG15-revise-2-COSP"
fname2 = "FC5_f19f19_MG15_mac3_cosp"

append = ".cam.h0.ANN.nc"

f1 = addfile(fdir1+fname1+"/"+fname1+append,"r")
f2 = addfile(fdir2+fname2+"/"+fname2+append,"r")

lon_1deg = f1->lon
lat_1deg = f1->lat
lev = f1->lev
cosp_ht = f1->cosp_ht ; units: m

lon_2deg = f2->lon
lat_2deg = f2->lat

cld_1deg = f1->CLD_CAL(0,:,:,:)
cld_2deg = f2->CLD_CAL(0,:,:,:)

lat_regrid = lat_2deg
lon_regrid = lon_2deg

cld_regrid = lev_lat_lon_regrid_2var(cld_1deg,cosp_ht,lat_1deg,lon_1deg,cld_2deg,lat_2deg,lon_2deg,lon_regrid,lat_regrid)
printVarSummary(cld_regrid)

cld_1deg_regrid = cld_regrid(0,:,:,:)
cld_2deg_regrid = cld_regrid(1,:,:,:)


cld_diff = cld_regrid(0,:,:,:)
cld_diff = (/cld_regrid(0,:,:,:)-cld_regrid(1,:,:,:) /) ; 1deg-2deg


;create plot
wks = gsn_open_wks("x11","../figure/lon-height-res-dependent-cld")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
plot = new(9,graphic)

cmap1 = read_colormap_file("WhiteBlueGreenYellowRed")

;cmap2 = read_colormap_file("blue-white-red_40colors")
cmap2 = read_colormap_file("BlueWhiteOrangeRed")



res = True
res@gsnDraw = False
res@gsnFrame = False
;res@trYReverse = True

res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnFillOn = True
;res@cnlbLabelStride = 4
;res@lbLabelBarOn = False

res@cnFillPalette        = cmap1(:150,:)        ; subset the color map

res@lbBoxLinesOn         = False     ; Turn off labelbar box lines

res@cnInfoLabelOn = False

;res@trYMinF = 700.
;res@trYMaxF = lev(29)

res@trYMaxF = 3000.

;res@gsnYAxisIrregular2Linear = True
;res@tiYAxisString = "Pressure(hPa)"
res@tiYAxisString = "Height (m)"

res@tmXBTickSpacingF= 10.

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 5. 
res@cnMaxLevelValF = 50.
res@cnLevelSpacingF = 5.

;res@gsnRightString = "%"
res@gsnRightString = ""

res2 = res
delete(res2@cnFillPalette)
res2@cnFillPalette = cmap2(:,:)


res2@cnLevelSelectionMode = "ManualLevels"
res2@cnMinLevelValF = -10.
res2@cnMaxLevelValF = 10.
res2@cnLevelSpacingF = 2.


;=======================================
lres = True
lres@gsnDraw = False
lres@gsnFrame = False
lres@xyLineThicknessF = 4.0 
lres@gsnLeftString = ""
lres@gsnRightString = ""

res@gsnLeftStringFontHeightF = 0.03

res@gsnLeftString = "(a)1deg-Off Peru"
plot(0) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_1deg_regrid(:,{-20:-10},{260:290}),1),res)

res@gsnLeftString = "(b)2deg-off Peru"
plot(1) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_2deg_regrid(:,{-20:-10},{260:290}),1),res)

res2@gsnLeftString = "(c)Diff-off Peru"
plot(2) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_diff(:,{-20:-10},{260:290}),1),res2)

;==========

res@gsnLeftString = "(d) 1deg-off California"
plot(3) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_1deg_regrid(:,{20:30},{200:260}),1),res)

res@gsnLeftString = "(e) 2deg-off California"
plot(4) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_2deg_regrid(:,{20:30},{200:260}),1),res)

res2@gsnLeftString = "(f) Diff-off California"
plot(5) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_diff(:,{20:30},{200:260}),1),res2)

;=============

res@gsnLeftString = "(g) 1deg-off Namibia"
plot(6) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_1deg_regrid(:,{-20:-10},{300:360}),1),res)

res@gsnLeftString = "(h) 2deg-off Namibia"
plot(7) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_2deg_regrid(:,{-20:-10},{300:360}),1),res)

res2@gsnLeftString = "(i) Diff-off Namibia"
plot(8) = gsn_csm_contour(wks, dim_avg_n_Wrap(cld_diff(:,{-20:-10},{300:360}),1),res2)



resPanel                 = True                 ; panel mods desired
;resPanel@gsnPanelLabelBar= True                 ; label bar on panel
;resPanel@gsnMaximize     = True                 ; fill up the page
gsn_panel(wks,plot,(/3,3/),resPanel)

end
