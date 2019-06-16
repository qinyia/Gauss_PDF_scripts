load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

function get_data(fname:string,var:string,east:numeric)
begin

fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

append = ".cam.h0.ANN.nc"

f1 = addfile(fdir+fname(0)+fdir_append+fname(0)+append,"r")
lon = f1->lon
lat = f1->lat({-30:30})
ilev = f1->ilev
lev = f1->lev
gw = f1->gw

if(var.eq."CMFMCDZM")then
data_out = new((/dimsizes(fname),dimsizes(ilev),dimsizes(lat)/),float)
data_ave = new((/dimsizes(fname),dimsizes(ilev),dimsizes(lat)/),float)
else
data_out = new((/dimsizes(fname),dimsizes(lev),dimsizes(lat)/),float)
data_ave = new((/dimsizes(fname),dimsizes(lev),dimsizes(lat)/),float)
end if

do ifile=0,dimsizes(fname)-1

f_tmp = addfile(fdir+fname(ifile)+fdir_append+fname(ifile)+append,"r")


if(east.eq.1)then ; global
    if (isfilevar(f1, var)) then
        data_tmp = f_tmp->$var$(0,:,{-30:30},:)
    else
        if(var.eq."CWAT")then
            data_tmp_1 = f_tmp->CLDLIQ(0,:,{-30:30},:)
            data_tmp_2 = f_tmp->CLDICE(0,:,{-30:30},:)
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."TDH")then
            data_tmp_1 = f_tmp->DTCOND(0,:,{-30:30},:)
            data_tmp_2 = f_tmp->DTV(0,:,{-30:30},:)
            data_tmp_3 = f_tmp->QRS(0,:,{-30:30},:)
            data_tmp_4 = f_tmp->QRL(0,:,{-30:30},:)
            data_tmp = data_tmp_1+data_tmp_2+data_tmp_3+data_tmp_4
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."TDM")then
            data_tmp_1 = f_tmp->VD01(0,:,{-30:30},:)
            data_tmp_2 = f_tmp->DCQ(0,:,{-30:30},:)
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."DQ_conv")then
            data_tmp_1 = f_tmp->ZMDQ  (0,:,{-30:30},:)
            data_tmp_2 = f_tmp->CMFDQ (0,:,{-30:30},:)
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."DQ_large")then
            data_tmp_1 = f_tmp->MACPDQ  (0,:,{-30:30},:)
            data_tmp_2 = f_tmp->MPDQ    (0,:,{-30:30},:)
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if



    end if
end if

if(east.eq.2)then ; western pacific
    if (isfilevar(f1, var)) then
        data_tmp = f_tmp->$var$(0,:,{-30:30},{120:180})
    else
        if(var.eq."CWAT")then
            data_tmp_1 = f_tmp->CLDLIQ(0,:,{-30:30},{120:180})
            data_tmp_2 = f_tmp->CLDICE(0,:,{-30:30},{120:180})
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."TDH")then
            data_tmp_1 = f_tmp->DTCOND(0,:,{-30:30},{120:180})
            data_tmp_2 = f_tmp->DTV   (0,:,{-30:30},{120:180})
            data_tmp_3 = f_tmp->QRS   (0,:,{-30:30},{120:180})
            data_tmp_4 = f_tmp->QRL   (0,:,{-30:30},{120:180})
            data_tmp = data_tmp_1+data_tmp_2+data_tmp_3+data_tmp_4
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."TDM")then
            data_tmp_1 = f_tmp->VD01(0,:,{-30:30},{120:180})
            data_tmp_2 = f_tmp->DCQ (0,:,{-30:30},{120:180})
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."DQ_conv")then
            data_tmp_1 = f_tmp->ZMDQ  (0,:,{-30:30},{120:180})
            data_tmp_2 = f_tmp->CMFDQ (0,:,{-30:30},{120:180})
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."DQ_large")then
            data_tmp_1 = f_tmp->MACPDQ  (0,:,{-30:30},{120:180})
            data_tmp_2 = f_tmp->MPDQ    (0,:,{-30:30},{120:180})
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if



    end if
end if

if(east.eq.3) then
    if (isfilevar(f1, var)) then
        data_tmp = f_tmp->$var$(0,:,{-30:30},{180:270})
    else
        if(var.eq."CWAT")then
            data_tmp_1 = f_tmp->CLDLIQ(0,:,{-30:30},{180:270})
            data_tmp_2 = f_tmp->CLDICE(0,:,{-30:30},{180:270})
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."TDH")then
            data_tmp_1 = f_tmp->DTCOND(0,:,{-30:30},{180:270})
            data_tmp_2 = f_tmp->DTV   (0,:,{-30:30},{180:270})
            data_tmp_3 = f_tmp->QRS   (0,:,{-30:30},{180:270})
            data_tmp_4 = f_tmp->QRL   (0,:,{-30:30},{180:270})
            data_tmp = data_tmp_1+data_tmp_2+data_tmp_3+data_tmp_4
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."TDM")then
            data_tmp_1 = f_tmp->VD01(0,:,{-30:30},{180:270})
            data_tmp_2 = f_tmp->DCQ (0,:,{-30:30},{180:270})
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."DQ_conv")then
            data_tmp_1 = f_tmp->ZMDQ  (0,:,{-30:30},{180:270})
            data_tmp_2 = f_tmp->CMFDQ (0,:,{-30:30},{180:270})
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if

        if(var.eq."DQ_large")then
            data_tmp_1 = f_tmp->MACPDQ  (0,:,{-30:30},{180:270})
            data_tmp_2 = f_tmp->MPDQ    (0,:,{-30:30},{180:270})
            data_tmp = data_tmp_1+data_tmp_2
            copy_VarCoords(data_tmp_1,data_tmp)
        end if



    end if
