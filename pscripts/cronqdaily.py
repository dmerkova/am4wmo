import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from netCDF4 import Dataset
from netCDF4 import chartostring
import sys


mydate=sys.argv[1]
print(mydate)
mymonth=mydate[4:6]
myncfile = '/lfs/h2/emc/ptmp/ashley.stanfield/CRON/wdqms/diagfiles/diag_conv_q_ges.'+mydate+'.nc4'


fh = Dataset(myncfile, mode='r')
obstype=fh.variables['Observation_Type']
lats=fh.variables['Latitude']
lons=fh.variables['Longitude']
prs=fh.variables['Pressure']
stid=fh.variables['Station_ID']
obs=fh.variables['Observation']
omf=fh.variables['Obs_Minus_Forecast_adjusted']
stnids=[i.tobytes(fill_value='/////', order='C') for i in stid]
stnids = np.array([''.join(i.decode('UTF-8', 'ignore').split()) for i in stnids])
iuse=fh.variables['Analysis_Use_Flag'][:]
ipuse=fh.variables['Analysis_Use_Flag'][:]
dfi=pd.DataFrame(iuse,columns=['iuse'])
df1=pd.DataFrame(data=lons[:],columns=['lon'])
df2=pd.DataFrame(data=lats[:],columns=['lat'])
df3=pd.DataFrame(data=obstype[:],columns=['obstype'])
#df4=pd.DataFrame(data=obs[:],columns=['obs'])
df5=pd.DataFrame(data=stnids[:],columns=['sid'])
df6=pd.DataFrame(data=prs[:],columns=['prs'])
df7=pd.DataFrame(data=obs[:],columns=['obs'])
df8=pd.DataFrame(data=omf[:],columns=['omf'])
frames = [df1,dfi,df2, df3,df5,df6,df8,df7]
df = pd.concat(frames,axis=1)
df133=df[(df.obstype==133)]    # US AMDARS and ADS-C


df133.to_csv('/lfs/h2/emc/obsproc/noscrub/dagmar.merkova/MONaircft/data/'+mymonth+'/d133-q'+mydate+'.csv')
#####################################
# statistics
#####################################
#low=d2a[(d2a.prs > '700.01')]
#mid=d2a[(d2a.prs > '400.01') & (d2a.prs < '700' )]
#high=d2a[(d2a.prs <'400' )]


