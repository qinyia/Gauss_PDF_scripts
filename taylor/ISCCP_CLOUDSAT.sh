
current_dir=/home/lyl/WORK3/qinyi/scripts/newcldfrac/taylor/ISCCP_CLOUDSAT_data/
in_data_dir=/home/lyl/WORK3/qinyi/scripts/amwg_diag/obs_data/

cd $current_dir


month=(01 02 03 04 05 06 07 08 09 10 11 12)
nmonth=${#month[*]}

##################ISCCP

for (( i=0;i<"$nmonth";i=i+1 ))
do
echo ${month[$i]}

ncks --mk_rec_dmn time -O $in_data_dir/ISCCP_${month[i]}_climo.nc $current_dir/ISCCP_${month[i]}_climo_v1.nc

ncatted -O -a units,time,o,c,"hours since 1983-01-01 0" $current_dir/ISCCP_${month[i]}_climo_v1.nc $current_dir/ISCCP_${month[i]}_climo_v2.nc 

##################CLOUDSAT

###first, add time dimension to all variables expect "gw"
ncecat -O -u time -x -v gw $in_data_dir/CLOUDSAT_${month[i]}_climo.nc CLOUDSAT_${month[i]}_climo_v1.nc
###second, append "gw" from default file to the new file
ncks -A -v gw $in_data_dir/CLOUDSAT_${month[i]}_climo.nc CLOUDSAT_${month[i]}_climo_v1.nc

done

ncrcat -O ISCCP_??_climo_v2.nc  ISCCP_MONTHS_climo.nc

ncrcat -O CLOUDSAT_??_climo_v1.nc CLOUDSAT_MONTHS_climo.nc

cp ISCCP_MONTHS_climo.nc ../
cp CLOUDSAT_MONTHS_climo.nc ../

