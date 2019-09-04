load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

function get_data(fname:string,vars:string)
begin

fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

append = ".cam.h0.ANN.nc"

f1 = addfile(fdir+fname(0)+fdir_append+fname(0)+append,"r")
lon = f1->lon
lat = f1->lat(:)
ilev = f1->ilev
lev = f1->lev
gw = f1->gw

data_out = new((/dimsizes(fname),dimsizes(vars),dimsizes(lev),dimsizes(lat),dimsizes(lon)/),float)
data_diff = new((/dimsizes(fname),dimsizes(vars),dimsizes(lev),dimsizes(lat),dimsizes(lon)/),float)

do ifile=0,dimsizes(fname)-1


f_tmp = addfile(fdir+fname(ifile)+fdir_append+fname(ifile)+append,"r")

do ivar = 0,dimsizes(vars)-1

    if (isfilevar(f1, vars(ivar))) then
        data_tmp = f_tmp->$vars(ivar)$(0,:,:,:)
    else
        if(vars(ivar).eq."CWAT")then
            data_tmp_1 = f_tmp->CLDLIQ(0,:,:,:)
            data_tmp_2 = f_tmp->CLDICE(0,:,:,:)
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(vars(ivar).eq."TDH")then
            data_tmp_1 = f_tmp->DTCOND(0,:,:,:)
            data_tmp_2 = f_tmp->DTV(0,:,:,:)
            data_tmp_3 = f_tmp->QRS(0,:,:,:)
            data_tmp_4 = f_tmp->QRL(0,:,:,:)
            data_tmp = data_tmp_1+data_tmp_2+data_tmp_3+data_tmp_4
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(vars(ivar).eq."TDM")then
            data_tmp_1 = f_tmp->VD01(0,:,:,:); Q tendency due to turbulent scheme
            data_tmp_2 = f_tmp->DCQ(0,:,:,:) ; Q tendency due to moist processes
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(vars(ivar).eq."DQ_conv")then
            data_tmp_1 = f_tmp->ZMDQ  (0,:,:,:)
            data_tmp_2 = f_tmp->CMFDQ (0,:,:,:)
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(vars(ivar).eq."DQ_large")then
            data_tmp_1 = f_tmp->MACPDQ  (0,:,:,:)
            data_tmp_2 = f_tmp->MPDQ    (0,:,:,:)
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(vars(ivar).eq."DLIQ")then
            data_tmp_1 = f_tmp->CMFDLIQ     (0,:,:,:)
            data_tmp_2 = f_tmp->MACPDLIQ    (0,:,:,:)
            data_tmp_3 = f_tmp->MPDLIQ       (0,:,:,:)
            data_tmp_4 = f_tmp->qlten_PBL   (0,:,:,:)

            data_tmp = data_tmp_1+data_tmp_2+data_tmp_3+data_tmp_4
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(vars(ivar).eq."LS_T_vert")then
            data_tmp_1 = f_tmp->OMEGA  (0,:,:,:)
            data_tmp_2 = f_tmp->T      (0,:,:,:)

            ; notion: center_finite_diff_n wil form double type value.
            data_1_double = data_tmp_1*center_finite_diff_n(data_tmp_2,lev,False,0,0)
            data_1 = tofloat(data_1_double)

            ; change from (K)/(hPa) to (K)/(Pa)
            data_tmp = (-1.0)*data_1/(100.)

            copy_VarCoords(data_tmp,data_1)
            printVarSummary(data_tmp)
        end if

        if(vars(ivar).eq."LS_T_hor_u")then
            data_tmp_1 = f_tmp->U      (0,:,:,:)
            data_tmp_2 = f_tmp->T      (0,:,:,:)

	    dlon = (lon(2)-lon(1))*0.0174533
	    dTdX = new((/dimsizes(lev),dimsizes(lat),dimsizes(lon)/),typeof(data_tmp_2))
	    do nl = 0,dimsizes(lat)-1
	    dX = 6378388.*cos(0.0174533*lat(nl))*dlon
	    ; center_finite_diff_n will produce double type.
	    dTdX(:,nl:nl,:) = tofloat(center_finite_diff_n (data_tmp_2(:,nl:nl,:), dX , True,0,2))
	    end do
	    data_tmp = (-1.0)*data_tmp_1*dTdX

            copy_VarCoords(data_tmp_2,data_tmp)
        end if

        if(vars(ivar).eq."LS_T_hor_v")then
            data_tmp_1 = f_tmp->V      (0,:,:,:)
            data_tmp_2 = f_tmp->T      (0,:,:,:)

	    dlat = (lat(2)-lat(1))*0.0174533
	    dTdY = new((/dimsizes(lev),dimsizes(lat),dimsizes(lon)/),typeof(data_tmp_2))
	    do nl = 0,dimsizes(lon)-1
	    dY = 6378388.*dlat
	    ; center_finite_diff_n will produce double type.
	    dTdY(:,:,nl:nl) = tofloat(center_finite_diff_n (data_tmp_2(:,:,nl:nl), dY , True,0,1))
	    end do
	    data_tmp = (-1.0)*data_tmp_1*dTdY

            copy_VarCoords(data_tmp_2,data_tmp)
            printVarSummary(data_tmp)
        end if

        if(vars(ivar).eq."LS_T_all")then
            data_tmp_1 = f_tmp->OMEGA  (0,:,:,:)
            data_tmp_2 = f_tmp->U      (0,:,:,:)
            data_tmp_3 = f_tmp->V      (0,:,:,:)
            data_tmp_4 = f_tmp->T      (0,:,:,:)

            ; notion: center_finite_diff_n wil form double type value.
            dTdZ = tofloat(center_finite_diff_n(data_tmp_4,lev,False,0,0))
            ; change from (K)/(hPa) to (K)/(Pa)
            data_tmp_w = (-1.0)*data_tmp_1*dTdZ/(100.)
            copy_VarCoords(data_tmp_4,data_tmp_w)

	    dlon = (lon(2)-lon(1))*0.0174533
	    dTdX = new((/dimsizes(lev),dimsizes(lat),dimsizes(lon)/),typeof(data_tmp_4))
	    do nl = 0,dimsizes(lat)-1
	    dX = 6378388.*cos(0.0174533*lat(nl))*dlon
	    ; center_finite_diff_n will produce double type.
	    dTdX(:,nl:nl,:) = tofloat(center_finite_diff_n (data_tmp_4(:,nl:nl,:), dX , True,0,2))
	    end do
	    data_tmp_u = (-1.0)*data_tmp_2*dTdX
            copy_VarCoords(data_tmp_4,data_tmp_u)

	    dlat = (lat(2)-lat(1))*0.0174533
	    dTdY = new((/dimsizes(lev),dimsizes(lat),dimsizes(lon)/),typeof(data_tmp_4))
	    do nl = 0,dimsizes(lon)-1
	    dY = 6378388.*dlat
	    ; center_finite_diff_n will produce double type.
	    dTdY(:,:,nl:nl) = tofloat(center_finite_diff_n (data_tmp_4(:,:,nl:nl), dY , True,0,1))
	    end do
	    data_tmp_v = (-1.0)*data_tmp_3*dTdY
            copy_VarCoords(data_tmp_4,data_tmp_v)


	    data_tmp = data_tmp_w + data_tmp_u + data_tmp_v
	    copy_VarCoords(data_tmp_w,data_tmp)

	    printVarSummary(data_tmp)
        end if

    end if
  data_out(ifile,ivar,:,:,:) = data_tmp

  end do ; do ivar= 

