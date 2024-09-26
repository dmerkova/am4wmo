import numpy as np
import pandas as pd
import sys

MONTH=sys.argv[1]
YYYY=sys.argv[2]

#dy=pd.read_csv('w233.csv',names=["sid","level","NA","NR","TB", "TSTD" ],skiprows=2 )
dy=pd.read_csv('w233.csv',names=["sid","level","NA","TB", "TSTD","NR" ],skiprows=2 )
#dy1=pd.read_csv('w233.csv',names=["sid","level","NA","TB", "TSTD","NR" ],skiprows=2 )
#dy=dy1.iloc[:,[0,1,2,5,3,4]]
dys=dy.sort_values(by=['TSTD'],ascending=False)

dz=dys[((dys['level']=='high')&((dys['TSTD']>10)|(dys['TB']>2.5)))|((dys['level']=='low')&((dys['TSTD']>10)|(dys['TB']>3)))|((dys['level']=='mid')&((dys['TSTD']>8)|(dys['TB']>2.5)))]
#dz=dys[(((dys['level']==' high ')|(dys['level']==' mid '))&((dys['std']>3)|(dys['bias']>2)))|((dys['level']==' low ')&((dys['std']>4)|(dys['bias']>3)))]

original_stdout = sys.stdout # Save a reference to the original standard output
with open('wacar.txt','w') as f:
    sys.stdout = f # Change the standard output to the file we created.
    print('           ACAR Statistics Versus the NCEP Guess')
    print('                  '+ MONTH + ' ' + YYYY)
    print('Suspect Wind                  ')
    #print (dz.sid.to_string(index=False))
    #print (dz.to_string(index=False))
    print (dz.to_markdown())

with open('sus-wacar.txt','w') as f:
    sys.stdout = f # Change the standard output to the file we created.
    print (dz.sid.to_string(index=False))

sys.stdout = original_stdout # Reset the standard output to its original value


#####################################
# statistics
#####################################
#low: prs >= 700
#mid: prs >= 400 & prs < 700 
#high:prs <= 400 

#Minimum Counts needed for suspect criterion:
#              LOW 20; MID 50; HIGH 50
#Suspect Criteria
# Temperature Bias: LOW  3.0; MID 2.0; HIGH  2.0 (deg. C)
# Temperature  RMS: LOW  4.0; MID 3.0; HIGH  3.0 (deg. C)
# Wind Speed  Bias: LOW  3.0; MID 2.5; HIGH  2.5 (m/s)
# Wind         RMS: LOW 10.0; MID 8.0; HIGH 10.0 (m/s)



