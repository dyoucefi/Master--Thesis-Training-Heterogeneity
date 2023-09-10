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


brest=open_dataset("C:/Users/dalil.youcefi/Documents/Formation et retour à l'emploi/Données/3. Brest/Primo_formes")
brest=brest%>%select(id_force,DISPOSITF_TR)%>%collect()

for (cohorte in as.character(seq(ym('2017-01'), ym('2021-06'), by = '1 month'))){
  print(cohorte)
  df=open_dataset(paste0(path,sprintf("5. Causal Forest/data_%s.parquet",as.character(cohorte))))
  
  df=df%>%collect()                        
  
  #On utilise BREST pour ne garder que les formations certifiantes en enlevat les POEC
  
  df=df%>%left_join(brest,by="id_force")
  
  
  print("bases ouvertes")
  
  
  df=df%>%filter(OBJECTIF_STAGE=="1- certification" & DISPOSITIF_TR != "POEC" |entree_formation==0 )
  #on enlève toutes les personnes qui ont créé une entreprise
  
  df=df%>%filter(emploi_creation_entreprise_t_plus_1 ==0&
                   emploi_creation_entreprise_t_plus_3 ==0&
                   emploi_creation_entreprise_t_plus_6 ==0&
                   emploi_creation_entreprise_t_plus_9 ==0&
                   emploi_creation_entreprise_t_plus_12 ==0&
                   emploi_creation_entreprise_t_plus_18 ==0&
                   emploi_creation_entreprise_t_plus_24 ==0&
                   emploi_creation_entreprise_t_plus_30 ==0&
                   emploi_creation_entreprise_t_plus_36 ==0)
  
  
  
  
  
  
  
  
  
  
  df=df%>%select(-c("duree_episode"))
  
  
  print("bases filtrées")
  
  #On converti tout en numérique et on enlève les valeurs inconnus (sauf ROME)
  
  df=df[df$QUALIF !="Inconnu",] #On convertit ces variables en nombres
  df$SEXE=as.numeric(df$SEXE)
  df$handicap=as.numeric(df$handicap)
  df$age=as.numeric( df$age)
  df$nb_demandes=as.numeric(df$nb_demandes)
  df$anciennete=as.numeric(df$anciennete)
  df$longue_distance=as.numeric(df$longue_distance)
  df$temps_maladie_avant=as.numeric(df$temps_maladie_avant)
  df$absence=as.numeric(df$absence)
  df$temps_chomage_avant=as.numeric(df$temps_chomage_avant)
  df$temps_maladie_spell=as.numeric(df$temps_maladie_spell)




controls <- c('anciennete',
              'nb_demandes',
              'age',
              
              
              'SEXE',
              'NENF',
              'NATION',
              'NIVFOR',
              'MOTINS',
              'CATREGR',
              'SITMAT',
              'CONTRAT',
              'zone_emploi',
              'QUALIF',
              'ROME',
              'EXPER',
              'handicap',
              'zone_urbaine',
              'zone_rurale',
              'longue_distance',
              'temps_maladie_spell',
              'temps_maladie_avant',
              'absence',
              'temps_chomage_avant',
              'nb_heures',"entree_formation")



controls=append(controls,variables)

#On réduit le nombres de colonnes et on sample dans l'échantillon de contrôle pour que l'estimation 
#ne soit pas trop longues

df_est=subset(df, select= controls)
df_est=na.omit(df_est)
treatment=df_est[df_est$entree_formation==1,]
control=df_est[df_est$entree_formation==0,]
control=control[sample(nrow(control),2*nrow(treatment)),]
df_est=rbind(treatment,control)
###One hot encoding des variables
df_est=dummy_cols(df_est)
###On enlève les variables qui ne sont pas numériques
df_est=df_est%>%select(where(is.numeric))
##### On met au format dataframe et on simplifie les noms des variables
df_est=data.frame(df_est)
df_est=clean_names(df_est)


#On sauvegarde les bases

write_parquet(df_est,paste0(path,sprintf("Prepro/Certif/prepro_data_certif_%s.parquet",cohorte)))


}
























###########




variables=c("emploi_quelconque_t_plus_3","emploi_quelconque_t_plus_6",  "emploi_quelconque_t_plus_12" ,"emploi_quelconque_t_plus_18" ,"emploi_quelconque_t_plus_24","emploi_quelconque_t_plus_36",
            
            "emploi_durable_t_plus_3","emploi_durable_t_plus_6", "emploi_durable_t_plus_12" , "emploi_durable_t_plus_18" ,"emploi_durable_t_plus_24" ,"emploi_durable_t_plus_36")






