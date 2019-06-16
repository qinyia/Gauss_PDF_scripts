
casename=(new-cldfrac16-1d-MG15-revise-2-COSP)

project=cloud-sgm-relation
casedir=/home/lyl/WORK1/lyl_cesm1_2_1/archive/${casename}/atm/hist/
workdir=/home/lyl/WORK3/qinyi/mid-data/$project/

vars=(gw,CLOUD,sgm_tota,T,Q,CLDLOW,LANDFRAC,delta_q,aa,CLDLIQ)

if [ ! -d $workdir ]; then
	mkdir -p $workdir
fi

regrid=true

cd $workdir

# set my grid information
cat > mygrid << EOR
gridtype = lonlat
xsize = 144
ysize = 73
xfirst = 0
xinc = 2.5
yfirst = -90
yinc = 2.5
EOR

# extract necessary variables
ncks -O -v $vars $casedir/$casename.cam.h0.ANN.nc $casename.cam.h0.ANN.vars.nc

if [ ${regrid} == "true" ]; then
# interpolate from model grid to defined standard grid
# because gw is only one-dimension, it cannot be interpolated in CDO. so I eliminate it from the file first.
ncks -O -x -v gw $casename.cam.h0.ANN.vars.nc tmp.nc
cdo remapbil,mygrid tmp.nc ${casename[icase]}.cam.h0.ANN_regrid.nc
rm tmp.nc
fi
