import numpy as np
import pandas as pd
import sys

#aircraft=sys.argv[1]
aircraft='133'
myfile='qdaily'+aircraft+'.csv'
dx=pd.read_csv(myfile)
del dx["id"]

#####################################
# statistics
#####################################
#low=dx[(dx.prs > 700.0)]
#mid=dx[(dx.prs > 300.0) & (dx.prs <= 700 )]
#high=dx[(dx.prs <=300 )]

#g2a=dx.groupby("sid")
#g2a.omf.describe().sort_values('std',ascending=False)

#dx1=low
#dx1["omf"].groupby(dx1['sid']).mean()

#g2a=dx1["omf"].groupby(dx1['sid'])
#g2a.agg(["count","mean","std"])
#t2a=dx.agg(["count","mean","std"])
#t2a.sort_values('mean', ascending=False)

def prs2lev(p1):
   if (p1>700.0):
         lev1="low"
   if (p1<=300.0):
         lev1="high"
   if (p1>300.0) & (p1 <= 700.0):
         lev1="mid"
   return lev1

def iuse1(iu):
    if (iu>0):
        used=0
    if (iu<0):
        used=1
    return used

dx['lev']=dx.apply(lambda x: prs2lev(x['prs']),axis=1)
dx['used']=dx.apply(lambda x: iuse1(x['iuse']),axis=1)
#dx.groupby(["sid","lev"])[["omf"]].mean()
#t2a=dx.groupby(["sid","lev"])[["omf"]].agg(["count","mean","std"])
#t2a=dx.groupby(["sid","lev"],as_index=False)["omf"]).agg(["count","mean","std"])
t2a=dx.groupby(["sid","lev"],as_index=False).agg({"omf":["count","mean","std"], "used":"sum"})
t2b=t2a.dropna()
t2b.to_csv('q'+aircraft+'.csv')


