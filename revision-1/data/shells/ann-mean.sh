
#casename=(new-cldfrac16-1d-MG15-revise-2-COSP)
#casename=(FC5_f09f09_MG15_COSP)
#casename=(FC5_f19f19_MG15_mac3_cosp)
casename=(his_200 B1850C5_f19g16_mac2)


ncase=${#casename[@]}
echo $ncase

for icase in `seq 0 $[$ncase-1]`
do
echo ${casename[icase]}

casedir=/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision/data/coupled/${casename[icase]}/
echo $casedir

workdir=/home/lyl/WORK3/qinyi/scripts/newcldfrac/revision/data/output/${casename[icase]}/
echo $workdir

if [ ! -d "$workdir" ]; then
mkdir $workdir
fi

int_year=2
end_year=6

echo ${end_year}

int_year_4d=`printf %04d $int_year`
end_year_4d=`printf %04d $end_year`

echo $int_year
echo $end_year

cd $workdir

ann_mean=true
climo_mean=true
stitch_file=false

if [ ${ann_mean} == "true" ] ; then
echo "ann_mean"

	for i in `seq $int_year $end_year`;
	do
	echo $i
	year=`printf %04d $i`
	echo $year
	
	# ann mean
	ncra -O  $casedir/${casename[icase]}.cam.h0.${year}-??.nc $workdir/${casename[icase]}.cam.h0.${year}.nc

	done  # i
fi

if [ ${climo_mean} == "true" ] ; then
echo "climo_mean"

	ncra -O $workdir/${casename[icase]}.cam.h0.????.nc $workdir/${casename[icase]}.cam.h0.ANN.nc

fi

if [ ${stitch_file} == "true" ]; then
echo "stitch_file"
	#stitching all time series into one files
	ncrcat -O ${casename[icase]}.cam.h0.????.nc ${casename[icase]}.cam.h0.${int_year_4d}-${end_year_4d}.nc
fi

done # icase

echo "Well done!"
