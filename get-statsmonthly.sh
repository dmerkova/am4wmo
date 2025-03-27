#!/bin/sh
#
set -x
export NDATE=/apps/ops/prod/nco/core/prod_util.v2.0.14/exec/ndate
begin=`ndate -24`
begin=20240831
beg=`echo $begin|cut -c1-8`
nyear=`echo $begin|cut -c1-4`
namemonth=$(date -d "last month" +"%B")
nmonth=$(date -d "last month" +"%m")
#namemonth=`date -d $beg +%B`
#nmonth=`echo $begin|cut -c5-6`
i=${beg}00
end=`ndate 24  $i`
pwd
WORKDIR=/lfs/h2/emc/obsproc/noscrub/dagmar.merkova/MONaircft
WORKDIRSRC=$WORKDIR/src
WORKDIRSRC=$WORKDIR
cd $WORKDIR
# load python env
module load python/3.8.6
module use /lfs/h1/mdl/nbm/save/apps/modulefiles
module load python-modules/3.8.6
export PYTHONPATH=$PYTHONPATH:/lfs/h1/mdl/nbm/save/apps/python-modules/apps/spack/python/3.8.6/intel/19.1.3.304/pjn2nzkjvqgmjw4hmyz43v5x4jbxjzpk/lib/python3.8/site-packages:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/py-ncepbufr:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/pandas:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/py-ncepbufr/:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/NCEPLIBS-bufr/python/ncepbufr:/u/dagmar.merkova/.local/lib/python3.6/site-packages

cd data/$nmonth
#delete first data from previous year 
find /path/to/directory -type f -mtime +336 -exec rm {} \;
#join one variable into 1 file
cat d131-t* |grep -v obstype >dx1
cat ../../src/headert.txt dx1 >tdaily131.csv
cat d133-t* |grep -v obstype >dx1
cat ../../src/headert.txt dx1 >tdaily133.csv
cat d133-q* |grep -v obstype >dx1
cat ../../src/headerq.txt dx1 >qdaily133.csv
cat d231-w* |grep -v obstype >dx1
cat ../../src/headerw.txt dx1 >wdaily231.csv
cat d233-w* |grep -v obstype >dx1
cat ../../src/headerw.txt dx1 >wdaily233.csv

## script to read input files, cumulate data and produce statistics by aircraft tailnumber
python $WORKDIRSRC/tsums.py 131
python $WORKDIRSRC/tsums.py 133
python $WORKDIRSRC/wsums.py 231
python $WORKDIRSRC/wsums.py 233
python $WORKDIRSRC/qsums.py 133

# now calculate suspects

python $WORKDIRSRC/q133acars-stats.py $namemonth $nyear
python $WORKDIRSRC/t133acars-stats.py $namemonth $nyear
python $WORKDIRSRC/w233acars-stats.py $namemonth $nyear

python $WORKDIRSRC/w231suspect.py $namemonth $nyear
python $WORKDIRSRC/t131suspect.py $namemonth $nyear

python $WORKDIRSRC/w233suspect.py $namemonth $nyear
python $WORKDIRSRC/t133suspect.py $namemonth $nyear

#putting reports together
echo "            ACAR Statistics Versus the NCEP Guess" >acarspom1
echo "               " $namemonth " " $nyear >pom2
tail -n+3 wacar-stats.txt > w233pom3
cat acarspom1 pom2 $WORKDIRSRC/src/acarswnd.txt  w233pom3 > /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_MONITOR/acarswnd.${nyear}${nmonth}.txt

tail -n+3 tacar-stats.txt > t133pom3
cat acarspom1 pom2 $WORKDIRSRC/src/acarstmp.txt  t133pom3 > /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_MONITOR/acarstmp.${nyear}${nmonth}.txt

tail -n+3 qacar-stats.txt > q133pom3
cat acarspom1 pom2 $WORKDIRSRC/src/acarsmst.txt q133pom3 > /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_MONITOR/acarsmst.${nyear}${nmonth}.txt

tail -n+3 acar.txt>t133pom3
tail -n+3 wacar.txt>w233pom3
cat acarspom1 pom2 $WORKDIRSRC/src/acarsstd.txt t133pom3 w233pom3 > /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_MONITOR/acarsstd.${nyear}${nmonth}.txt

echo "            AMDAR Statistics Versus the NCEP Guess" >amdarspom1
echo "               " $namemonth " " $nyear >pom2
tail -n+3 amdar.txt>t131pom3
tail -n+3 wamdar.txt>w231pom3
cat amdarspom1 pom2 $WORKDIRSRC/src/amdars.txt t131pom3 w231pom3 > /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_MONITOR/amdar.${nyear}${nmonth}.txt

echo "DONE"
