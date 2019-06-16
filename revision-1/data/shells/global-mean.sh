

#casename=(FC5_f09f09_micmac2rad_nonml_rcon)
#casename=(B1850C5_mic2mac2rad_c0_0.045)
casename=(his_200 B1850C5_f19g16_mac2)

ncase=${#casename[@]}
echo $ncase

for icase in `seq 0 $[$ncase-1]`
do
echo ${casename[icase]}

#casedir=/home/lyl/WORK1/lyl_cesm1_2_1/archive/${casename[icase]}/atm/hist/
casedir=/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision/data/coupled/${casename[icase]}/

echo $casedir

#workdir=/home/lyl/WORK4/qinyi/my-diag/${casename[icase]}/
workdir=/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision/data/output/${casename[icase]}/
echo $workdir

if [ ! -d "$workdir" ]; then
mkdir $workdir
fi

int_year=1
end_year=12

echo ${end_year}

int_year_4d=`printf %04d $int_year`
end_year_4d=`printf %04d $end_year`

echo $int_year
echo $end_year

cd $workdir

ann_mean=true
stitch_file=true

if [ ${ann_mean} == "true" ] ; then
echo "qinyi"

	for i in `seq $int_year $end_year`;
	do
	echo $i
	year=`printf %04d $i`
	echo $year
	
	# ann mean
	ncra -O  $casedir/${casename[icase]}.cam.h0.${year}-??.nc $workdir/${casename[icase]}.${year}.ann.mean.nc
	
	# global ann mean with gaussian weighting and ocean mask.
	ncwa -O -a lon,lat -w gw $workdir/${casename[icase]}.${year}.ann.mean.nc $workdir/${casename[icase]}.${year}.glob.avg.ann.mean.nc
	
	done  # i
fi

if [ ${stitch_file} == "true" ]; then
echo "qinyi-1"
	#stitching all time series into one files
	ncrcat -O ${casename[icase]}.????.glob.avg.ann.mean.nc ${casename[icase]}.${int_year_4d}-${end_year_4d}.glob.avg.ann.mean.nc
fi


done # icase

echo "Well done!"
