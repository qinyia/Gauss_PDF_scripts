load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./functions_read_file.ncl"
load "./functions_calculate.ncl"
load "./functions_plot.ncl"

begin

;==========read data and calculate RH and LTS
fdir = "/home/lyl/WORK3/qinyi/data/NEWCLDFRAC/"

RELHUM_old = read_RELHUM(fdir,"F_MG1.5_f09f09")
RELHUM_new = read_RELHUM(fdir,"new-cldfrac7-1d")

RELHUM_old_1000 = RELHUM_old(:,29,:,:)
RELHUM_new_1000 = RELHUM_new(:,29,:,:)


T_old = read_T(fdir,"F_MG1.5_f09f09")
T_new = read_T(fdir,"new-cldfrac7-1d")

;level = read_level(fdir,"F_MG1.5_f09f09")
a = addfile(fdir+"F_MG1.5_f09f09/atm/hist/F_MG1.5_f09f09.cam.h0.0002-01.nc","r")
level = a->lev
gw1 = a->gw

P = conform(T_old,level,1)        ;make p same shape/rank/size as T

P0 = 1000.0
;======calculate potential temperature
theta_old = cal_theta(T_old,P,P0)
theta_new = cal_theta(T_new,P,P0)


;=====calculate LTS

LTS_old = theta_old(:,{700},:,:)-theta_old(:,29,:,:)
LTS_new = theta_new(:,{700},:,:)-theta_new(:,29,:,:)
copy_VarCoords(theta_old(:,{700},:,:),LTS_old)
copy_VarCoords(theta_new(:,{700},:,:),LTS_new)



;==========Area Mean
;===== Four areas
;===Californian (20–30N, 120–130W)
RELHUM_old_Cal = wgt_areaave(RELHUM_old_1000(:,{20:30},{230:240}),gw1({20:30}),1.0,1)
RELHUM_new_Cal = wgt_areaave(RELHUM_new_1000(:,{20:30},{230:240}),gw1({20:30}),1.0,1)

LTS_old_Cal = wgt_areaave(LTS_old(:,{20:30},{230:240}),gw1({20:30}),1.0,1)
LTS_new_Cal = wgt_areaave(LTS_new(:,{20:30},{230:240}),gw1({20:30}),1.0,1)

;===Peruvian    (10–20S, 80–90W)
RELHUM_old_Per = wgt_areaave(RELHUM_old_1000(:,{-20:-10},{270:280}),gw1({-20:-10}),1.0,1)
RELHUM_new_Per = wgt_areaave(RELHUM_new_1000(:,{-20:-10},{270:280}),gw1({-20:-10}),1.0,1)

LTS_old_Per = wgt_areaave(LTS_old(:,{-20:-10},{270:280}),gw1({-20:-10}),1.0,1)
LTS_new_Per = wgt_areaave(LTS_new(:,{-20:-10},{270:280}),gw1({-20:-10}),1.0,1)


;===Namibian    (10–20S, 0 –10E)
RELHUM_old_Nam = wgt_areaave(RELHUM_old_1000(:,{-20:-10},{0:10}),gw1({-20:-10}),1.0,1)
RELHUM_new_Nam = wgt_areaave(RELHUM_new_1000(:,{-20:-10},{0:10}),gw1({-20:-10}),1.0,1)

LTS_old_Nam = wgt_areaave(LTS_old(:,{-20:-10},{0:10}),gw1({-20:-10}),1.0,1)
LTS_new_Nam = wgt_areaave(LTS_new(:,{-20:-10},{0:10}),gw1({-20:-10}),1.0,1)


;===Australian  (25–35S, 95–105E)
RELHUM_old_Aus = wgt_areaave(RELHUM_old_1000(:,{-35:-25},{255:265}),gw1({-35:-25}),1.0,1)
RELHUM_new_Aus = wgt_areaave(RELHUM_new_1000(:,{-35:-25},{255:265}),gw1({-35:-25}),1.0,1)

LTS_old_Aus = wgt_areaave(LTS_old(:,{-35:-25},{255:265}),gw1({-35:-25}),1.0,1)
LTS_new_Aus = wgt_areaave(LTS_new(:,{-35:-25},{255:265}),gw1({-35:-25}),1.0,1)


;===Canarian    (15–25N, 25–35W)
RELHUM_old_Can = wgt_areaave(RELHUM_old_1000(:,{15:25},{325:335}),gw1({15:25}),1.0,1)
RELHUM_new_Can = wgt_areaave(RELHUM_new_1000(:,{15:25},{325:335}),gw1({15:25}),1.0,1)

LTS_old_Can = wgt_areaave(LTS_old(:,{15:25},{325:335}),gw1({15:25}),1.0,1)
LTS_new_Can = wgt_areaave(LTS_new(:,{15:25},{325:335}),gw1({15:25}),1.0,1)

printVarSummary(LTS_old_Can)


;==========Separate into different Bins





end
