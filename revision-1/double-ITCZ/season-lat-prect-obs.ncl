
load "./functions_lat_interpolate.ncl"

function get_PRECT(fdir:string,fapend:string,case:string,type:string)
begin

 f_tmp     = addfile (fdir+case+fapend, "r")                         ; add file

if(type.eq."model")then

 PRECC_tmp   = f_tmp->PRECC
 PRECL_tmp   = f_tmp->PRECL

 lat = f_tmp->lat
 lon = f_tmp->lon
 time = f_tmp->time

 PRECT_tmp = PRECC_tmp
 PRECT_tmp@long_name = "total precipitation rate"
 PRECT_tmp   = PRECC_tmp+PRECL_tmp
; PRECT_tmp   = PRECC_tmp

 PRECT_tmp = PRECT_tmp*8.64e7
 PRECT_tmp@units = "mm/day"

data_out = PRECT_tmp
lat_out = lat
lon_out = lon
time_out = time
delete([/PRECC_tmp, PRECL_tmp, PRECT_tmp/])

end if

if(type.eq."obs")then
 lat = f_tmp->lat
 lon = f_tmp->lon
 time = f_tmp->time

PRECT_tmp = f_tmp->PRECT

data_out = PRECT_tmp
lat_out = lat
lon_out = lon
time_out = time

delete([/PRECT_tmp/])

end if

return ([/data_out,lat_out,lon_out,time_out/])

end 

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

begin
;*********************************************
; read in data
;*********************************************

;casename = (/"GPCP","BC5_f19g16","BC5_f19g16_mac2"/)
;casename = (/"GPCP","FC5_f09f09_MG15_COSP","new-cldfrac16-1d-MG15-revise-2-COSP"/)
;casename = (/"XIEARKIN","his_200","B1850C5_f19g16_mac2"/)
casename = (/"GPCP","his_200","B1850C5_f19g16_mac2"/)


fdir = (/"/home/share3/lyl/work3/qinyi/double-ITCZ/data/obs/", \
         "/home/share3/lyl/work3/qinyi/double-ITCZ/data/atm/", \
	 "/home/share3/lyl/work3/qinyi/double-ITCZ/data/atm/"/)

;fdir = (/"/home/share3/lyl/work3/qinyi/double-ITCZ/data/obs/", \
;         "/home/share3/lyl/work3/qinyi/double-ITCZ/data/amip/", \
;	 "/home/share3/lyl/work3/qinyi/double-ITCZ/data/amip/"/)


;fapend = (/"_ANN_climo.nc", \
;           ".cam.h0.ANN.nc", \
;	   ".cam.h0.ANN.nc" /)

fapend = (/"_MONTHS.nc", \
           ".cam.h0.MONTHS.nc", \
	   ".cam.h0.MONTHS.nc" /)


result_obs = get_PRECT(fdir(0),fapend(0),casename(0),"obs")
PRECT_obs = result_obs[0]
lat_obs   = result_obs[1]
lon_obs   = result_obs[2]
time = result_obs[3]

result_def = get_PRECT(fdir(1),fapend(1),casename(1),"model")
PRECT_def = result_def[0]
lat_def   = result_def[1]
lon_def   = result_def[2]

result_new = get_PRECT(fdir(2),fapend(2),casename(2),"model")
PRECT_new = result_new[0]
lat_new   = result_new[1]
lon_new   = result_new[2]

;horizontal interpolation
prect_interp = time_lat_lon_interpolate(dimsizes(time), \
                                        PRECT_obs,lat_obs,lon_obs, \
					PRECT_def,lat_def,lon_def, \
					PRECT_new,lat_new,lon_new)


printVarSummary(prect_interp)

lat1 = -30
lat2 = 30

lon1=180
lon2=270

;lon1=220
;lon2=280

; zonal mean over eastern pacific [80W-140W]
prect_interp_zm = dim_avg_n_Wrap(prect_interp(:,:,:,{lon1:lon2}),3) ; 160W-80W
;prect_interp_zm = dim_avg_n_Wrap(prect_interp(:,:,:,{140:200}),3) ; 140E-160W

printVarSummary(prect_interp_zm)

prect_interp_zm_rev = prect_interp_zm(case|:,lat|:,time|:)

prect_interp_zm_rev_diff = prect_interp_zm_rev
prect_interp_zm_rev_diff(0,:,:) = prect_interp_zm_rev(1,:,:) - prect_interp_zm_rev(0,:,:) ; def-obs
prect_interp_zm_rev_diff(1,:,:) = prect_interp_zm_rev(2,:,:) - prect_interp_zm_rev(0,:,:) ; new-obs
prect_interp_zm_rev_diff(2,:,:) = prect_interp_zm_rev(2,:,:) - prect_interp_zm_rev(1,:,:) ; new-obs


