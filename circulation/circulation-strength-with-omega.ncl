load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

load "./functions_zmmsf.ncl"
load "./functions_lat_interpolate.ncl"

begin

;***************file 1********************
fdir = "/home/lyl/WORK1/lyl_cesm1_2_1/archive/"
fdir_append = "/atm/hist/"

fdir_obs = "/home/lyl/WORK1/cesm1_2_1/amwg_diag/obs_data/"

fname1 = "FC5_f09f09_MG15"
;fname2 = "new-cldfrac16-1d-MG15"
fname2 = "new-cldfrac16-1d-MG15-revise-2-COSP"
fname3 = "ERAI_ANN_climo.nc"

append = ".cam.h0.ANN.nc"

f1 = addfile(fdir+fname1+fdir_append+fname1+append,"r")
f2 = addfile(fdir+fname2+fdir_append+fname2+append,"r")
f3 = addfile(fdir_obs+fname3,"r")
f3_mask = addfile("./ERAI-mask.nc","r")

OMEGA_def = f1->OMEGA(0,{500},{-30:30},:)
OMEGA_new = f2->OMEGA(0,{500},{-30:30},:)
OMEGA_obs = f3->OMEGA(0,{500},{-30:30},:)

; Pa/s to mb/day
OMEGA_def = OMEGA_def*864.
OMEGA_new = OMEGA_new*864.


gw1 = f1->gw({-30:30})
gw3 = f3->gw({-30:30})

LANDFRAC = f1->LANDFRAC(0,{-30:30},:)

lsm = f3_mask->lsm(0,{-30:30},:)


OMEGA_def@_FillValue = 9.9e36
OMEGA_new@_FillValue = 9.9e36
OMEGA_obs@_FillValue = 9.9e36

w_def_up = where(OMEGA_def.lt.0.,OMEGA_def,OMEGA_def@_FillValue)
w_def_dn = where(OMEGA_def.gt.0.,OMEGA_def,OMEGA_def@_FillValue)
w_def_up_aave = wgt_areaave_Wrap(w_def_up,gw1,1.0,0)
w_def_dn_aave = wgt_areaave_Wrap(w_def_dn,gw1,1.0,0)

w_def_up_lnd = where(OMEGA_def.lt.0..and.LANDFRAC.gt.0.8,OMEGA_def,OMEGA_def@_FillValue)
w_def_up_ocn = where(OMEGA_def.lt.0..and.LANDFRAC.lt.0.8,OMEGA_def,OMEGA_def@_FillValue)
w_def_dn_lnd = where(OMEGA_def.gt.0..and.LANDFRAC.gt.0.8,OMEGA_def,OMEGA_def@_FillValue)
w_def_dn_ocn = where(OMEGA_def.gt.0..and.LANDFRAC.lt.0.8,OMEGA_def,OMEGA_def@_FillValue)
w_def_up_lnd_aave = wgt_areaave_Wrap(w_def_up_lnd,gw1,1.0,0)
w_def_up_ocn_aave = wgt_areaave_Wrap(w_def_up_ocn,gw1,1.0,0)
w_def_dn_lnd_aave = wgt_areaave_Wrap(w_def_dn_lnd,gw1,1.0,0)
w_def_dn_ocn_aave = wgt_areaave_Wrap(w_def_dn_ocn,gw1,1.0,0)

cir_intensity_def = w_def_dn_aave - w_def_up_aave
cir_intensity_def_lnd = w_def_dn_lnd_aave - w_def_up_lnd_aave
cir_intensity_def_ocn = w_def_dn_ocn_aave - w_def_up_ocn_aave

;print(cir_intensity_def+"   "+cir_intensity_def_lnd+"   "+cir_intensity_def_ocn)

;=================
w_new_up = where(OMEGA_new.lt.0.,OMEGA_new,OMEGA_new@_FillValue)
w_new_dn = where(OMEGA_new.gt.0.,OMEGA_new,OMEGA_new@_FillValue)
w_new_up_aave = wgt_areaave_Wrap(w_new_up,gw1,1.0,0)
w_new_dn_aave = wgt_areaave_Wrap(w_new_dn,gw1,1.0,0)

