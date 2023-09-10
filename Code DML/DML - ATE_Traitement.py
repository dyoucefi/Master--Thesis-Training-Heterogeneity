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


dates= pd.date_range('2017-01-01','2021-07-01' , freq='1M')-pd.offsets.MonthBegin(1)
dates=[date_obj.strftime('%Y-%m-%d') for date_obj in dates]


weights=[]

for t in dates:
    
     df=pd.read_parquet(path+"/5. Causal Forest/data_"+t+".parquet",engine='pyarrow')
     w=df.entree_formation.sum()
     weights.append(w)




var_quel=["emploi_quelconque_t_plus_3","emploi_quelconque_t_plus_6",  "emploi_quelconque_t_plus_12" ,"emploi_quelconque_t_plus_18" ,"emploi_quelconque_t_plus_24","emploi_quelconque_t_plus_36"]




dic_irm={}
dic_plr={}

dic_irm["poids"]=weights
dic_plr["poids"]=weights


dic_irm["cohorte"]=dates
dic_plr["cohorte"]=dates


for var in var_quel:
    irm_coef=[]
    plr_coef=[]
    irm_upp=[]
    irm_low=[]
    plr_upp=[]
    plr_low=[]

    
        
    
    
    for cohorte in dates:
     
        dml_plr_obj=joblib.load( path+"/Résultats/Python/PLR/dml_plr_"+cohorte+"_"+var+".joblib")
        plr_coef.append(dml_plr_obj.summary.coef)
        plr_low.append(dml_plr_obj.confint()["2.5 %"])
        plr_upp.append(dml_plr_obj.confint()["97.5 %"])
        
        dml_irm_obj=joblib.load( path+"/Résultats/Python/IRM/dml_irm_"+cohorte+"_"+var+".joblib")
        irm_coef.append(dml_irm_obj.summary.coef)
        irm_low.append(dml_irm_obj.confint()["2.5 %"])
        irm_upp.append(dml_irm_obj.confint()["97.5 %"])
   
    dic_irm["coef_"+var]=irm_coef
    dic_irm["upp_"+var]=irm_upp
    dic_irm["low_"+var]=irm_low
    
    
    dic_plr["coef_"+var]=plr_coef
    dic_plr["upp_"+var]=plr_upp
    dic_plr["low_"+var]=plr_low
    




   
df_irm=pd.DataFrame.from_dict(dic_irm,orient="columns")
df_plr=pd.DataFrame.from_dict(dic_plr,orient="columns")

  

var_float= list(df_plr.columns)
var_float.remove("cohorte")
  
df_irm[var_float]=df_irm[var_float].astype(float)
df_plr[var_float]=df_plr[var_float].astype(float)

def weighted_average(dataframe, value, weight):
    val = dataframe[value]
    wt = dataframe[weight]
    return (val * wt).sum() / wt.sum()
 


dic_avg={}


dic_avg["temps"]=["3","6","12","18","24","36"]

irm_coef=[]
plr_coef=[]
irm_upp=[]
irm_low=[]
plr_upp=[]
plr_low=[]


for var in var_quel:
    
    irm_coef.append(weighted_average(df_irm,"coef_"+var,"poids"))
    plr_coef.append(weighted_average(df_plr,"coef_"+var,"poids"))
    
    irm_upp.append(weighted_average(df_irm,"upp_"+var,"poids"))
    plr_upp.append(weighted_average(df_plr,"upp_"+var,"poids"))
    
    irm_low.append(weighted_average(df_irm,"low_"+var,"poids"))
    plr_low.append(weighted_average(df_plr,"low_"+var,"poids"))
    


dic_avg["plr_coef"]=plr_coef
dic_avg["plr_upp"]=plr_upp
dic_avg["plr_low"]=plr_low


dic_avg["irm_coef"]=irm_coef
dic_avg["irm_upp"]=irm_upp
dic_avg["irm_low"]=irm_low
    

df_avg=pd.DataFrame.from_dict(dic_avg,orient="columns")


import plotly.express as px

fig = px.line(df, x=df_avg['temps'], y=df_avg['irm_coef'])
fig.add_scatter(x=df_avg['temps'], y=df_avg['plr_coef'])

# Display the plot
fig.show()
    
    
    
    