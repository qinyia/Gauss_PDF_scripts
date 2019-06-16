#!/bin/bash

case_name=(new-cldfrac16-1d-MG15-revise-COSP)

casedir=/home/lyl/WORK1/lyl_cesm1_2_1/archive/$case_name/atm/hist

year=(0002 0003 0004 0005 0006)
nyear=${#year[*]}
echo $nyear

cd $casedir

#for (( iyr=0;iyr<"$nyear";iyr=iyr+1 ))
#
#do
#echo ${year[$iyr]}
#
#ncra -O $case_name.cam.h0.${year[$iyr]}-??.nc $case_name.cam.h0.${year[$iyr]}.nc
#
#done

ncra -O *0002.nc *0003.nc *0004.nc *0005.nc *0006.nc $case_name.cam.h0.ANN.nc


