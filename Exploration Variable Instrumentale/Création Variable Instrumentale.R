library(readxl)
library(dplyr)
library(haven)
library(ggplot2)
library(sf)
library(data.table)
library(stringr)
library(arrow)
library(tidyr)
library(spatialrisk)
library(metric.osrm)
library(geosphere)
library(fastDummies)




path="C:/Users/dalil.youcefi/Documents/Formation et retour à l'emploi/Données/"


#########Fichier à recrée avec DE il faut juste sélectionner la commune et la mobilité, et la demande



fh_fin=open_dataset(paste0("Adresses BPF/mob_com.parquet"))%>%collect()

##### A  affiner il faut rajouter la bonne demande
fh_fin=fh_fin%>%group_by(id_force)%>%filter(row_number()==n())


####On charge une cohorte

df_test=open_dataset(paste0(path,"5. Causal Forest/data_2019-09-01.parquet"))
df_test=df_test%>%collect()


####On réduit la base

treat=df_test%>%filter(entree_formation==1)
#treat=treat%>%filter(OBJECTIF_STAGE=="1- certification" )
control=df_test%>%filter(entree_formation==0)%>%sample_n(2*nrow(treat))


df_test=rbind(control,treat)

####On rajoute la commune et la mobilité
df_test=df_test%>%left_join(fh_fin,by="id_force" )
###On ne garde que ceux qui ont une mobilité en KM
df_test=df_test%>%filter(MOBUNIT=="KM")


####On charge les matrices de distance
add_2018 <- readRDS(sprintf(paste0(path,"commune_bpf_dist_%s.rds","2018")))

names(add_2018) <- make.names(names(add_2018), unique=TRUE)
add_2019 <- readRDS(sprintf(paste0(path,"commune_bpf_dist_%s.rds","2019")))


#####Conversion en KM
add_2018=add_2018/1000
add_2019=add_2019/1000


####On fait une jointure avec la cohorte pour rendre le calcul plus rapide
li_siret=colnames(add_2018)
add_2018$DEPCOM=row.names(add_2018)


df_test=df_test%>%left_join(add_2018,by="DEPCOM")

####On compte les OFs qui sont dans la zone de mobilité en 2018
df_test$instr_2018 <- rowSums(df_test[,li_siret] <= df_test$MOBDIST,na.rm=T)

####On retire les colonnes de la matrice de distance
df_test=df_test[,!colnames(df_test) %in% li_siret]


###On fait de même pour 2019

li_siret=colnames(add_2019)
add_2019$DEPCOM=row.names(add_2019)
df_test=df_test%>%left_join(add_2019,by="DEPCOM")
df_test$instr_2019 <- rowSums(df_test[,li_siret] <= df_test$MOBDIST,na.rm=T)
df_test=df_test[,!colnames(df_test) %in% li_siret]




####On crée l'instrument

df_test$instr=df_test$instr_2019-df_test$instr_2018

####On prépare la base comme pour causal forest 

df=df_test






df=df[df$QUALIF !="Inconnu",] #On convertit ces variables en nombres
df$SEXE=as.numeric(df$SEXE)
df$handicap=as.numeric(df$handicap)
df$age=as.numeric( df$age)
df$age2=df$age**2
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
              'nb_heures',"entree_formation","emploi_quelconque_t_plus_6","instr")




df=df%>%select(-c("duree_episode"))




df=subset(df, select= controls)

####On ne garde que les covariables et le traitement

instrumental_var=c('anciennete',"instr",
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








df2=df[,instrumental_var]

df2=dummy_cols(df2)

df2=df2%>%select(where(is.numeric))

####On fait un first stage 
summary(lm(entree_formation~.,df2))