brest=open_dataset("C:/Users/dalil.youcefi/Documents/Formation et retour à l'emploi/Données/3. Brest/Primo_formes")
brest=data.frame(brest%>%collect())
brest=brest%>%select(c(id_force,DISPOSITIF_TR,DUREE_FORMATION_HEURES_REDRESSEE))


for (cohorte in as.character(seq(ym('2017-09'), ym('2017-09'), by = '1 month'))){
  print(cohorte)
  df=open_dataset(paste0(path,sprintf("5. Causal Forest/data_%s.parquet",as.character(cohorte))))
  
  df=df%>%collect()                        
  
  #On utilise BREST pour ne garder que les formations certifiantes en enlevat les POEC
  
  df=df%>%left_join(brest,by="id_force")
  
  
  print("bases ouvertes")
  
  
  df=df%>%filter(OBJECTIF_STAGE=="1- certification" & DISPOSITIF_TR != "POEC" |entree_formation==0 )
  #on enlève toutes les personnes qui ont créé une entreprise
  
  df=df%>%filter(emploi_creation_entreprise_t_plus_1 ==0&
                   emploi_creation_entreprise_t_plus_3 ==0&
                   emploi_creation_entreprise_t_plus_6 ==0&
                   emploi_creation_entreprise_t_plus_9 ==0&
                   emploi_creation_entreprise_t_plus_12 ==0&
                   emploi_creation_entreprise_t_plus_18 ==0&
                   emploi_creation_entreprise_t_plus_24 ==0&
                   emploi_creation_entreprise_t_plus_30 ==0&
                   emploi_creation_entreprise_t_plus_36 ==0)
  
  
  
  
  
  
  
  
  
  
  df=df%>%select(-c("duree_episode"))
  
  
  print("bases filtrées")
  
  
  df$entree_formation=df$DUREE_FORMATION_HEURES_REDRESSEE
  df[is.na(df$entree_formation),]$entree_formation=0
  #On converti tout en numérique et on enlève les valeurs inconnus (sauf ROME)
  
  df=df[df$QUALIF !="Inconnu",] #On convertit ces variables en nombres
  df$SEXE=as.numeric(df$SEXE)
  df$handicap=as.numeric(df$handicap)
  df$age=as.numeric( df$age)
  df$nb_demandes=as.numeric(df$nb_demandes)
  df$anciennete=as.numeric(df$anciennete)
  df$longue_distance=as.numeric(df$longue_distance)
  df$temps_maladie_avant=as.numeric(df$temps_maladie_avant)
  df$absence=as.numeric(df$absence)
  df$temps_chomage_avant=as.numeric(df$temps_chomage_avant)
  df$temps_maladie_spell=as.numeric(df$temps_maladie_spell)
  
  
  
  
  controls <- c('anciennete',
                'nb_demandes',
                'age',
                
                
                'SEXE',
                'NENF',
                'NATION',
                'NIVFOR',
                'MOTINS',
                'CATREGR',
                'SITMAT',
                'CONTRAT',
                'zone_emploi',
                'QUALIF',
                'ROME',
                'EXPER',
                'handicap',
                'zone_urbaine',
                'zone_rurale',
                'longue_distance',
                'temps_maladie_spell',
                'temps_maladie_avant',
                'absence',
                'temps_chomage_avant',
                'nb_heures',"entree_formation")
  
  
  
  controls=append(controls,variables)
  
  #On réduit le nombres de colonnes et on sample dans l'échantillon de contrôle pour que l'estimation 
  #ne soit pas trop longues
  
  df_est=subset(df, select= controls)
  df_est=na.omit(df_est)
  treatment=df_est[df_est$entree_formation>0,]
  control=df_est[df_est$entree_formation==0,]
  control=control[sample(nrow(control),2*nrow(treatment)),]
  df_est=rbind(treatment,control)
  ###One hot encoding des variables
  df_est=dummy_cols(df_est)
  ###On enlève les variables qui ne sont pas numériques
  df_est=df_est%>%select(where(is.numeric))
  ##### On met au format dataframe et on simplifie les noms des variables
  df_est=data.frame(df_est)
  df_est=clean_names(df_est)
  
  
  #On sauvegarde les bases
  
  write_parquet(df_est,paste0(path,sprintf("Prepro/Certif/prepro_data_certif_h_lin_%s.parquet",cohorte)))
  
  
}







