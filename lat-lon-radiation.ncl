load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

function get_data(fname:string,var:string)
begin

fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

append = ".cam.h0.ANN.nc"

f1 = addfile(fdir+fname(0)+fdir_append+fname(0)+append,"r")
lon = f1->lon
lat = f1->lat({-30:30})
ilev = f1->ilev
lev = f1->lev
gw = f1->gw({-30:30})

data_aave = new((/dimsizes(fname)/),float)

do ifile=0,dimsizes(fname)-1

f_tmp = addfile(fdir+fname(ifile)+fdir_append+fname(ifile)+append,"r")


    if (isfilevar(f1, var)) then
        data_tmp = f_tmp->$var$(0,{-30:30},:)
    end if

data_tmp_aave = wgt_areaave_Wrap(data_tmp,gw,1.0,1)

data_aave(ifile) = data_tmp_aave

end do

return(data_aave)

end



begin
;***************file 1********************
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

fname1 = "F_2000_f09f09_MG1.5"
fname2 = "new-cldfrac16-1d-MG15"

append = ".cam.h0.ANN.nc"

;analyze dataset 


vars = (/"FLNT","FSNT","FLNS","FSNS"/)

fname = (/fname1,fname2/)


nvars = dimsizes(vars)

out = new((/dimsizes(vars),dimsizes(fname)/),float)
do i = 0,dimsizes(vars)-1


out(i,:) = get_data(fname,vars(i))

end do

net1 = (out(0,0)-out(2,0))-(out(1,0)-out(3,0))
net2 = (out(0,1)-out(2,1))-(out(1,1)-out(3,1))

print(net1+" "+net2)




end