end do ; do ifile=

do ifile=0,dimsizes(fname)-1
    data_diff(ifile,:,:,:,:) = data_out(ifile,:,:,:,:) - data_out(0,:,:,:,:)
    copy_VarCoords(data_out,data_diff)
end do

do ivar = 0,dimsizes(vars)-1

if(vars(ivar).eq."Q".or.vars(ivar).eq."CLDLIQ".or.vars(ivar).eq."CLDICE".or.vars(ivar).eq."CWAT")then
    data_out(:,ivar,:,:,:) = data_out(:,ivar,:,:,:)*1000.
    data_diff(:,ivar,:,:,:) = data_diff(:,ivar,:,:,:)*1000.
end if

if(vars(ivar).eq."CMFMCDZM".or.vars(ivar).eq."ZMMU".or.vars(ivar).eq."ZMEU".or.vars(ivar).eq."ZMDU")then
    data_diff(:,ivar,:,:,:) = -10.*data_diff(:,ivar,:,:,:)*86400/100.
    data_out(:,ivar,:,:,:) = -10.*data_out(:,ivar,:,:,:)*86400/100.
end if 

if(vars(ivar).eq."OMEGA")then
    data_diff(:,ivar,:,:,:) = data_diff(:,ivar,:,:,:)*86400./100.
    data_out(:,ivar,:,:,:) = data_out(:,ivar,:,:,:)*86400./100.