;*************************
; plotting parameters
;*************************
 wks   = gsn_open_wks ("eps", "../figure/fig16-lat-time-PRECT-"+casename(2)+"-"+lon1+"to"+lon2+"-eps" )

cmap1 = read_colormap_file("WhiteBlueGreenYellowRed")
cmap2 = read_colormap_file("ViBlGrWhYeOrRe")

 plot = new(6,graphic)

 res                  = True                ; plot mods desired
 res@gsnFrame = False
 res@gsnDraw = False
 res@cnFillOn         = True                ; color on
 res@lbOrientation    = "Vertical"          ; vertical label bar
 res@pmLabelBarOrthogonalPosF = -0.04       ; move label bar closer to axis
 res@cnLinesOn        = False               ; turn off contour lines
 ;res@cnFillPalette    = "ViBlGrWhYeOrRe"    ; set color map
 res@cnFillPalette        = cmap1(:170,:)

;  res@tmXMajorGrid                = True          ; implement x grid 
;  res@tmXMajorGridThicknessF      = 1.0           ; 2.0 is default
;  res@tmXMajorGridLineDashPattern = 2             ; select short dash lines
;  
;  res@tmYMajorGrid                = True          ; implement y grid
;  res@tmYMajorGridThicknessF      = 1.0           ; 2.0 is default
;  res@tmYMajorGridLineDashPattern = 2             ; select short dash lines
;
;  res@tmYMinorGrid                = True          ; implement y grid
;  res@tmYMinorGridThicknessF      = 1.0           ; 2.0 is default
;  res@tmYMinorGridLineDashPattern = 2             ; select short dash lines



 res@vpXF             = 0.12                ; default is 0.2 (aspect ratio)
 res@vpYF             = 0.8                 ; default is 0.8
 res@vpHeightF        = 0.4                 ; default is 0.6
 res@vpWidthF         = 0.75                ; default is 0.6

 res@tmXBMode = "Explicit"
 res@tmXBValues = fspan(0,11,12)
 res@tmXBLabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

 res@cnLevelSelectionMode = "ManualLevels" ; manual levels
 res@cnMinLevelValF       = 1.
 res@cnMaxLevelValF       = 15.
 res@cnLevelSpacingF      = 1.


 res@lbLabelStride    = 2

res@gsnStringFontHeightF = 0.025

res@gsnRightString = "PRECT(mm/day)"
res@gsnRightStringOrthogonalPosF = -0.010

;if(lon1.gt.180)then
;res@gsnCenterString = (360.-lon2)+"W-"+(360-lon1)+"W"
;else
;res@gsnCenterString = lon1+"E-"+(360-lon2)+"W"
;end if

res@gsnLeftString = "(a) GPCP"
 plot(0) = gsn_csm_lat_time(wks, prect_interp_zm_rev(0,{lat1:lat2},:), res) 

res@gsnLeftString = "(b) Park-RH"
 plot(1) = gsn_csm_lat_time(wks, prect_interp_zm_rev(1,{lat1:lat2},:), res) 

res@gsnLeftString = "(c) Gauss-PDF"
 plot(2) = gsn_csm_lat_time(wks, prect_interp_zm_rev(2,{lat1:lat2},:), res) 

; gsn_panel(wks,plot(0:2),(/3,1/),False)

 res@cnLevelSelectionMode = "ManualLevels" ; manual levels
 res@cnMinLevelValF       = -10.
 res@cnMaxLevelValF       = 10.
 res@cnLevelSpacingF      = 1.

delete(res@cnFillPalette)
res@cnFillPalette    = cmap2

res@gsnLeftString = "(d) RH-OBS"
 plot(3) = gsn_csm_lat_time(wks, prect_interp_zm_rev_diff(0,{lat1:lat2},:), res) 

res@gsnLeftString = "(e) PDF-OBS"
 plot(4) = gsn_csm_lat_time(wks, prect_interp_zm_rev_diff(1,{lat1:lat2},:), res) 

res@gsnLeftString = "(f) PDF-RH"
 plot(5) = gsn_csm_lat_time(wks, prect_interp_zm_rev_diff(2,{lat1:lat2},:), res) 

; gsn_panel(wks,plot(3:5),(/3,1/),False)

 gsn_panel(wks,plot,(/2,3/),False)





                              
end