end if

data_tmp_ave = dim_avg_n_Wrap(data_tmp,2)

data_ave(ifile,:,:) = data_tmp_ave

end do

do ifile=0,dimsizes(fname)-1
    data_out(ifile,:,:) = data_ave(ifile,:,:) - data_ave(0,:,:)
    copy_VarCoords(data_ave,data_out)
end do

if(var.eq."Q".or.var.eq."CLDLIQ".or.var.eq."CLDICE".or.var.eq."CWAT")then
    data_ave = data_ave*1000.
    data_out = data_out*1000.
end if

if(var.eq."CMFMCDZM".or.var.eq."ZMMU".or.var.eq."ZMEU".or.var.eq."ZMDU")then
    data_out = -10.*data_out*86400/100.
    data_ave = -10.*data_ave*86400/100.
end if 

if(var.eq."OMEGA")then
    data_out = data_out*86400./100.
    data_ave = data_ave*86400./100.
end if 

if(var.eq."QRL".or.var.eq."QRS".or.var.eq."DTCOND".or.var.eq."DTV".or.var.eq."TDH".or.\
   var.eq."ZMDT".or.var.eq."CMFDT")then
    data_out = data_out*86400.
    data_ave = data_ave*86400.
end if

if(var.eq."MACPDT".or.var.eq."MPDT")then
    data_out = data_out*86400./1500.
    data_ave = data_ave*86400./1500.
end if

if(var.eq."TDM".or.var.eq."DCQ".or.var.eq."VD01".or.\
   var.eq."ZMDQ".or.var.eq."CMFDQ".or.var.eq."MACPDQ".or.var.eq."MPDQ".or.\
   var.eq."DQ_conv".or.var.eq."DQ_large")then
    data_out = data_out*86400.*1000.
    data_ave = data_ave*86400.*1000.
end if


return( [/data_out, data_ave/] )

end



begin
;***************file 1********************
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

fname1 = "F_2000_f09f09_MG1.5"
fname2 = "new-cldfrac16-1d-MG15"


append = ".cam.h0.ANN.nc"

;analyze dataset 


;vars = (/"TDM","DCQ","TDH","DTCOND","QRL","QRS","CWAT","CLOUD","CLDICE","CLDLIQ"/)
;vars = (/"TDM","DCQ","TDH","DTCOND","QRL","QRS"/)
vars = (/"CLOUD","AREL"/)

fname = (/fname1,fname2/)


; east=1: global; 
; east=2: west; 
; east=3: east
;east = (/1,2,3/)
east = (/1/)


region = (/"Global","WP","EP"/)

nvars = dimsizes(vars)
con = new((/nvars,15/),float)
dcon = new ((/nvars,15/),float)