end if 

if(vars(ivar).eq."QRL".or.vars(ivar).eq."QRS".or.vars(ivar).eq."DTCOND".or.vars(ivar).eq."DTV".or.vars(ivar).eq."TDH".or.\
   vars(ivar).eq."ZMDT".or.vars(ivar).eq."CMFDT".or.\
   vars(ivar).eq."DTCORE".or.\
   vars(ivar).eq."LS_T_vert".or.\
   vars(ivar).eq."LS_T_hor_u".or.\
   vars(ivar).eq."LS_T_hor_v".or.\
   vars(ivar).eq."LS_T_all".or.\
   vars(ivar).eq."SHDLFT" .or. vars(ivar).eq."DPDLFT".or.\
   vars(ivar).eq."tten_PBL" \
   )then
    data_diff(:,ivar,:,:,:) = data_diff(:,ivar,:,:,:)*86400.
    data_out(:,ivar,:,:,:) = data_out(:,ivar,:,:,:)*86400.
end if

if(vars(ivar).eq."MACPDT".or.vars(ivar).eq."MPDT")then
    data_diff(:,ivar,:,:,:) = data_diff(:,ivar,:,:,:)*86400./1500.
    data_out(:,ivar,:,:,:) = data_out(:,ivar,:,:,:)*86400./1500.
end if

if(vars(ivar).eq."CMFDLIQ".or.vars(ivar).eq."MACPDLIQ".or.\
   vars(ivar).eq."MPDLIQ".or.vars(ivar).eq."qlten_PBL".or.\
   vars(ivar).eq."ZMDLIQ".or.vars(ivar).eq."DLIQ")then
    data_diff(:,ivar,:,:,:) = data_diff(:,ivar,:,:,:)*86400.*1000.
    data_out(:,ivar,:,:,:) = data_out(:,ivar,:,:,:)*86400.*1000.
end if

if(vars(ivar).eq."TDM".or.vars(ivar).eq."DCQ".or.vars(ivar).eq."VD01".or.vars(ivar).eq."qvten_PBL".or.\
   vars(ivar).eq."ZMDQ".or.vars(ivar).eq."CMFDQ".or.vars(ivar).eq."MACPDQ".or.vars(ivar).eq."MPDQ".or.\
   vars(ivar).eq."DQ_conv".or.vars(ivar).eq."DQ_large")then

    data_diff(:,ivar,:,:,:) = data_diff(:,ivar,:,:,:)*86400.*1000.
    data_out(:,ivar,:,:,:) = data_out(:,ivar,:,:,:)*86400.*1000.

end if

print(vars(ivar)+"	Min="+min(data_out(:,ivar,:,:,:))+"		Max="+max(data_out(:,ivar,:,:,:)))

end do


return( [/data_out, data_diff, lev, lat, lon/] )

end



begin
;***************file 1********************
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

;fname1 = "FC5_f09f09_MG15"
fname1 = "FC5_f09f09_MG15_COSP"
;fname2 = "new-cldfrac16-1d-MG15-revise"
fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"

;fname2 = "new-cldfrac16-1d-MG15-revise-shal"
;fname2 = "new-cldfrac16-1d-MG15"

;fname2 = "new-cldfrac16-1d-MG15-fix"
;fname2 = "new-cldfrac16-1d-MG15-turb"


append = ".cam.h0.ANN.nc"

;analyze dataset 


