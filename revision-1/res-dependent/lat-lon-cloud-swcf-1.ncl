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
fdir = "/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision-1/data/output/"
fdir_append = ""

fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"

fname1 = "new-cldfrac16-1d-MG15-revise-2-COSP"
fname2 = "FC5_f19f19_MG15_mac3_cosp"

append = ".cam.h0.ANN.nc"


f1 = addfile(fdir+fname1+"/"+fname1+append,"r")
f2 = addfile(fdir+fname2+"/"+fname2+append,"r")


CLDLOW_1deg = f1->CLDLOW(0,:,:)
CLDLOW_2deg = f2->CLDLOW(0,:,:)

CLDLOW_1deg = CLDLOW_1deg*100.
CLDLOW_2deg = CLDLOW_2deg*100.

SWCF_1deg = f1->SWCF(0,:,:)
SWCF_2deg = f2->SWCF(0,:,:)



lat1 = f1->lat
lon1 = f1->lon
lat2 = f2->lat
lon2 = f2->lon


lat_regrid = lat2
lon_regrid = lon2
plat = dimsizes(lat_regrid)
plon = dimsizes(lon_regrid)

CLDLOW_regrid = new((/2,plat,plon/),"float")

; interpolate data
CLDLOW_regrid(0,:,:) = linint2 (lon1,lat1,CLDLOW_1deg,True,lon_regrid,lat_regrid,0) ; 1degree data
CLDLOW_regrid(1,:,:) = linint2 (lon2,lat2,CLDLOW_2deg,True,lon_regrid,lat_regrid,0) ; 2degree data

CLDLOW_regrid!0 = "line"
CLDLOW_regrid&line = (/0,1/)
CLDLOW_regrid!1 = "lat"
CLDLOW_regrid&lat = lat_regrid
CLDLOW_regrid!2 = "lon"
CLDLOW_regrid&lon = lon_regrid

CLDLOWdiff = CLDLOW_regrid(0,:,:)
CLDLOWdiff = (/CLDLOW_regrid(0,:,:)-CLDLOW_regrid(1,:,:) /) ; 1deg-2deg

printVarSummary(CLDLOWdiff)

;;;;SWCF
SWCF_regrid = new((/2,plat,plon/),"float")

; interpolate data
SWCF_regrid(0,:,:) = linint2 (lon1,lat1,SWCF_1deg,True,lon_regrid,lat_regrid,0)   
SWCF_regrid(1,:,:) = linint2 (lon2,lat2,SWCF_2deg,True,lon_regrid,lat_regrid,0)   

SWCF_regrid!0 = "line"
SWCF_regrid&line = (/0,1/)
SWCF_regrid!1 = "lat"
SWCF_regrid&lat = lat_regrid
SWCF_regrid!2 = "lon"
SWCF_regrid&lon = lon_regrid

SWCFdiff = SWCF_regrid(0,:,:)
SWCFdiff = (/SWCF_regrid(0,:,:)-SWCF_regrid(1,:,:) /) ; 1deg-2deg



;************************create plot***************
wks = gsn_open_wks("eps","../figure/fig14-lat-lon-res-dependent-cloud-swcf-eps")

plot = new(6,graphic)

cmap1 = read_colormap_file("WhiteBlueGreenYellowRed")

cmap2 = read_colormap_file("blue-white-red_40colors")
;cmap2 = read_colormap_file("BlueWhiteOrangeRed")


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

res@gsnRightString = "CLDLOW(%)"

res@gsnLeftStringFontHeightF =  0.025
res@gsnRightStringFontHeightF = 0.025

res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 100.
res@cnMinLevelValF       = 5.
res@cnLevelSpacingF      = 5.

res@gsnLeftString = "(a) PDF-2deg"
plot(0) = gsn_csm_contour_map_ce (wks,CLDLOW_regrid(1,:,:),res)

res2 = res
delete(res2@cnFillPalette)
res2@cnFillPalette = cmap2(:,:)

res2@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res2@cnMaxLevelValF       = 20.
res2@cnMinLevelValF       = -20.
res2@cnLevelSpacingF      = 2.

res2@gsnLeftString = "(b) 1deg-2deg"
plot(1) = gsn_csm_contour_map_ce (wks,CLDLOWdiff,res2)

;;;; SWCF

res@gsnRightString = "SWCF(W/m~S~2~N~)"
res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res@cnMaxLevelValF       = 0.
res@cnMinLevelValF       = -160.
res@cnLevelSpacingF      = 15.

res@gsnLeftString = "(c) PDF-2deg"
plot(2) = gsn_csm_contour_map_ce (wks,SWCF_regrid(1,:,:),res)

res2 = res
delete(res2@cnFillPalette)
res2@cnFillPalette = cmap2(:,:)

res2@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
res2@cnMaxLevelValF       = 20.
res2@cnMinLevelValF       = -20.
res2@cnLevelSpacingF      = 2.

res2@gsnLeftString = "(d) 1deg-2deg"
plot(3) = gsn_csm_contour_map_ce (wks,SWCFdiff,res2)

;;;; panel finally
pres1 = True

gsn_panel(wks,plot,(/2,2/),pres1)


end
