load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
begin
;***************file 1********************
fdir1 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt2-vocals/run/hourmean/"
fdir2 = "/home/lyl/WORK1/lyl_cesm1_2_1/scripts/capt-vocals-revise-2/run/hourmean/"

fname1 = "day03.nc"
fname2 = "day03.nc"

f1 = addfile(fdir1+fname1,"r")

time = f1->time
lev = f1->lev

lon = f1->lon

T_1 = new((/3,dimsizes(time),dimsizes(lev)/),float)
Q_1 = new((/3,dimsizes(time),dimsizes(lev)/),float)

T_1(0,:,:) = f1->T(:,:,{-20},{285}) ; 75W
T_1(1,:,:) = f1->T(:,:,{-20},{275}) ; 85W
T_1(2,:,:) = f1->T(:,:,{-20},{265}) ; 95W

T_1 = T_1-273.15

Q_1(0,:,:) = f1->Q(:,:,{-20},{285})
Q_1(1,:,:) = f1->Q(:,:,{-20},{275})
Q_1(2,:,:) = f1->Q(:,:,{-20},{265})


; calculate the relative humidity
es0 = 6.1078
a = 17.269
b = 35.86

Pres = conform(T_1,lev,2)
es_1 = es0*exp(a*T_1/(273.15+T_1-b)) ;T_1 unit: degree
e_1 =Q_1*Pres/(0.622+0.378*Q_1) 
RH_1 = e_1/es_1*100.
copy_VarCoords(T_1,RH_1)

Q_1 = Q_1*1000. ;kg/kg to g/kg

;======day mean
T_1_day = T_1(:,5:7,:)
T_1_day_avg = dim_avg_n_Wrap(T_1_day,1)

Q_1_day = Q_1(:,5:7,:)
Q_1_day_avg = dim_avg_n_Wrap(Q_1_day,1)

RH_1_day = RH_1(:,5:7,:)
RH_1_day_avg = dim_avg_n_Wrap(RH_1_day,1)


;night mean
T_1_night = T_1(:,1:4,:)
T_1_night_avg = dim_avg_n_Wrap(T_1_night,1)

Q_1_night = Q_1(:,1:4,:)
Q_1_night_avg = dim_avg_n_Wrap(Q_1_night,1)

RH_1_night = RH_1(:,1:4,:)
RH_1_night_avg = dim_avg_n_Wrap(RH_1_night,1)


;all day mean
T_1_avg = dim_avg_n_Wrap(T_1,1)
Q_1_avg = dim_avg_n_Wrap(Q_1,1)
RH_1_avg = dim_avg_n_Wrap(RH_1,1)


;==============================
f2 = addfile(fdir2+fname2,"r")

T_2 = new((/3,dimsizes(time),dimsizes(lev)/),float)
Q_2 = new((/3,dimsizes(time),dimsizes(lev)/),float)

T_2(0,:,:) = f2->T(:,:,{-20},{285}) ; 75W
T_2(1,:,:) = f2->T(:,:,{-20},{275}) ; 85W
T_2(2,:,:) = f2->T(:,:,{-20},{265}) ; 95W

T_2 = T_2-273.15

Q_2(0,:,:) = f2->Q(:,:,{-20},{285})
Q_2(1,:,:) = f2->Q(:,:,{-20},{275})
Q_2(2,:,:) = f2->Q(:,:,{-20},{265})


; calculate the relative humidity
es0 = 6.1078
a = 17.269
b = 35.86

Pres = conform(T_2,lev,2)
es_2 = es0*exp(a*T_2/(273.15+T_2-b))
e_2 =Q_2*Pres/(0.622+0.378*Q_2) 
RH_2 = e_2/es_2*100.
copy_VarCoords(T_2,RH_2)

Q_2 = Q_2*1000.

;======day mean
T_2_day = T_2(:,5:7,:)
T_2_day_avg = dim_avg_n_Wrap(T_2_day,1)

Q_2_day = Q_2(:,5:7,:)
Q_2_day_avg = dim_avg_n_Wrap(Q_2_day,1)