;vars = (/"TDM","DCQ","TDH","DTCOND","QRL","QRS","CWAT","CLOUD","CLDICE","CLDLIQ"/)
;vars = (/"CMFDLIQ","MACPDLIQ","MPDLIQ","qlten_PBL","DLIQ"/)

;vars 	  = (/"ZMDT","DPDLFT","CMFDT","SHDLFT","MACPDT","MPDT","tten_PBL","DTCOND","DTCORE"/)
;color_raw = (/"blue","navyblue","red","brown","black","darkorange","purple","yellow","green"/)

vars 	  = (/"CMFDT","SHDLFT","MACPDT","MPDT","tten_PBL","DTCOND","DTCORE","QRL","QRS"/)
color_raw = (/"red","brown","black","darkorange","purple","cyan2","darkolivegreen2","blue","navyblue"/)


;vars = (/"CLOUD","CLDLIQ"/)
;vars = (/"TDH","DTCOND","DTV","QRS","QRL","DTCORE"/)

;vars = (/"LS_T_all","LS_T_hor_u","LS_T_hor_v","LS_T_vert","DTCORE"/)
;vars = (/"U","V"/)

;vars = (/"T"/)

;vars = (/"TDM","DCQ","VD01"/)

;vars = (/"DCQ","ZMDQ","CMFDQ","MACPDQ","MPDQ"/)
;vars = (/"CMELIQ"/)


;vars = (/"qv_after","qv_before"/)
;vars = (/"T"/)

; "VD01" = "qvten_PBL"

fname = (/fname1,fname2/)


result= get_data(fname,vars)

xx = result[0] ; fname*vars*lev*lat*lon
yy = result[1] ; fname*vars*lev*lat*lon
lev = result[2]
lat = result[3]
lon = result[4]

xx_3dim = new((/dimsizes(fname)*dimsizes(vars),dimsizes(lev),dimsizes(lat),dimsizes(lon)/),float)
yy_3dim = new((/dimsizes(fname)*dimsizes(vars),dimsizes(lev),dimsizes(lat),dimsizes(lon)/),float)

xx_3dim(0:dimsizes(vars)-1,:,:,:) = xx(0,:,:,:,:)
xx_3dim(dimsizes(vars):2*dimsizes(vars)-1,:,:,:) = xx(1,:,:,:,:)
printVarSummary(xx_3dim)

yy_3dim(0:dimsizes(vars)-1,:,:,:) = yy(0,:,:,:,:)
yy_3dim(dimsizes(vars):2*dimsizes(vars)-1,:,:,:) = yy(1,:,:,:,:)
printVarSummary(yy_3dim)


printMinMax(yy_3dim,False)

label1 = new((/dimsizes(vars)/),string)
label2 = new((/dimsizes(vars)/),string)
label3 = new((/dimsizes(vars)/),string)

color1 = new((/dimsizes(vars)/),string)
color2 = new((/dimsizes(vars)/),string)
color  = new((/2*dimsizes(vars)/),string)

dash1 = new((/dimsizes(vars)/),string)
dash2 = new((/dimsizes(vars)/),string)
dash  = new((/2*dimsizes(vars)/),string)


do ivar = 0,dimsizes(vars)-1
label1(ivar) = (/vars(ivar)+"-Park_RH"/)
label2(ivar) = (/vars(ivar)+"-Gauss_PDF"/)
label3(ivar) = (/vars(ivar)+"-DIFF"/)

color1(ivar) = (/color_raw(ivar)/)
color2(ivar) = (/color_raw(ivar)/)

dash1(ivar) = (/0/)
dash2(ivar) = (/14/)

end do

color(0:dimsizes(vars)-1) = color1
color(dimsizes(vars):2*dimsizes(vars)-1) = color2

dash(0:dimsizes(vars)-1) = dash1
dash(dimsizes(vars):2*dimsizes(vars)-1) = dash2



;************************create plot***************
date=systemfunc("date")
print(date)
wks = gsn_open_wks("pdf","../figure/85W-Ttend-"+date)
;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
gsn_define_colormap(wks,"BlueRed")


res = True
res@trYReverse = True

res@gsnFrame = False
res@gsnDraw = False

