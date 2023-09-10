library(haven)
library(ggplot2)
library(dplyr)
library(grf)
library(gridExtra)
library(arrow)
library(dplyr)
library(readr)
library(haven)
library(lubridate)
library(tictoc)
library(tidyr)
library(DoubleML)
library(data.table)
library(DoubleML)
library(mlr3)
library(mlr3learners)
library(data.table)
library(TSstudio)
library(janitor)
library(fastDummies)
set.seed(2)



path="C:/Users/dalil.youcefi/Documents/Formation et retour à l'emploi/Données/"


variables=c("emploi_quelconque_t_plus_3","emploi_quelconque_t_plus_6",  "emploi_quelconque_t_plus_12" ,"emploi_quelconque_t_plus_18" ,"emploi_quelconque_t_plus_24","emploi_quelconque_t_plus_36",
            
            "emploi_durable_t_plus_3","emploi_durable_t_plus_6", "emploi_durable_t_plus_12" , "emploi_durable_t_plus_18" ,"emploi_durable_t_plus_24" ,"emploi_durable_t_plus_36")


var_quel=c("emploi_quelconque_t_plus_3","emploi_quelconque_t_plus_6",  "emploi_quelconque_t_plus_12" ,"emploi_quelconque_t_plus_18" ,"emploi_quelconque_t_plus_24","emploi_quelconque_t_plus_36")





for (cohorte in as.character(seq(ym('2017-09'), ym('2021-06'), by = '1 month'))){
  print(cohorte)
  df=open_dataset(paste0(path,sprintf("Prepro/Certif/prepro_data_certif_cf_%s.parquet",cohorte)))
  
  df=df%>%collect()                        
  
  
  #On ne garde que les variables d'intérêt
  
  for (var in var_quel){
    
    print(var)
    
    
    cols=variables[variables!=var]
    sel=colnames(df)
    sel=sel[!sel%in%cols]
    df_est=subset(df,select=sel)
    df_est=na.omit(df_est)
    df_est=df_est%>%sample_n(round(0.5*nrow(df_est)))
    
    #On sépare en train et en test
    
    # Je resample pour accélérer l'estimation: ne change pas grand chose surtout pour les cohortes avec beaucoup de formés
    
    
    
    
    col=colnames(df_est)
    #selection des covariables
    x_cols=col[! col %in% c("entree_formation",var)]
    
    
    
    #### On mets les covariables, l'outcome et le traitement dans des dataframe différents
    X=df_est[,x_cols]
    Y=df_est[,var]
    W=df_est[,"entree_formation"]
    tic()
    cf=causal_forest(X,Y,W)
    toc()
    
    
    
    
    saveRDS(cf,paste0(path,sprintf("Résultats/R/CF/Certif/cf_certif_%s.rds",paste0(cohorte,"_",var))))
    
    
}
    
  }








######################


var_quel=c("emploi_quelconque_t_plus_18")
for (cohorte in as.character(seq(ym('2017-09'), ym('2017-09'), by = '1 month'))){
  print(cohorte)
  df=open_dataset(paste0(path,sprintf("Prepro/Certif/prepro_data_certif_h_lin_%s.parquet",cohorte)))
  
  df=df%>%collect()                        
  
  

  
  #On ne garde que les variables d'intérêt
  
  for (var in var_quel){
    
    print(var)
   

    cols=variables[variables!=var]
    sel=colnames(df)
    sel=sel[!sel%in%cols]
    df_est=subset(df,select=sel)
    df_est=na.omit(df_est)
    df_est=df_est%>%sample_n(round(0.5*nrow(df_est)))
    
    #On sépare en train et en test
    
    # Je resample pour accélérer l'estimation: ne change pas grand chose surtout pour les cohortes avec beaucoup de formés
    
    

    
    col=colnames(df_est)
    #selection des covariables
    x_cols=col[! col %in% c("entree_formation",var)]
    
    
    
    
    X=df_est[,x_cols]
    Y=df_est[,var]
    W=df_est[,"entree_formation"]
    tic()
    cf=causal_forest(X,Y,W)
    toc()
    
    

    
    saveRDS(cf,paste0(path,sprintf("Résultats/R/CF/Certif/cf_certif_h_lin_%s.rds",paste0(cohorte,"_",var))))
    
    
    
 
    
  }
  
}