RH_2_day = RH_2(:,5:7,:)
RH_2_day_avg = dim_avg_n_Wrap(RH_2_day,1)

;night mean
T_2_night = T_2(:,1:4,:)
T_2_night_avg = dim_avg_n_Wrap(T_2_night,1)

Q_2_night = Q_2(:,1:4,:)
Q_2_night_avg = dim_avg_n_Wrap(Q_2_night,1)

RH_2_night = RH_2(:,1:4,:)
RH_2_night_avg = dim_avg_n_Wrap(RH_2_night,1)

;all day mean
T_2_avg = dim_avg_n_Wrap(T_2,1)
Q_2_avg = dim_avg_n_Wrap(Q_2,1)
RH_2_avg = dim_avg_n_Wrap(RH_2,1)



;**********************file3****************************
fdir3 = "/home/lyl/WORK3/qinyi/scripts/vocals-fortran/vocals_unify/"
fname31 = "75W_day.txt"
fname32 = "75W_nig.txt"
fname33 = "85W_day.txt"
fname34 = "85W_nig.txt"



data31 = asciiread(fdir3+fname31,(/30,6/),"float")
data32 = asciiread(fdir3+fname32,(/30,6/),"float")
data33 = asciiread(fdir3+fname33,(/30,6/),"float")
data34 = asciiread(fdir3+fname34,(/30,6/),"float")

; ========75W
;day 
 p31 = data31(:,0)
 t31 = data31(:,1)
td31 = data31(:,2)
rh31 = data31(:,3)
 u31 = data31(:,4)
 v31 = data31(:,5)

;night
 p32 = data32(:,0)
 t32 = data32(:,1)
td32 = data32(:,2)
rh32 = data32(:,3)
 u32 = data32(:,4)
 v32 = data32(:,5)

; ========85W
;day 
 p33 = data33(:,0)
 t33 = data33(:,1)
td33 = data33(:,2)
rh33 = data33(:,3)
 u33 = data33(:,4)
 v33 = data33(:,5)

;night
 p34 = data34(:,0)
 t34 = data34(:,1)
td34 = data34(:,2)
rh34 = data34(:,3)
 u34 = data34(:,4)
 v34 = data34(:,5)

T_3 = new((/3,2,dimsizes(lev)/),float) ;station_num*time_series*lev_num
Td_3 = new((/3,2,dimsizes(lev)/),float)
Q_3 = new((/3,2,dimsizes(lev)/),float)
p_3 = new((/3,2,dimsizes(lev)/),float)
RH_3 = new((/3,2,dimsizes(lev)/),float)

T_3(0,0,:) = t31(::-1)
T_3(0,1,:) = t32(::-1)
T_3(1,0,:) = t33(::-1)
T_3(1,1,:) = t34(::-1)
T_3(2,0,:) = -999.
T_3(2,1,:) = -999.

Td_3(0,0,:) = td31(::-1)
Td_3(0,1,:) = td32(::-1)
Td_3(1,0,:) = td33(::-1)
Td_3(1,1,:) = td34(::-1)
Td_3(2,0,:) = -999.
Td_3(2,1,:) = -999.

p_3(0,0,:) = p31(::-1)
p_3(0,1,:) = p32(::-1)
p_3(1,0,:) = p33(::-1)
p_3(1,1,:) = p34(::-1)
p_3(2,0,:) = -999.
p_3(2,1,:) = -999.

RH_3(0,0,:) = rh31(::-1)
RH_3(0,1,:) = rh32(::-1)
RH_3(1,0,:) = rh33(::-1)
RH_3(1,1,:) = rh34(::-1)
RH_3(2,0,:) = -999.
RH_3(2,1,:) = -999.

T_3@_FillValue = -999.
Q_3@_FillValue = -999.
Td_3@_FillValue = -999.
p_3@_FillValue = -999.
RH_3@_FillValue = -999.


; calculate the specific humidity
es0 = 6.1078
a = 17.269
b = 35.86

