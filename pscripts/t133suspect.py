import numpy as np
import pandas as pd
import sys

MONTH=sys.argv[1]
YYYY=sys.argv[2]

#aircraft=sys.argv[1]
#myfile='t'+aircraft+'.csv'
myfile='t133.csv'
dy=pd.read_csv(myfile,names=["sid","level","NA","TB", "TSTD","NR" ],skiprows=2 )
dys=dy.sort_values(by=['TSTD'],ascending=False)

dz=dys[(((dys['level']=='high')|(dys['level']=='mid'))&((dys['TSTD']>3)|(dys['TB']>2)))|((dys['level']=='low')&((dys['TSTD']>4)|(dys['TB']>3)))]
#dz=dys[(((dys['level']==' high ')|(dys['level']==' mid '))&((dys['std']>3)|(dys['bias']>2)))|((dys['level']==' low ')&((dys['std']>4)|(dys['bias']>3)))]

original_stdout = sys.stdout # Save a reference to the original standard output
with open('acar.txt','w') as f:
    sys.stdout = f # Change the standard output to the file we created.
    print('           ACARS Statistics Versus the NCEP Guess')
    print('                  '+ MONTH + ' ' + YYYY)
    print('Suspect Temperatures                  ')
    #print (dz.sid.to_string(index=False))
    #print (dz.to_string(index=False))
    print (dz.to_markdown())

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



