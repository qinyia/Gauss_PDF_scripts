load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 


load "./functions_lat_interpolate.ncl"
load "./functions_getvar.ncl"

begin


ss = systemfunc("rm ./tmp*")

ncdf_mode = "create"

;***************file 1********************
fdir = "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision/data/output/"
fdir_append = ""

fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"

fname1 = "new-cldfrac16-1d-MG15-revise-2-COSP"

fname2 = "FC5_f19f19_MG15_mac3_cosp"

fname3 = "NVAP_ANN_climo.nc"

append = ".cam.h0.ANN.nc"


f1 = addfile(fdir+fname1+"/"+fname1+append,"r")
f2 = addfile(fdir+fname2+"/"+fname2+append,"r")
f3 = addfile(fdir_obs+fname3,"r")


TGCLDLWP_def = get_TGCLDLWP(f1)
TGCLDLWP_new = get_TGCLDLWP(f2)
TGCLDLWP_obs = f3->TGCLDLWP_OCEAN(0,:,:)

lat1 = f1->lat
lon1 = f1->lon
lat2 = f2->lat
lon2 = f2->lon
lat3 = f3->lat
lon3 = f3->lon

; interpolate data
TGCLDLWP_interp = lat_lon_interpolate(TGCLDLWP_def,lat1,lon1,TGCLDLWP_new,lat2,lon2,TGCLDLWP_obs,lat3,lon3)


TGCLDLWPdiff = TGCLDLWP_interp
TGCLDLWPdiff(0,:,:) = (/TGCLDLWP_interp(0,:,:)-TGCLDLWP_interp(2,:,:) /) ; def-obs
TGCLDLWPdiff(1,:,:) = (/TGCLDLWP_interp(1,:,:)-TGCLDLWP_interp(2,:,:) /) ; new-obs
TGCLDLWPdiff(2,:,:) = (/TGCLDLWP_interp(1,:,:)-TGCLDLWP_interp(0,:,:) /) ; new-def

;************************create plot***************
wks = gsn_open_wks("x11","../figure/fig7-lat-lon-LWP-ttest")
;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

plot = new(6,graphic)

;cmap1 = read_colormap_file("BlAqGrYeOrReVi200")
cmap1 = read_colormap_file("WhiteBlueGreenYellowRed")
cmap2 = read_colormap_file("BlueRed")

res                      = True               ; plot mods desired

res@gsnDraw = False
res@gsnFrame = False
 
;  res@gsnMaximize = True

res@cnFillOn             = True               ; turn on color for contours
res@cnLinesOn            = False              ; turn off contour lines
res@cnLineLabelsOn       = False              ; turn off contour line labels
res@cnFillPalette        = cmap1(:150,:)        ; subset the color map

res@mpLandFillColor      = "gray"            ; set land to be gray

res@mpCenterLonF         = 180.

res@gsnRightString = "TGCLDLWP(g/m~S~2~N~)"

res@gsnLeftStringFontHeightF =  0.025
res@gsnRightStringFontHeightF = 0.025

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 200.
res@cnMinLevelValF       = 10.
res@cnLevelSpacingF      = 10.

res@lbLabelBarOn = False
res@gsnLeftString = "(a) 1deg"
plot(0) = gsn_csm_contour_map_ce (wks,TGCLDLWP_interp(0,:,:),res)
res@gsnLeftString = "(b) 2deg"
plot(1) = gsn_csm_contour_map_ce (wks,TGCLDLWP_interp(1,:,:),res)
res@gsnLeftString = "(c) ISCCP"
plot(2) = gsn_csm_contour_map_ce (wks,TGCLDLWP_interp(2,:,:),res)

res2 = res
delete(res2@cnFillPalette)
res2@cnFillPalette = cmap2(:,:)

res2@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res2@cnMaxLevelValF       = 100.
res2@cnMinLevelValF       = -100.
res2@cnLevelSpacingF      = 10.

res2@lbLabelBarOn = False
res2@gsnLeftString = "(d) 1deg-ISCCP"
plot(3) = gsn_csm_contour_map_ce (wks,TGCLDLWPdiff(0,:,:),res2)
res2@gsnLeftString = "(e) 2deg-ISCCP"
plot(4) = gsn_csm_contour_map_ce (wks,TGCLDLWPdiff(1,:,:),res2)
res2@gsnLeftString = "(f) 1deg-2deg"
plot(5) = gsn_csm_contour_map_ce (wks,TGCLDLWPdiff(2,:,:),res2)

;;;; panel finally
pres1 = True
pres1@gsnPanelLabelBar = True
pres1@gsnFrame = False
pres1@gsnPanelTop = 0.9
pres1@gsnPanelBottom = 0.6
pres1@pmLabelBarWidthF = 0.70
pres1@pmLabelBarHeightF = 0.07
pres1@lbLabelStride = 2
pres1@pmLabelBarOrthogonalPosF = -0.015

gsn_panel(wks,plot(0:2),(/1,3/),pres1)

pres2 = True
pres2@gsnPanelLabelBar = True
pres2@gsnPanelTop = 0.6
pres2@gsnPanelBottom = 0.3
pres2@pmLabelBarWidthF = 0.70
pres2@pmLabelBarHeightF = 0.07
pres2@lbLabelStride = 2
pres2@pmLabelBarOrthogonalPosF = -0.015

gsn_panel(wks,plot(3:5),(/1,3/),pres2)


end
