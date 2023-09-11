


Here a the codes that I used for my master thesis evaluating the impact of training of the return to employment in France between September 2017 and June 2021




First step: run the 0-data_processing_for_python_r.R file to prepare data for DML python and Causal Forest codes on R

Second step: Create : 
- DML: DML- ATE.py to estimate ATE with MRI and PLR and DML-ATT.py to estimate ATT with MRI
- Routinecf.R to run binary processing on all cohorts and linear processing for September 2017 with Causal Forest

Tip: run the scripts on the terminal for python and R. For R, you can launch the execution in the background on the terminal with Rscript: write .../R/R-4.1.1/bin/Rscript.exe routinecf.R & ,the & allowing to launch the execution in the background.

Third step: extract the results for R: these are the codes Exploitation Causal Forest Binaire.R and Exploitation Causal Forest traitement continu.R.

Fouth step: Use notebooks to produce tables and graphs


Folder "Exploitation Variable Instrumentale": Matrice de Distance Commune OFs.R. geolocates OFs with their addresses and creates the distance matrix with all communes.

Instrumental variable creation.R: calculates for each ERP the annual variation of OFs present in its mobility zone. Unconvincing results with GMPs. They should be reproduced with the RCOs, with information on sessions by month, and the instrument created: Session programmed in month m year n when a PRE enters training - number of training sessions of year n-1 and month m.



File operation instrumental variable: Commune Distance Matrix OFs.R. geolocates OFs with their addresses and creates the distance matrix with all communes.

Instrumental variable creation.R: calculates for each ERP the annual variation of OFs present in its mobility zone. Unconvincing results with GMPs. It would be necessary to reproduce them with the RCOs, with information on sessions by month, and to create the instrument: Session programmed in month m year n when a PRE enters training - number of training sessions programmed in month m year n-1. This can only be done with RCOs from 2022 onwards.
