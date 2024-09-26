#!/bin/sh
#
set -x
# check if you are on dev comuter continue, if not exit
now_on=`cat /etc/cluster_name`
now_backup=`cat /lfs/h1/ops/prod/config/prodmachinefile | grep backup  | cut -d ":" -f 2 `
now_primary=`cat /lfs/h1/ops/prod/config/prodmachinefile | grep primary | cut -d ":" -f 2 `
if test "$now_on" = "$now_primary" 
then    
	exit
fi
###############################
export NDATE=/apps/ops/prod/nco/core/prod_util.v2.0.14/exec/ndate
begin=`ndate -288`
ending=`ndate -48`
beg=`echo $begin|cut -c1-8`
nyear=`echo $begin|cut -c1-4`
i=${beg}00
endd=`echo $ending|cut -c1-8`
iend=${endd}18
echo $endd
echo $iend
pwd

WORKDIR=/lfs/h2/emc/obsproc/noscrub/dagmar.merkova/wmo_stats
WORKDIRSRC=/lfs/h2/emc/obsproc/noscrub/dagmar.merkova/GIT/play/aircraft-monitoring4wmo
PSCRIPTS=$WORKDIRSRC/pscripts
FIX=$WORKDIRSRC/fix

cd $WORKDIR
# load python env
module load python/3.8.6
module use /lfs/h1/mdl/nbm/save/apps/modulefiles
module load python-modules/3.8.6
export PYTHONPATH=$PYTHONPATH:/lfs/h1/mdl/nbm/save/apps/python-modules/apps/spack/python/3.8.6/intel/19.1.3.304/pjn2nzkjvqgmjw4hmyz43v5x4jbxjzpk/lib/python3.8/site-packages:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/py-ncepbufr:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/pandas:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/py-ncepbufr/:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/NCEPLIBS-bufr/python/ncepbufr:/u/dagmar.merkova/.local/lib/python3.6/site-packages
#
rm -rf $WORKDIR/10days
mkdir 10days
#copy all files you need
while [ $i -le ${iend} ]
do
     echo $i
#     datum=`echo $i|cut -c1-8`
     mm=`echo $i|cut -c5-6`
     cp  $WORKDIR/$mm/d131-t${i}.csv $WORKDIR/10days/.
     cp  $WORKDIR/$mm/d133-t${i}.csv $WORKDIR/10days/.
     cp  $WORKDIR/$mm/d133-q${i}.csv $WORKDIR/10days/.
     cp  $WORKDIR/$mm/d231-w${i}.csv $WORKDIR/10days/.
     cp  $WORKDIR/$mm/d233-w${i}.csv $WORKDIR/10days/.
     i=`/u/dagmar.merkova/bin/ndate 06  $i`
     wait
done

cd 10days

echo "10 day statistics: " $begin " - " $ending >datum
echo "Disclaimer: The statistics presented here are calculated based on data from our development mashine and may not reflect the most recent updates or changes. If you notice that the statistics appear outdated or inaccurate, please reach out to us <obsproc_support@noaa.gov>  for assistance in verifying and obtaining the latest information." >> datum

cat d131-t* |grep -v obstype >dx1
cat $FIX/headert.txt dx1 >tdaily131.csv
cat d133-t* |grep -v obstype >dx1
cat $FIX/headert.txt dx1 >tdaily133.csv
cat d133-q* |grep -v obstype >dx1
cat $FIX/headerq.txt dx1 >qdaily133.csv
cat d231-w* |grep -v obstype >dx1
cat $FIX/headerw.txt dx1 >wdaily231.csv
cat d233-w* |grep -v obstype >dx1
cat $FIX/headerw.txt dx1 >wdaily233.csv


## script to read input files, cumulate data and produce statistics by aircraft tailnumber
python $PSCRIPTS/tsums.py 131
python $PSCRIPTS/tsums.py 133
python $PSCRIPTS/wsums.py 231
python $PSCRIPTS/wsums.py 233
python $PSCRIPTS/qsums.py 133

# now calculate suspects

python $PSCRIPTS/q133acars-stats.py 10day stats
python $PSCRIPTS/t133acars-stats.py 10day stats
python $PSCRIPTS/w233acars-stats.py 10day stats

python $PSCRIPTS/w233suspect.py 10day stats
python $PSCRIPTS/t133suspect.py 10day stats

python $PSCRIPTS/w231suspect.py 10day stats
python $PSCRIPTS/t131suspect.py 10day stats

#putting reports for ACAR together
echo "            ACAR Statistics Versus the NCEP Guess" >acarspom1
echo "                10 day statistics" >pom2
tail -n+6 wacar-stats.txt > w233pom3
cat datum acarspom1 pom2 $FIX/acarswnd.txt  w233pom3 > $WORKDIR/WMO_10/acarswnd

tail -n+6 tacar-stats.txt > t133pom3
cat datum acarspom1 pom2 $FIX/acarstmp.txt  t133pom3 > $WORKDIR/WMO_10/acarstmp

tail -n+6 qacar-stats.txt > q133pom3
cat datum acarspom1 pom2 $FIX/acarsmst.txt q133pom3 > $WORKDIR/WMO_10/acarsmst

cat datum acarspom1 pom2 $FIX/acarsstd.txt acar.txt wacar.txt >  $WORKDIR/WMO_10/acarsstd




echo "            AMDAR Statistics Versus the NCEP Guess" >amdarspom1
echo "                10 day statistics " >pom2
echo "Suspect winds " >pom3
tail -n+5 amdar.txt>t131pom3
tail -n+3 wamdar.txt>w231pom3
cat datum amdarspom1 pom2 $FIX/amdars.txt t131pom3 pom3 w231pom3 > $WORKDIR/WMO_10/amdar

qsub <  $WORKDIRSRC/put2rzdm10day.sh