e_3 = es0*exp(a*Td_3/(273.15+Td_3-b))
e_3@_FillValue = -999.
Q_3 = 0.622*e_3/(p_3-0.378*e_3)


T_3_day_avg = T_3(:,0,:)
T_3_night_avg = T_3(:,1,:)

Q_3_day_avg = Q_3(:,0,:)
Q_3_night_avg = Q_3(:,1,:)

RH_3_day_avg = RH_3(:,0,:)
RH_3_night_avg = RH_3(:,1,:)

T_3_avg = dim_avg_n_Wrap(T_3,1)
Q_3_avg = dim_avg_n_Wrap(Q_3,1)
RH_3_avg = dim_avg_n_Wrap(RH_3,1)


copy_VarCoords(T_1_day_avg,T_3_day_avg)
copy_VarCoords(T_1_night_avg,T_3_night_avg)

copy_VarCoords(Q_1_day_avg,Q_3_day_avg)
copy_VarCoords(Q_1_night_avg,Q_3_night_avg)

copy_VarCoords(RH_1_day_avg,RH_3_day_avg)
copy_VarCoords(RH_1_night_avg,RH_3_night_avg)

copy_VarCoords(T_1_avg,T_3_avg)
copy_VarCoords(Q_1_avg,Q_3_avg)
copy_VarCoords(RH_1_avg,RH_3_avg)


Q_3_day_avg = Q_3_day_avg*1000.
Q_3_night_avg = Q_3_night_avg*1000.
Q_3_avg = Q_3_avg*1000.


T_dn = new((/18,dimsizes(lev)/),float)
T_dn(0:2,:) = T_1_day_avg
T_dn(3:5,:) = T_1_night_avg
T_dn(6:8,:) = T_2_day_avg
T_dn(9:11,:) = T_2_night_avg
T_dn(12:14,:) = T_3_day_avg
T_dn(15:17,:) = T_3_night_avg

Q_dn = new((/18,dimsizes(lev)/),float)
Q_dn(0:2,:)  = Q_1_day_avg
Q_dn(3:5,:)  = Q_1_night_avg
Q_dn(6:8,:)  = Q_2_day_avg
Q_dn(9:11,:) = Q_2_night_avg
Q_dn(12:14,:)= Q_3_day_avg
Q_dn(15:17,:)= Q_3_night_avg

; no separate between day and night
T_all_day = new((/9,dimsizes(lev)/),float)
T_all_day(0:2,:) = T_1_avg
T_all_day(3:5,:) = T_2_avg
T_all_day(6:8,:) = T_3_avg

; change unit from degreeC to K
T_all_day = T_all_day + 273.15

Q_all_day = new((/9,dimsizes(lev)/),float)
Q_all_day(0:2,:) = Q_1_avg
Q_all_day(3:5,:) = Q_2_avg
Q_all_day(6:8,:) = Q_3_avg


RH_all_day = new((/9,dimsizes(lev)/),float)
RH_all_day(0:2,:) = doubletofloat(RH_1_avg)
RH_all_day(3:5,:) = doubletofloat(RH_2_avg)
RH_all_day(6:8,:) = RH_3_avg



;***********************create plot***************
;wks = gsn_open_wks("eps","../figure/fig5-profile_T_Q_day_night_75W_2_95W-eps")
wks = gsn_open_wks("pdf","../figure/fig5-profile_T_Q_day_night_75W_2_95W")

plot = new(4,graphic)

;colors = (/"black","blue","magenta","brown","burlywood","darkgreen","darkorange","purple"/)
; use colors to separate three stations
colors = (/"blue","red","black","blue","red","black","blue","red","black","blue","red","black"/)
; use marker to separate day and night
markermode = (/"Lines","Lines","Lines","Lines","Lines","Lines","Lines","Lines","Lines"/)
;markers = (/16,16,16,16,16,16/)
; use dash line to separate two cases and observation:
dashes = (/1,1,1,2,2,2,0,0,0/)

thickes = (/1.5,2,3,1.5,2,3,1.5,2,3/)

