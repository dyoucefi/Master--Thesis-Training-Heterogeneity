# -*- coding: utf-8 -*-
"""
Created on Wed Aug 16 13:51:40 2023

@author: dalil.youcefi
"""

# -*- coding: utf-8 -*-
"""
Created on Tue Jul 18 09:38:31 2023

@author: dalil.youcefi
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.base import clone
import joblib
import pickle

import doubleml as dml


path="C:/Users/dalil.youcefi/Documents/Formation et retour à l'emploi/Données"


dates= pd.date_range('2017-01-01','2020-01-01' , freq='1M')-pd.offsets.MonthBegin(1)
dates=[date_obj.strftime('%Y-%m-%d') for date_obj in dates]


weights=[]

for t in dates:
    
     df=pd.read_parquet(path+"/5. Causal Forest/data_"+t+".parquet",engine='pyarrow')
     w=df.entree_formation.sum()
     weights.append(w)




var_quel=["emploi_quelconque_t_plus_3","emploi_quelconque_t_plus_6",  "emploi_quelconque_t_plus_12" ,"emploi_quelconque_t_plus_18" ,"emploi_quelconque_t_plus_24","emploi_quelconque_t_plus_36"]




dic_irm={}

dic_irm["poids"]=weights



dic_irm["cohorte"]=dates



for var in var_quel:
    irm_coef=[]

    irm_upp=[]
    irm_low=[]
 
    
        
    
    
    for cohorte in dates:
     

        
        dml_irm_obj=joblib.load( path+"/Résultats/Python/IRM/ATT/dml_irm_att_"+cohorte+"_"+var+".joblib")
        irm_coef.append(dml_irm_obj.summary.coef)
        irm_low.append(dml_irm_obj.confint()["2.5 %"])
        irm_upp.append(dml_irm_obj.confint()["97.5 %"])
   
        dic_irm["coef_"+var]=irm_coef
        dic_irm["upp_"+var]=irm_upp
        dic_irm["low_"+var]=irm_low
        
    

    




   
df_irm=pd.DataFrame.from_dict(dic_irm,orient="columns")


  

var_float= list(df_irm.columns)
var_float.remove("cohorte")
  
df_irm[var_float]=df_irm[var_float].astype(float)


def weighted_average(dataframe, value, weight):
    val = dataframe[value]
    wt = dataframe[weight]
    return (val * wt).sum() / wt.sum()
 


dic_avg={}


dic_avg["temps"]=["3","6","12","18","24","36"]

irm_coef=[]

irm_upp=[]
irm_low=[]



for var in var_quel:
    
    irm_coef.append(weighted_average(df_irm,"coef_"+var,"poids"))

    
    irm_upp.append(weighted_average(df_irm,"upp_"+var,"poids"))
  
    
    irm_low.append(weighted_average(df_irm,"low_"+var,"poids"))




dic_avg["irm_coef"]=irm_coef
dic_avg["irm_upp"]=irm_upp
dic_avg["irm_low"]=irm_low
    

df_avg=pd.DataFrame.from_dict(dic_avg,orient="columns")


import plotly.express as px

fig = px.line(df, x=df_avg['temps'], y=df_avg['irm_coef'])


# Display the plot
fig.show()
    
    
    
    