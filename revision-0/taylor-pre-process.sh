
case=(FC5_f09f09_MG15_COSP new-cldfrac16-1d-MG15-revise-2-COSP)

ncase=${#case[*]}

echo $ncase

for (( icase=0;icase<"$ncase";icase=icase+1 ))

do 
echo ${case[$icase]}

tmpdir=/home/lyl/WORK1/cesm1_2_1/amwg_diag/climo/${case[$icase]}/

ncrcat -O $tmpdir/${case[$icase]}_??_climo.nc $tmpdir/${case[$icase]}_MONTHS_climo.nc

done
