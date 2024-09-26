import numpy as np
import pandas as pd
import sys
MONTH=sys.argv[1]
YYYY=sys.argv[2]

#aircraft=sys.argv[1]
#myfile='t'+aircraft+'.csv'
myfile='t133.csv'
dy1=pd.read_csv(myfile,names=["sid","level","NA","TB", "TSTD","NR" ],skiprows=2 )
dy=dy1.iloc[:,[0,1,2,5,3,4]]
dys=dy.sort_values(by=['TSTD'],ascending=False)

dz=pd.pivot_table(dys,values=['NA','NR','TB','TSTD'], index='sid', columns='level',fill_value=0)


original_stdout = sys.stdout # Save a reference to the original standard output
with open('tacar-stats.txt','w') as f:
    sys.stdout = f # Change the standard output to the file we created.
    print('           ACARS Statistics Versus the NCEP Guess')
    print('                  '+ MONTH + ' ' + YYYY)
    #print (dz.sid.to_string(index=False))
    print (dz.to_string(index=True))

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

#AFTER THAT NEED SOME REFORMATING
#awk '{printf "%8s %10.6f %10.6f %10.6f %10.6f %10.6f %10.6f %7.1f %7.1f %7.1f %7.1f %7.1f %7.1f  \n", $1,$8,$9,$10,$11,$12,$13,$2,$3,$4,$5,$6,$7}' tacar-stats.txt >temp



