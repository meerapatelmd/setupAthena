# setupAthena <img src="man/figures/logo.png" align="right" alt="" width="120" />  

This package provides all the tools needed to build a Postgres instance of the OMOP CDM Vocabulary Tables, also called "Athena".    


# Installation   

```
library(devtools)  
install_github("patelm9/setupAthena")  
```  
  
# Requirements   

1. Downloaded and unpacked vocabulary bundle from athena.ohdsi.org. If CPT4 is in the bundle, remember to reconstitute it with either the functions available in this package or from the Command Line using the README.txt that came with the vocabularies.   
1. Postgres database    


# Execution  
 
A. After the zip file is unpacked and the CPT4 have been reconstituted:   

```
library(setupAthena) 
run_setup(conn = conn, 
          target_schema = "my_schema",
          path_to_csvs = "~/Desktop/athena_vocab")
```  

B. To use the option of reconstituting CPT4 alongside the rest of the setup:  

```
library(setupAthena) 
run_setup(conn = conn, 
          target_schema = "my_schema",
          path_to_csvs = "~/Desktop/athena_vocab",
          steps = c("prepare_cpt4", "drop_tables", "copy", "indices", "constraints", "log"),)
```  



## Code of Conduct

Please note that the setupAthena project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.  


