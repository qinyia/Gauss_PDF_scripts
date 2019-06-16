

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
  delete([/lbres,vph,vpw,nboxes,lbid,amres,annoid/])

end 


begin


fdir			= "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append		= "/atm/hist/"
case			= "new-cldfrac16-1d-MG15-revise-2-COSP"
append			= ".cam.h0."

files			= systemfunc("ls "+fdir+case+fdir_append+case+append+"0002-??.nc")

f1			= addfiles(files,"r")

CLOUD			= f1[:]->CLOUD
sgm			= f1[:]->sgm_tota
N1			= f1[:]->N1
printMinMax(N1,True)

sgm			= sqrt(sgm)*1e3

CLOUD@_FillValue	= 1e20
sgm@_FillValue		= 1e20

CLOUD			= where(CLOUD.le.1e-4,CLOUD@_FillValue,CLOUD)
sgm			= where(sgm.lt.1e-5,sgm@_FillValue,sgm)


CLOUD_n1		= CLOUD
sgm_n1			= sgm
CLOUD_n1		= where(N1.gt.0.5,CLOUD@_FillValue,CLOUD)
sgm_n1			= where(N1.gt.0.5,sgm@_FillValue,sgm)

printVarSummary(CLOUD)
printVarSummary(sgm)


;-------------------------------------------
; Peruvian (P): 10S-20S, 80W-90W
; Namibian (N): 10-20S, 0-10E
; Californian (C): 20-30N, 120-130W
; Australian (A): 25-35S, 95-105E
; Canarian (Ca): 15-25N, 25-35W
; North Pacific (Pa): 40-50N, 170E-180
; North Atlantic (At): 50-60N, 35-45W
; China (Ch): 20-30N, 105-120E

latSA			= (/-20, -20, 20, -25, 15, 40, 50, 20, -20, 5/)
latEA			= (/-10, -10, 30, -35, 25, 50, 60, 30, -10, 15/)
lonSA			= (/280., 0, 240, 95, 335, 170, 325, 105, 255, 140/)
lonEA			= (/270, 10, 230, 105, 325, 180, 315, 120, 230, 160/)
levSA			= (/500, 500, 500, 500, 500, 500, 500, 500, 500, 500/)
levEA			= (/950, 950, 950, 950, 950, 950, 950, 950, 950, 950/)
regionA			= (/ \
				"Peruvian (P): 10S-20S, 80W-90W",\               			; 0
				"Namibian (N): 10-20S, 0-10E",\                  			; 1
				"Californian (C): 20-30N, 120-130W",\            			; 2
				"Australian (A): 25-35S, 95-105E",\              			; 3
				"Canarian (Ca): 15-25N, 25-35W",\                			; 4
				"North Pacific (Pa): 40-50N, 170E-180",\         			; 5
				"North Atlantic (At): 50-60N, 35-45W",\          			; 6
				"China (Ch): 20-30N, 105-120E", \                			; 7
				"Southeast Pacific (SEP): 10S-20S, 105W-130W", \ 			; 8
				"Warm pool (WP): 5N-15N,140E-160E" \					; 9
		           /)

vector			= (/0,1,2,3,4,5,6,7,8,9/)
;vector			= (/9/)

latS			= latSA(vector)
latE			= latEA(vector)
lonS			= lonSA(vector)
lonE			= lonEA(vector)
levS			= levSA(vector)
levE			= levEA(vector)
region			= regionA(vector)

wks_type                        = "pdf"
wks_type@wkPaperWidthF          = 8.3 
wks_type@wkPaperHeightF         = 8.3 

wks			= gsn_open_wks(wks_type,"./figure/cloud-sgm-bin-by-region")

do ii=0,dimsizes(latS)-1

CLOUD_sp		= CLOUD(:,{levS(ii):levE(ii)},{latS(ii):latE(ii)},{lonS(ii):lonE(ii)})
CLOUD_n1_sp		= CLOUD_n1(:,{levS(ii):levE(ii)},{latS(ii):latE(ii)},{lonS(ii):lonE(ii)})

sgm_sp			= sgm(:,{levS(ii):levE(ii)},{latS(ii):latE(ii)},{lonS(ii):lonE(ii)})
sgm_n1_sp		= sgm_n1(:,{levS(ii):levE(ii)},{latS(ii):latE(ii)},{lonS(ii):lonE(ii)})

