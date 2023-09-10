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
library(geojsonio)



comm=read.csv("C:/Users/dalil.youcefi/Downloads/georef-france-commune.csv",sep=";",encoding = "UTF-8")
path="C:/Users/dalil.youcefi/Documents/Formation et retour à l'emploi/Données/Adresses BPF/"




comm=read.csv(paste0(path,"georef-france-commune.csv"),sep=";",encoding = "UTF-8")
comm=comm%>%select(Code.Officiel.Commune)




####On récupère la localisation par Code Commune Insee

for (annee in c("2018","2019")){
  
  
  print(annee)
  
  commune=codeComToCoord(codeInsee =comm$Code.Officiel.Commune,
                         geo = annee,
                         type = "chx")
  
  commune=commune%>%drop_na(lon,lat)
  
  
  
  #####On récupère les adresses des BPF
  adresses_cf <- readRDS(sprintf(paste0(path,"adresses_cf_%s.rds",annee)))
  adresses_cf=adresses_cf%>%drop_na(ad_phy_voie)
  adresses_cf=adresses_cf%>%group_by(n_siret)%>%filter(row_number()==1)
  add=paste(adresses_cf$ad_phy_voie, adresses_cf$ad_post_code_postale, adresses_cf$ad_phy_ville)

  add=unlist(add)
  adresses_loc=data.frame(matrix(nrow=length(add),ncol=2))
  adresses_loc$siret=adresses_cf$n_siret
  colnames(adresses_loc)=c("lon","lat")
  
  
  
  
  #On covertit pour chaque adresse en coordonnées
  for (i in seq(1,length(add))){
    
    
    
    
    skip_to_next <- FALSE
    
    # Note that print(b) fails since b doesn't exist
    
    tryCatch({z=adresseToCoord(add[i], nbEchos=1)
    adresses_loc[i,"lon"]=as.numeric(z["LON"])
    adresses_loc[i,"lat"]=as.numeric(z["LAT"])
    
    }, error = function(e) { skip_to_next <<- TRUE} )
    
    if(skip_to_next){ next }
    
    
  }
  
  
  
  
  
  
  
  ####On enlève les lieux non localisés
  commune=commune%>%drop_na(lon,lat)
  
  adresses_loc=adresses_loc%>%drop_na(lon,lat)
  
  
  
  
  ####On crée la matrice de distance (en m)
  res=distm(cbind(commune[,"lon"],commune[,"lat"]),cbind(adresses_loc[,"lon"],adresses_loc[,"lat"]))
  
  
  
  df=data.frame(res)
  
  ###On remet les codes communes en lignes et les siret en colonnes
  res$code_comm=commune$code
  
  
  
  colnames(adresses_loc)=c("lon","lat","siret")
  colnames(df)=adresses_loc$siret
  row.names(df)=commune$code
  saveRDS(df,sprintf(paste0(path,"commune_bpf_dist_%s.rds",annee)))
  
}