;res@trYMinF = 700.
res@trYMinF = 400.

res@xyLineColors = color
res@xyDashPatterns = dash 
res@xyLineThicknessF = 2.0
res@xyMarkLineModes = "Lines"

res@tiYAxisString = "Pressure (hPa)"

res@tmXTOn        = False
res@tmYROn        = False
res@tmXBMinorOn         = False
res@tmYLMinorOn         = False

fh                          = 0.02
res@tmXBLabelFontHeightF    = fh
res@tmYLLabelFontHeightF    = fh
res@tiXAxisFontHeightF      = fh
res@tiYAxisFontHeightF      = fh

res@trXMinF		= -12.
res@trXMaxF		= 12.

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


res@gsnLeftString = "(a)"

if(vars(0).eq."CMFDT")then
res@tiXAxisString = "T Tendency (K day~S~-1~N~)"
end if

if(vars(0).eq."CMFDLIQ")then
res@tiXAxisString = "Liquid Water Tendency (g kg~S~-1~N~ day~S~-1~N~)"
end if

;res@tiMainString = "20S,"+(360-lon({275}))+"W"
res@gsnRightString = "[20S,"+(360-lon({275}))+"W]"

plot = gsn_csm_xy(wks,xx_3dim(:,:,{-20},{275}),lev,res)

;==============================Attach a legend
lgres1 = True
lgres1@lgLineColors =color1
lgres1@lgLineThicknessF = res@xyLineThicknessF
lgres1@lgDashIndexes = dash1
lgres1@lgItemTypes = res@xyMarkLineModes
lgres1@lgLabelFontHeightF = .08 
lgres1@vpWidthF = 0.22
lgres1@vpHeightF = 0.28
lgres1@lgPerimThicknessF = 1.0
lgres1@lgPerimOn = False

lgres2 = True
lgres2@lgLineColors = color2
lgres2@lgLineThicknessF = res@xyLineThicknessF
lgres2@lgDashIndexes = dash2
lgres2@lgItemTypes = res@xyMarkLineModes
lgres2@lgLabelFontHeightF = .08 
lgres2@vpWidthF = 0.22
lgres2@vpHeightF = 0.28
lgres2@lgPerimThicknessF = 1.0
lgres2@lgPerimOn = False

lgres3 = lgres1

;label1 = (/vars(0)+"-RH",vars(1)+"-RH",vars(2)+"-RH",vars(3)+"-RH",vars(4)+"-RH"/)
;label2 = (/vars(0)+"-PDF",vars(1)+"-PDF",vars(2)+"-PDF",vars(3)+"-PDF",vars(4)+"-PDF"/)

legend1 = gsn_create_legend(wks,dimsizes(vars),label1,lgres1)
legend2 = gsn_create_legend(wks,dimsizes(vars),label2,lgres2)
legend3 = gsn_create_legend(wks,dimsizes(vars),label3,lgres3)

amres1 = True
amres1@amJust = "TopRight"
amres1@amParallelPosF = 0.5
amres1@amOrthogonalPosF = -0.5 
annoid1 = gsn_add_annotation(plot,legend1,amres1)

amres2 = True
amres2@amJust = "TopLeft"
amres2@amParallelPosF = -0.5
amres2@amOrthogonalPosF = -0.5 
annoid2 = gsn_add_annotation(plot,legend2,amres2)


draw(plot)
frame(wks)

resd				= res
delete(resd@xyDashPatterns)
resd@xyDashPatterns = dash1
resd@trXMinF	= -6.
resd@trXMaxF	= 6.

resd@gsnLeftString = "(b)"

plotd = gsn_csm_xy(wks,yy_3dim(:,:,{-20},{275}),lev,resd)

annoid3 = gsn_add_annotation(plotd,legend3,amres1)
;annoid4 = gsn_add_annotation(plot,legend2,amres2)

draw(plotd)
frame(wks)

resP        = True
resP@gsnPanelYWhiteSpacePercent  = 5.0
resP@gsnPanelXWhiteSpacePercent  = 5.0
gsn_panel(wks,(/plot,plotd/),(/1,2/),resP)


end