res = True
;res@tiMainString = "Temperature (85W,20S)" 	;add title
res@trYReverse = True 				;reverse Y-axis
res@gsnFrame = False 				;don't advance frame yet
res@gsnDraw = False
res@trYMinF =700
res@trYMaxF = lev(29)
res@xyMarkLineModes = markermode
;res@xyMarkers = markers
;res@tiXAxisString = "temperature (K)"
res@tiYAxisString = "pressure (hPa)"
res@xyLineColors = colors 
;res@xyLineThicknessF = 3.0
res@xyMonoLineThickness = False
res@xyLineThicknesses	= thickes 
res@xyDashPatterns = dashes


;res@tiXAxisString = "T(~F34~0~F~C)"
res@tiXAxisString = "T (K)"
res@trXMinF = 273.
res@trXMaxF = 293.
res@gsnLeftString = "(a)"

res@gsnLeftStringFontHeightF = 0.03

ft								= 0.025
res@gsnStringFontHeightF		= ft+0.005
res@tmXTOn						= False
res@tmYROn						= False
res@tmXBLabelFontHeightF		= ft
res@tmYLLabelFontHeightF		= ft 
res@tmXBMinorOn					= False
res@tmYLMinorOn					= False

res@tiXAxisFontHeightF			= ft+0.005
res@tiYAxisFontHeightF			= ft+0.005



plot(0) = gsn_csm_xy(wks,T_all_day,T_all_day&lev,res)
;plot(0) = gsn_csm_xy(wks,T_dn,T_dn&lev,res)


;========================
;Attach a legend
lgres = True
;lgres@lgLineColors = colors
lgres@lgLineColors = (/"black","black","black"/)
lgres@lgMonoLineThickness = False
lgres@lgLineThicknesses = res@xyLineThicknesses
;lgres@lgLineThicknessF = res@xyLineThicknessF
lgres@lgItemTypes = res@xyMarkLineModes
lgres@lgLabelFontHeightF = .060
lgres@vpWidthF = 0.30
lgres@vpHeightF = 0.22
lgres@lgPerimOn = False

labels_case = (/"Park_RH","Gauss_PDF","OBS"/)
labels_station = (/"75W","85W","95W"/)

lgres@lgDashIndexes = (/1,2,0/)
legend_case = gsn_create_legend(wks,3,labels_case,lgres)

;===========add text here
txres = True
txres@txFontHeightF = 0.025
txres@txJust = "TopRight"

ypos = 750.
xpos = 277.
strs = (/"75W",\
         "85W",\
	 "95W"/)
nstr = dimsizes(strs)
text = new(nstr,graphic)

;====note
;note 1: the xpos and ypos are the coordinate of plot, not the position in workstation. gsn_text_ndc depends on the position in workstation.
;note 2: txres@txFontColor only supports one color, thus it is necessary to cycle it in the do cycle.
ypos = 700.
do i=0,nstr-1
  ypos = ypos+20.
  txres@txFontColor = colors(i)
  text_anno = gsn_add_text(wks,plot(0),strs(i),xpos,ypos,txres)
end do

;gsn_text_ndc(wks,"75W",0.5,0.5,txres)

;========================
res@tiXAxisString = "q~B~v~N~ (g kg~S~-1~N~)"
res@trXMinF = 0.
res@trXMaxF = 10.
res@gsnLeftString = "(b)"
plot(1) = gsn_csm_xy(wks,Q_all_day,Q_all_day&lev,res)

;=======
amres_case = True
amres_case@amJust = "TopRight"
amres_case@amParallelPosF = 0.5
amres_case@amOrthogonalPosF = -0.5 
annoid_case = gsn_add_annotation(plot(1),legend_case,amres_case)

;========================
res@tiXAxisString = "RH (%)"
res@trXMinF = 0.
res@trXMaxF = 100.
res@gsnLeftString = "(c)"
;plot(2) = gsn_csm_xy(wks,RH_all_day,RH_all_day&lev,res)

resP						= True
resP@gsnPanelLeft			= 0.05
resP@gsnPanelRight			= 0.95

gsn_panel(wks,plot,(/1,2/),resP)

end
