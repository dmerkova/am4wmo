#!/bin/bash
#PBS -N obs_transfers_wcoss2
#PBS -j oe
#PBS -A GFS-DEV 
##PBS -A OBSPROC-T2O
#PBS -q dev_transfer
#PBS -l place=vscatter,select=1:ncpus=1:mem=5GB
#PBS -l walltime=0:20:00
#PBS -l debug=true

set -x
#-- Setup --export Pdate=$(date +'%Y%m%d' -d "1 day ago")
#RZDM Variables
#
export WEBARCH=/home/people/emc/ftp/WMO_10d
#export WEBDIR=/home/people/emc/ftp/wmoabo10
export WSUSER=dmerkova
export WS=emcrzdm.ncep.noaa.gov

#scp /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_10/*  ${WSUSER}@${WS}:${WEBDIR}
ssh -l $WSUSER $WS " chmod 755 ${WEBDIR}/*"

scp /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_10/*  ${WSUSER}@${WS}:${WEBARCH}
ssh -l $WSUSER $WS " chmod 755 ${WEBARCH}/*"