w_new_up_lnd = where(OMEGA_new.lt.0..and.LANDFRAC.gt.0.8,OMEGA_new,OMEGA_new@_FillValue)
w_new_up_ocn = where(OMEGA_new.lt.0..and.LANDFRAC.lt.0.8,OMEGA_new,OMEGA_new@_FillValue)
w_new_dn_lnd = where(OMEGA_new.gt.0..and.LANDFRAC.gt.0.8,OMEGA_new,OMEGA_new@_FillValue)
w_new_dn_ocn = where(OMEGA_new.gt.0..and.LANDFRAC.lt.0.8,OMEGA_new,OMEGA_new@_FillValue)
w_new_up_lnd_aave = wgt_areaave_Wrap(w_new_up_lnd,gw1,1.0,0)
w_new_up_ocn_aave = wgt_areaave_Wrap(w_new_up_ocn,gw1,1.0,0)
w_new_dn_lnd_aave = wgt_areaave_Wrap(w_new_dn_lnd,gw1,1.0,0)
w_new_dn_ocn_aave = wgt_areaave_Wrap(w_new_dn_ocn,gw1,1.0,0)

cir_intensity_new = w_new_dn_aave - w_new_up_aave
cir_intensity_new_lnd = w_new_dn_lnd_aave - w_new_up_lnd_aave
cir_intensity_new_ocn = w_new_dn_ocn_aave - w_new_up_ocn_aave

;print(cir_intensity_new+"   "+cir_intensity_new_lnd+"   "+cir_intensity_new_ocn)
;=================

w_obs_up = where(OMEGA_obs.lt.0.,OMEGA_obs,OMEGA_obs@_FillValue)
w_obs_dn = where(OMEGA_obs.gt.0.,OMEGA_obs,OMEGA_obs@_FillValue)
w_obs_up_aave = wgt_areaave_Wrap(w_obs_up,gw3,1.0,0)
w_obs_dn_aave = wgt_areaave_Wrap(w_obs_dn,gw3,1.0,0)

w_obs_up_lnd = where(OMEGA_obs.lt.0..and.lsm.gt.0.8,OMEGA_obs,OMEGA_obs@_FillValue)
w_obs_up_ocn = where(OMEGA_obs.lt.0..and.lsm.lt.0.8,OMEGA_obs,OMEGA_obs@_FillValue)
w_obs_dn_lnd = where(OMEGA_obs.gt.0..and.lsm.gt.0.8,OMEGA_obs,OMEGA_obs@_FillValue)
w_obs_dn_ocn = where(OMEGA_obs.gt.0..and.lsm.lt.0.8,OMEGA_obs,OMEGA_obs@_FillValue)
w_obs_up_lnd_aave = wgt_areaave_Wrap(w_obs_up_lnd,gw3,1.0,0)
w_obs_up_ocn_aave = wgt_areaave_Wrap(w_obs_up_ocn,gw3,1.0,0)
w_obs_dn_lnd_aave = wgt_areaave_Wrap(w_obs_dn_lnd,gw3,1.0,0)
w_obs_dn_ocn_aave = wgt_areaave_Wrap(w_obs_dn_ocn,gw3,1.0,0)

cir_intensity_obs = w_obs_dn_aave - w_obs_up_aave
cir_intensity_obs_lnd = w_obs_dn_lnd_aave - w_obs_up_lnd_aave
cir_intensity_obs_ocn = w_obs_dn_ocn_aave - w_obs_up_ocn_aave

print("case		total circ.	land circ.	ocean circ.")
print("Def"+"		"+cir_intensity_def+"		"+cir_intensity_def_lnd+"		"+cir_intensity_def_ocn)
print("PDF"+"		"+cir_intensity_new+"		"+cir_intensity_new_lnd+"		"+cir_intensity_new_ocn)
print("ERA"+"		"+cir_intensity_obs+"		"+cir_intensity_obs_lnd+"		"+cir_intensity_obs_ocn)





;printVarSummary(w_def_up_aave)


end 