do i = 0,dimsizes(vars)-1
     if (vars(i) .eq. "Q") then
       con(i,:)=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,16/)
       dcon(i,:)=(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
     end if
     if (vars(i) .eq. "T") then
       con(i,:)=(/180,185,190,200,210,220,230,240,250,260,270,280,290,295,300/)
       dcon(i,:)=(/-9,-7,-5,-4,-3,-2,-1,0,1,2,3,4,5,7,9/)
     end if
     if (vars(i) .eq. "RELHUM") then
       con(i,:)=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)
       dcon(i,:)=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     end if
     if (vars(i) .eq. "TDH".or.vars(i).eq."DTCOND".or.\
         vars(i).eq."ZMDT".or.vars(i).eq."MACPDT".or.vars(i).eq."CMFDT".or.vars(i).eq."MPDT") then
       con(i,:)=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/)
       dcon(i,:)=(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
     end if
     if (vars(i) .eq. "TDM".or.vars(i).eq."DCQ".or.\
         vars(i).eq."ZMDQ".or.vars(i).eq."MACPDQ".or.vars(i).eq."CMFDQ".or.vars(i).eq."MPDQ".or.\
         vars(i) .eq."DQ_conv".or.vars(i).eq."DQ_large") then
       con(i,:)=(/-2.1,-1.8,-1.5,-1.2,-.9,-.6,-.3,0,.3,.6,.9,1.2,1.5,1.8,2.1/)
       dcon(i,:)=(/-.7,-.6,-.5,-.4,-.3,-.2,-.1,0,.1,.2,.3,.4,.5,.6,.7/)
     end if
;     if (vars(i) .eq. "CLOUD") then
;       con(i,:)=(/.05,.1,.15,.2,.25,.3,.35,.4,.45,.5,.55,.6,.65,.7,.75/)
;       dcon(i,:)=(/-.20,-.17,-.14,-.11,-.08,-.05,-.02,0,.02,.05,.08,.11,.14,.17,.20/)
;     end if
     if (vars(i) .eq. "QRS") then
       con(i,:)=(/.1,.2,.3,.4,.5,.6,.7,.8,.9,1,1.1,1.2,1.3,1.4,1.5/)
       dcon(i,:)=(/-.4,-.3,-.25,-.2,-.15,-.1,-.05,0,.05,.1,.15,.2,.25,.3,.4/)
     end if
     if (vars(i) .eq. "QRL") then
       con(i,:)=(/-7,-6,-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-.5,0,.5,1/)
       dcon(i,:)=(/-1,-.8,-.6,-.4,-.3,-.2,-.1,0,.1,.2,.3,.4,.6,.8,1/)
     end if
     if (vars(i) .eq. "CWAT") then
       con(i,:)=(/.01,.015,.02,.025,.03,.035,.04,.05,.06,.07,.08,.09,.10,.11,.12/)
       dcon(i,:)=(/-.06,-.05,-.04,-.03,-.02,-.01,-.005,0,.005,.01,.02,.03,.04,.05,.06/)
     end if
     if (vars(i) .eq. "CLDLIQ") then
       con(i,:)=(/0.01,0.02,0.03,0.04,0.05,0.08,0.1,0.12,0.14,0.16,0.18,0.20,0.22,0.24,0.26/)
       dcon(i,:)=(/-0.12,-0.1,-0.08,-0.06,-0.04,-0.02,-0.01,0,0.01,0.02,0.04,0.06,0.08,0.1,0.12/)
     end if
     if (vars(i) .eq. "CLDICE") then
       con(i,:)=(/0.001,0.002,0.004,0.006,0.008,0.01,0.012,0.015,0.02,0.025,0.03,0.035,0.04,0.045,0.05/)
       dcon(i,:)=(/-0.02,-0.015,-0.010,-0.005,-0.004,-0.002,-0.001,0,0.001,0.002,0.004,0.005,0.01,0.015,0.02/)
     end if
     if (vars(i) .eq. "OMEGA".or.vars(i).eq."CMFMCDZM") then
       con(i,:)=(/-20,-10,-5,0,5,10,20,30,40,50,60,80,100,120,150/)
       dcon(i,:)=(/-20,-15,-10,-8,-6,-4,-2,0,2,4,6,8,10,15,20/)
     end if

end do ; do i=


do i = 0,dimsizes(vars)-1

do ieast = 0,dimsizes(east)-1 ; west and east pacific

result= get_data(fname,vars(i),east(ieast))

xx = result[0]
yy = result[1]

printVarSummary(xx)

printMinMax(yy,False)

;************************create plot***************
wks = gsn_open_wks("x11","figure/lat-height-diff-all-"+vars(i)+"-"+region(ieast))
;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
gsn_define_colormap(wks,"BlueRed")

plot1 = new(1,graphic)
plot2 = new(8,graphic)

res = True
res@trYReverse = True
res@gsnDraw = False
res@gsnFrame = False
res@tiYAxisString = "pressure(hPa)"

res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnFillOn = True
res@cnInfoLabelOn = False

res@gsnYAxisIrregular2Linear = True

res@gsnLeftString = ""
res@gsnRightString = ""

res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ExplicitLevels"

do ifile=0,dimsizes(fname)-1

    res@gsnLeftString = fname(ifile)+" "+vars(i)+" "+region(ieast)
    if(ifile.eq.0)then
        res@cnLevels = con(i,:)
        plot1(ifile) = gsn_csm_contour(wks,yy(ifile,:,{-30:30}),res)
        delete(res@cnLevels)
    else
        res@cnLevels = dcon(i,:)
        plot2(ifile-1) = gsn_csm_contour(wks,xx(ifile,:,{-30:30}),res)

;        res@cnLevels = con(i,:)
;        plot2(ifile-1) = gsn_csm_contour(wks,yy(ifile,:,{-30:30}),res)

        delete(res@cnLevels)
    end if

end do



pres1 = True
;pres1@txString = vars(i)+" For "+region(ieast)
pres1@gsnPanelLabelBar = True
pres1@gsnFrame = False
pres1@gsnPanelBottom = 0.7
pres1@lbOrientation = "vertical"
gsn_panel(wks,plot1,(/1,1/),pres1)

pres2 = True
pres2@gsnPanelLabelBar = True
pres2@gsnPanelTop = 0.7
pres2@gsnPanelBottom = 0.10
pres2@gsnFrame = False
;pres2@lbOrientation = "vertical"

gsn_panel(wks,plot2,(/2,3/),pres2)

frame(wks)



delete(xx)
delete(yy)

end do ;do i=

end do ; do ieast=




end
