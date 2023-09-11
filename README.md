


Here a the codes that I used for my master thesis evaluating the impact of training of the return to employment in France between September 2017 and June 2021





Première étape : exécuter le fichier 0-traitement_données_pour_python_r.R pour préparer les données pour les codes DML python et Causal Forest sur R

Deuxième étape : Créer les modèles : 
-	DML : DML- ATE.py pour estimer les ATE avec les IRM et les PLR et DML-ATT.py pour estimer les ATT avec les IRM
-	Routinecf.R pour exécuter le traitement binaire sur toute les cohortes et le traitement linéaire pour Septembre 2017 avec Causal Forest

Astuce : exécuter les scripts sur le terminal pour python et R. Pour R, on peut lancer l’exécution en fond sur le terminal avec Rscript : en écrivant C:/Users/dalil.youcefi/Documents/R/R-4.1.1/bin/Rscript.exe routinecf.R & ,le & permettant de lancer l’exécution en fond.

Troisième étape : extraire les résultats pour R : ce sont les codes Exploitation Causal Forest Binaire.R et Exploitation Causal Forest traitement continu.R.

Quatrième étape : Utiliser les notebooks pour produire les tableaux et les graphiques


Dossier exploitation variable instrumentale : Matrice de Distance Commune OFs.R. géolocalise les OF avec leurs adresses et crée la matrice de distance avec toutes les communes.

Création variable instrumentale.R : calcule pour chaque PRE la variation annuelle d’OF présent dans sa zone de mobilité. Résultats peu convaincant avec les BPF. Il faudrait les reproduire avec les RCO avec les informations sur les sessions par mois et créé l’instrument : Session programmée au mois m année n quand un PRE rentre en formation – nombre de formation programmée au mois m année n-1. On ne peut le faire qu’à partir de 2022 avec les RCO.
