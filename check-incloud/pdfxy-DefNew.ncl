
begin

season			=(/"ANN"/)

;compare_type 		= (/"amip-obs","cmip-obs"/)
compare_type 		= (/"amip-obs"/)

compset			= (/"atm"/)

var_TimeLatLon	= (/"ICWMR","CLOUD"/)

Dir		= "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/"
Dir_append	= "/run/"
case		= (/"FC5_f09f09_checkIncloud_perStep","FC5_f09f09_Mac3_checkIncloud_perStep"/)
case_append	= ".cam.h1.0001-01-01-00000.nc"

case_out	= (/"Def","New"/)


do icase=0,dimsizes(case)-1

;========================================================
; Read data
;========================================================
ncdf 				= addfile(Dir+case(icase)+Dir_append+case(icase)+case_append ,"r")
dSizes				= getfiledimsizes(ncdf)  
print(dSizes)
; lat: dSizes(1); lon: dSizes(2); time: dSizes(5); lev: dSizes(8)

;do ivarlist=0,dimsizes(var_TimeLatLon)-1

vars_TimeLatLon			= new((/dimsizes(var_TimeLatLon),dSizes(5),dSizes(8),dSizes(1),dSizes(2)/),float)
vars_TimeLatLon!0		= "vars"
vars_TimeLatLon&vars		= ispan(0,dimsizes(var_TimeLatLon)-1,1)

do ivar=0,dimsizes(var_TimeLatLon)-1
	vars_TimeLatLon(ivar,:,:,:,:)		=ncdf->$var_TimeLatLon(ivar)$ 

if(var_TimeLatLon(ivar).eq."ICWMR")then
	vars_TimeLatLon(ivar,:,:,:,:)	 	= vars_TimeLatLon(ivar,:,:,:,:)*1e3
end if

end do

;end do; do ivarlist=

printVarSummary(vars_TimeLatLon)
printMinMax(vars_TimeLatLon,True)

;========================================================
; Get regional average of variables
;========================================================

; notion: because later need to calculate the difference: (ind_latS-ind_latE)
; so latS must be the more southward latitude value.  
; the same to lonE and lonS.
latS				= -20.
latE				= 20.
lonS				= 180.
lonE				= 280.

levS				= 850.

lat				= vars_TimeLatLon&lat
lat!0				= "lat"
lat&lat				= vars_TimeLatLon&lat
rad    				= 4.0*atan(1.0)/180.0
clat   				= cos(lat*rad)
copy_VarCoords(lat,clat)

lon				= vars_TimeLatLon&lon
time				= vars_TimeLatLon&time
lev				= vars_TimeLatLon&lev

ind_latS			= ind_nearest_coord(latS,lat,0)
ind_latE			= ind_nearest_coord(latE,lat,0)

ind_lonS			= ind_nearest_coord(lonS,lon,0)
ind_lonE			= ind_nearest_coord(lonE,lon,0)

ind_levS			= ind_nearest_coord(levS,lev,0)

print(ind_latE-ind_latS)
print(ind_lonE-ind_lonS)
print(ind_levS)


;do ilat=ind_latS,ind_latE
;do ilon=ind_lonS,ind_lonE


;---------------------------------------------------------------
; get variable from the specific region
;---------------------------------------------------------------
; vars_TimeLatLon(var,time,lev,lat,lon)
vars_TimeLatLon_SpecRegion					= vars_TimeLatLon(:,{::10},ind_levS,ind_latS:ind_latE,ind_lonS:ind_lonE)
printVarSummary(vars_TimeLatLon_SpecRegion)

; (var,time,lat,lon)
xx				= vars_TimeLatLon_SpecRegion(0,:,:,:)
yy				= vars_TimeLatLon_SpecRegion(1,:,:,:)

; PDFxy
pdf2				= pdfxy(xx,yy,0,0,False)
printVarSummary(pdf2)
;========================================================
; Plotting starts here....
;========================================================
wks				= gsn_open_wks("x11","./figure/PDFxy"+case_out(icase)+"_"+latS+"_"+latE+"_"+lonS+"_"+lonE)

plotd				= new(4,graphic)

;************************************************
; create plots  
;************************************************


res				= True

;res@gsnFrame			= False
;res@gsnDraw			= False

res@cnFillOn			= True
res@cnFillPalette		= "WhBlGrYeRe"
res@cnFillMode			= "RasterFill"
res@cnLinesOn			= False
res@cnLineLabelsOn		= False
res@cnInfoLabelOn		= False

res@tiXAxisString		= var_TimeLatLon(0)
res@tiYAxisString		= var_TimeLatLon(1)

res@cnLevelSelectionMode        = "ExplicitLevels"
res@cnLevels			= (/0.002,0.2,0.4,0.6,0.8,1.0,1.2,1.5,2.0,2.5/)

res@trXMaxF			= 1.

plot				= gsn_csm_contour(wks,pdf2,res)


end do ; do icase=

                               
end