N1_sp			= N1(:,{levS(ii):levE(ii)},{latS(ii):latE(ii)},{lonS(ii):lonE(ii)})

printVarSummary(CLOUD_sp)

dSizes			= dimsizes(CLOUD_sp)
print(dSizes)

time			= CLOUD_sp&time
lev			= CLOUD_sp&lev
lat			= CLOUD_sp&lat
lon			= CLOUD_sp&lon

nt			= dSizes(0)
nlev			= dSizes(1)
nlat			= dSizes(2)
nlon			= dSizes(3)

CLOUD_lon		= reshape(CLOUD_sp,(/nt*nlev*nlat,nlon/))
CLOUD_lat		= reshape(CLOUD_sp,(/nt*nlev*nlon,nlat/))
CLOUD_lev		= reshape(CLOUD_sp,(/nt*nlat*nlon,nlev/))

CLOUD_n1_lev		= reshape(CLOUD_n1_sp,(/nt*nlat*nlon,nlev/))

sgm_lon			= reshape(sgm_sp,(/nt*nlev*nlat,nlon/))
sgm_lat			= reshape(sgm_sp,(/nt*nlev*nlon,nlat/))
sgm_lev			= reshape(sgm_sp,(/nt*nlat*nlon,nlev/))

sgm_n1_lev		= reshape(sgm_n1_sp,(/nt*nlat*nlon,nlev/))


N1_lon			= reshape(N1_sp,(/nt*nlev*nlat,nlon/))
N1_lat			= reshape(N1_sp,(/nt*nlev*nlon,nlat/))
N1_lev			= reshape(N1_sp,(/nt*nlat*nlon,nlev/))


printVarSummary(CLOUD_lev)

;---------------------------------Plotting starts here ---------------------------------------


res			= True

res@gsnFrame		= False
res@gsnDraw		= False

;res@gsnYAxisIrregular2Log = True

res@xyMarkLineMode	= "Markers"
res@xyMarkerSizeF	= 0.005
res@xyMarkers		= 16

res@gsnLeftString	= region(ii) 
res@trYMaxF		= 1.
res@trXMinF		= 0.
res@trXMaxF		= 1.

res@tiXAxisString	= "CLOUD (fraction)"

;------------
res1			= res
res1@trYMinF		= 0.
res1@tiYAxisString	= "sgm-linear"
;------------
res2			= res
res2@xyYStyle		= "Log"
res2@trYMinF		= 1e-4
res2@tiYAxisString	= "sgm-log"

;----------Setting----------------------
ntmp			= nlev
tmp			= lev

xx1			= CLOUD_lev
yy1			= sgm_lev
xx2			= CLOUD_n1_lev
yy2			= sgm_n1_lev

;----------Setting----------------------

color			= ispan(2,256,256/ntmp)
labels			= sprintf("%3.1f",tmp)

res1@xyMarkerColor	= color(0)
plot1			= gsn_csm_xy(wks,xx1(::2,ntmp-2),yy1(::2,ntmp-2),res1)
res2@xyMarkerColor	= color(0)
plot2			= gsn_csm_xy(wks,xx1(::2,ntmp-2),yy1(::2,ntmp-2),res2)


do iloop=0,ntmp-1
res1@xyMarkerColor	= color(iloop)
ovplot1			= gsn_csm_xy(wks,xx1(::2,iloop),yy1(::2,iloop),res1)
res2@xyMarkerColor	= color(iloop)
ovplot2			= gsn_csm_xy(wks,xx1(::2,iloop),yy1(::2,iloop),res2)

overlay(plot1,ovplot1)
overlay(plot2,ovplot2)
end do

labelbar		= attach_labelbar(wks,plot2,labels,color)

;draw(plot1)
;frame(wks)
;exit

resP			= True
resP@gsnPanelRight	= 0.9


gsn_panel(wks,(/plot1,plot2/),(/1,2/),resP)

delete([/CLOUD_lat,CLOUD_lon,CLOUD_lev,CLOUD_n1_lev/])
delete([/sgm_lat,sgm_lon,sgm_lev,sgm_n1_lev/])
delete([/N1_lat,N1_lon,N1_lev/])
delete([/color/])
delete([/CLOUD_sp,sgm_sp,N1_sp,CLOUD_n1_sp,sgm_n1_sp/])
delete([/time,lat,lon,lev/])
delete([/ntmp,tmp,xx1,yy1,xx2,yy2/])
delete(res)

end do ; do ii=


end
