
;----------------------------------------------------------------------
; Function to attach a labelbar outside of an XY plot
;----------------------------------------------------------------------
function attach_labelbar(wks,plot,labels,colors)
local lbres, vph, vpw, nboxes
begin
  nboxes = dimsizes(labels)
  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False          ; Necessary to control sizes
  lbres@lbPerimOn          = False
  lbres@vpWidthF           = 0.2 * vpw     ; labelbar width
  lbres@vpHeightF          = vph           ; labelbar height
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.02          ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
  lbres@lbBoxLinesOn       = False

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
;
; Now, create some annotation resources indicating how we want to
; attach the labelbar to the plot.
;                                                                 
  amres                = True
  amres@amParallelPosF = 0.61     ; Move away from plot
  annoid = gsn_add_annotation(plot,lbid,amres)

  return(annoid)
end


;============
; Main codes
;============

begin

season			=(/"ANN"/)

;compare_type 		= (/"amip-obs","cmip-obs"/)
compare_type 		= (/"amip-obs"/)

compset			= (/"atm"/)

var_TimeLatLon	= (/"ICWMR","CLOUD"/)

Dir		= "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/FC5_f09f09_checkIncloud_perStep/run/"
case		= "FC5_f09f09_checkIncloud_perStep.cam.h1.0001-01-01-00000.nc"


do icomp = 0,dimsizes(compare_type)-1
print(compare_type(icomp))


do icompset=0,dimsizes(compset)-1

;========================================================
; Read data
;========================================================
ncdf 				= addfile(Dir+case ,"r")
dSizes				= getfiledimsizes(ncdf)  
print(dSizes)
; lat: dSizes(1); lon: dSizes(2); time: dSizes(5); lev: dSizes(8)

do ivarlist=0,dimsizes(var_TimeLatLon)-1

vars_TimeLatLon			= new((/dimsizes(var_TimeLatLon),dSizes(5),dSizes(8),dSizes(1),dSizes(2)/),float)
vars_TimeLatLon!0		= "vars"
vars_TimeLatLon&vars		= ispan(0,dimsizes(var_TimeLatLon)-1,1)

do ivar=0,dimsizes(var_TimeLatLon)-1
	vars_TimeLatLon(ivar,:,:,:,:)		=ncdf->$var_TimeLatLon(ivar)$ 
end do

end do; do ivarlist=

printVarSummary(vars_TimeLatLon)
printMinMax(vars_TimeLatLon,True)

;========================================================
; Get regional average of variables
;========================================================

latS				= -20.
latE				= 0.
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
;---------------------------------------------------------------
; get index
;---------------------------------------------------------------
Index							= dimsizes(vars_TimeLatLon_SpecRegion)
printVarSummary(Index)
print(Index)
;---------------------------------------------------------------
; (vars,time*lat*lon)
;---------------------------------------------------------------
newdims1						= dimsizes(time(::10))*(ind_latE-ind_latS+1)*(ind_lonE-ind_lonS+1)
vars_TimeLatLon_SpecRegion_LatLon				= reshape(vars_TimeLatLon_SpecRegion,(/Index(0),newdims1/))
vars_TimeLatLon_SpecRegion_LatLon!0			= "vars"
vars_TimeLatLon_SpecRegion_LatLon&vars			= ispan(0,Index(0)-1,1)
vars_TimeLatLon_SpecRegion_LatLon!1			= "TimeLatLon"
vars_TimeLatLon_SpecRegion_LatLon&TimeLatLon		= ispan(0,newdims1-1,1)
printVarSummary(vars_TimeLatLon_SpecRegion_LatLon)

;---------------------------------------------------------------
; (vars,time*lat,lon)
;---------------------------------------------------------------
newdims2						= dimsizes(time(::10))*(ind_latE-ind_latS+1)
vars_TimeLatLon_SpecRegion_Lat				= reshape(vars_TimeLatLon_SpecRegion,(/Index(0),newdims2,Index(3)/))

vars_TimeLatLon_SpecRegion_Lat!0				= "vars"
vars_TimeLatLon_SpecRegion_Lat&vars			= ispan(0,Index(0)-1,1)
vars_TimeLatLon_SpecRegion_Lat!1				= "TimeLat"
vars_TimeLatLon_SpecRegion_Lat&TimeLat			= ispan(0,newdims2-1,1)
vars_TimeLatLon_SpecRegion_Lat!2				= "lon"
vars_TimeLatLon_SpecRegion_Lat&lon				= lon(ind_lonS:ind_lonE)
printVarSummary(vars_TimeLatLon_SpecRegion_Lat)

;---------------------------------------------------------------
; (vars,time*lon,lat)
;---------------------------------------------------------------
newdims3						= dimsizes(time(::10))*(ind_lonE-ind_lonS+1)
vars_TimeLatLon_SpecRegion_Lon				= reshape(vars_TimeLatLon_SpecRegion,(/Index(0),newdims3,Index(2)/))

vars_TimeLatLon_SpecRegion_Lon!0				= "vars"
vars_TimeLatLon_SpecRegion_Lon&vars			= ispan(0,Index(0)-1,1)
vars_TimeLatLon_SpecRegion_Lon!1				= "TimeLon"
vars_TimeLatLon_SpecRegion_Lon&TimeLon			= ispan(0,newdims3-1,1)
vars_TimeLatLon_SpecRegion_Lon!2				= "lat"
vars_TimeLatLon_SpecRegion_Lon&lat				= lat(ind_latS:ind_latE)
printVarSummary(vars_TimeLatLon_SpecRegion_Lon)


;---------------------------------------------------------------
; Set the plotting variables
;---------------------------------------------------------------
xx							= vars_TimeLatLon_SpecRegion_Lat(0,:,:)
yy							= vars_TimeLatLon_SpecRegion_Lat(1,:,:)
printVarSummary(xx)

levels							= xx&lon
labels							= sprintf("%3.1f",levels)
print(labels)

inds							= dimsizes(xx)
nps							= inds(1)

nsteps							= 256/nps
colors							= ispan(2,256,nsteps)
overlays 						= new(nps-1,graphic)

;========================================================
; Plotting starts here....
;========================================================
wks				= gsn_open_wks("x11","./figure/scatter"+"_"+latS+"_"+latE+"_"+lonS+"_"+lonE)

plotd				= new(4,graphic)

;************************************************
; create plots  
;************************************************


res				= True

res@gsnFrame			= False
res@gsnDraw			= False

res@xyMarkLineModes		= "Markers" 
res@xyMarkers			=  16 
res@xyMarkerSizeF		= 0.01 
res@tmLabelAutoStride 		= True 

res@trYMinF			= min(yy)
res@trYMaxF			= max(yy)
res@trXMinF			= min(xx)
res@trXMaxF			= max(xx)



res@xyMarkerColor		= colors(0)

;plotd				= gsn_csm_xy(wks,xxDiff,yyDiff,res)
;exit
plot				= gsn_csm_xy(wks,xx(:,0),yy(:,0),res)

do iloop = 1,nps-1
	res@xyMarkerColor		= colors(iloop)
	overlays(iloop-1)		= gsn_csm_xy(wks,xx(:,iloop),yy(:,iloop),res)

	overlay(plot,overlays(iloop-1))
end do

labelbar 			= attach_labelbar(wks,plot,labels,colors)

maximize_output(wks,False)

exit

end do ; do icompset=
end do; do icomp=
                               
end
