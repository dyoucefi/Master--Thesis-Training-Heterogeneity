#!/usr/bin/env python
# coding: utf-8

# In[17]:


import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.base import clone
import joblib
import pickle

import doubleml as dml


# In[2]:
np.random.seed(3141)

path="C:/Users/dalil.youcefi/Documents/Formation et retour à l'emploi/Données"



variables=["emploi_quelconque_t_plus_3","emploi_quelconque_t_plus_6",  "emploi_quelconque_t_plus_12" ,"emploi_quelconque_t_plus_18" ,"emploi_quelconque_t_plus_24","emploi_quelconque_t_plus_36",
            
            "emploi_durable_t_plus_3","emploi_durable_t_plus_6", "emploi_durable_t_plus_12" , "emploi_durable_t_plus_18" ,"emploi_durable_t_plus_24" ,"emploi_durable_t_plus_36"]



var_quel=["emploi_quelconque_t_plus_3","emploi_quelconque_t_plus_6",  "emploi_quelconque_t_plus_12" ,"emploi_quelconque_t_plus_18" ,"emploi_quelconque_t_plus_24","emploi_quelconque_t_plus_36"]

dates= pd.date_range('2017-01-01','2021-07-01' , freq='1M')-pd.offsets.MonthBegin(1)
dates=[date_obj.strftime('%Y-%m-%d') for date_obj in dates]

for cohorte in dates:
    
    print(cohorte)
    
    df=pd.read_parquet(path+"/Prepro/Toutes Form/prepro_data_"+cohorte+".parquet",engine='pyarrow')
    
    for var in var_quel:
        print(var)
        
        
        
        remove = [x for x in variables if x != var]
        
        
        
        
        df_est=df.drop(columns=remove)
        x_cols=list(df_est.drop(columns=[var, "entree_formation"]).columns)
        
        ###irm
        
        ml_g = RandomForestRegressor(n_estimators=100, max_features=30, max_depth=8, min_samples_leaf=10)
        ml_m = RandomForestClassifier(n_estimators=100, max_features=30, max_depth=8, min_samples_leaf=10)
        obj_dml_data = dml.DoubleMLData(df_est, var, "entree_formation",x_cols=x_cols)
        dml_irm_obj = dml.DoubleMLIRM(obj_dml_data, ml_g, ml_m)


        
        dml_irm_obj.fit()

        joblib.dump(dml_irm_obj, path+"/Résultats/Python/IRM/Toutes Form/dml_irm_"+cohorte+"_"+var+".joblib")
                
        
        

    

