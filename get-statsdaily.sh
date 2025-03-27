#!/bin/sh
set -x
export NDATE=/apps/ops/prod/nco/core/prod_util.v2.0.14/exec/ndate
begin=`ndate -24`
beg=`echo $begin|cut -c1-8`
i=${beg}00
end=`ndate 24  $i`
pwd
cd $HOME
# load python env
module load python/3.8.6
module use /lfs/h1/mdl/nbm/save/apps/modulefiles
module load python-modules/3.8.6
export PYTHONPATH=$PYTHONPATH:/lfs/h1/mdl/nbm/save/apps/python-modules/apps/spack/python/3.8.6/intel/19.1.3.304/pjn2nzkjvqgmjw4hmyz43v5x4jbxjzpk/lib/python3.8/site-packages:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/py-ncepbufr:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/pandas:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/py-ncepbufr/:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/NCEPLIBS-bufr/python/ncepbufr:/u/dagmar.merkova/.local/lib/python3.6/site-packages


while [ $i -le ${end} ] 
do
      echo $i 
      #datum=`echo $i|cut -c1-8`
      #hh=`echo $i|cut -c9-10`
      # i=`expr $i + 1`
      #echo "kuk: "$i,${datum},$hh
      python /lfs/h2/emc/obsproc/noscrub/${USER}/am4wmo/pscripts/crontdaily.py $i
      python /lfs/h2/emc/obsproc/noscrub/${USER}/am4wmo/pscripts/cronwdaily.py $i
      python /lfs/h2/emc/obsproc/noscrub/${USER}/am4wmo/pscripts/cronqdaily.py $i

      i=`ndate 6  $i`
      echo $i
      wait
done

