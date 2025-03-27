import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from netCDF4 import Dataset
from netCDF4 import chartostring
import sys


mydate=sys.argv[1]
print(mydate)
#mydate='2022033000'
mymonth=mydate[4:6]
myncfile = '/lfs/h2/emc/ptmp/ashley.stanfield/CRON/wdqms/diagfiles/diag_conv_t_ges.'+mydate+'.nc4'
#myncfile = '/lfs/h2/emc/obsproc/noscrub/dagmar.merkova/data/'+mymonth+'/diag_conv_t_ges.'+mydate+'.nc4'

fh = Dataset(myncfile, mode='r')
obstype=fh.variables['Observation_Type']
lats=fh.variables['Latitude']
lons=fh.variables['Longitude']
prs=fh.variables['Pressure']
stid=fh.variables['Station_ID']
obs=fh.variables['Observation']
omf=fh.variables['Obs_Minus_Forecast_adjusted']
pof=fh.variables['Data_Pof']
try:
        stnids=chartostring(stid[:])
except:
        stnids=[i.tobytes(fill_value='/////', order='C') for i in stid]
        stnids = np.array([''.join(i.decode('UTF-8', 'ignore').split()) for i in stnids])
iuse=fh.variables['Analysis_Use_Flag']
puse=fh.variables['Prep_Use_Flag']
prepqc=fh.variables['Prep_QC_Mark'] 
setupqc=fh.variables['Setup_QC_Mark']
dfi=pd.DataFrame(iuse[:],columns=['iuse'])
dfp=pd.DataFrame(puse[:],columns=['puse'])
dfpqc=pd.DataFrame(prepqc[:],columns=['prepqc'])
dfsqc=pd.DataFrame(setupqc[:],columns=['setupqc'])
df1=pd.DataFrame(data=lons[:],columns=['lon'])
df2=pd.DataFrame(data=lats[:],columns=['lat'])
df3=pd.DataFrame(data=obstype[:],columns=['obstype'])
#df4=pd.DataFrame(data=obs[:],columns=['obs'])
df5=pd.DataFrame(data=stnids[:],columns=['sid'])
df6=pd.DataFrame(data=prs[:],columns=['prs'])
df7=pd.DataFrame(data=obs[:],columns=['obs'])
df8=pd.DataFrame(data=omf[:],columns=['omf'])
df9=pd.DataFrame(data=pof[:],columns=['pof'])
frames = [df1,df2, df3,df5,df6,df8,df7,df9,dfi,dfp,dfsqc,dfpqc]
df = pd.concat(frames,axis=1)
df131=df[(df.obstype==131)]    # non US AMDARS and ADS-C
df133=df[(df.obstype==133)]    # US AMDARS and ADS-C
#df131=df[(df.obstype==131) & (df.iuse==1.0)]    # non US AMDARS and ADS-C
#df133=df[(df.obstype==133) & (df.iuse==1.0)]    # US AMDARS and ADS-C


#df131.to_csv('d131-t'+mydate+'.csv')
df131.to_csv('/lfs/h2/emc/obsproc/noscrub/dagmar.merkova/MONaircft/data/'+mymonth+'/d131-t'+mydate+'.csv')
#df133.to_csv('d133-t'+mydate+'.csv')
df133.to_csv('/lfs/h2/emc/obsproc/noscrub/dagmar.merkova/MONaircft/data/'+mymonth+'/d133-t'+mydate+'.csv')
#####################################
# statistics
#####################################
#low=d2a[(d2a.prs > '700.01')]
#mid=d2a[(d2a.prs > '400.01') & (d2a.prs < '700' )]
#high=d2a[(d2a.prs <'400' )]


