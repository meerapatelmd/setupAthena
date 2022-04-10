# setupAthena 0.8.0  

* Changed default target schema to 'omop_athena'  

* Added default values for `umls_api_key` and `conn_fun` 
arguments  

* Changed `prepare_cpt4` because on.exit() was not behaving 
as expected  

* Added conditions that warns the user if the `release_version` 
is already logged in the database  



# setupAthena 0.7.0 (2021-12-09)  

* Added steps in `prepare_cpt4` where the 
native CONCEPT.csv file is copied for safekeeping 
and replaced with the original in case the function 
exits early. This was added to avoid having to redownload 
the vocabulary files every time this function does not 
complete successfully.  

* Added vocabulary counts to the log as well as a 
warning if any of the vocabulary_ids had 0 counts. 

* Added a diff report that prints to the console between 
the newest log entry and the one previous to it.  

* Introduced `postprocessing` steps to the `run_setup` function 
to include the creation of downstream lookups and tables such as 
the ATC classifications for the RxNorm drugs.  


# setupAthena 0.6.0 (2021-08-28)  

* Fixed prettyunits parsing error when running indexes  
* Added `chariotViz` package setup integration


# setupAthena 0.5.0 (2021-08-12)  

* New `fetch_*` functions that retrieves version information 
at the entire vocabulary and vocabulary_id level to a 
`setupAthenaLog` class object  
* Added `vocabulary_version` to log  
* Added improved console messaging, including processing 
time to `indices()`  
* Converted log to a safer process where the previous log 
is only dropped when the new one is successfully written  


# setupAthena 0.4.0 (2021-06-18)  
 
* Added `sa_release_version` and `sa_schema` field to log  
* Changed logging to a complete rewrite from an append to preserve 
existing log data.  
* Updated documentation on new `release_version` argument  


# setupAthena 0.3.0

* Section headers at each step execution is now center justified  
* Disclaimer regarding required user permissions level added 
to README and package argument descriptions.  
* Added Code of Conduct.


# setupAthena 0.2.0

* Added a `NEWS.md` file to track changes to the package.  
* Added `log` feature that logs updates with row counts for each table to a `setup_athena_log` table in the `public` schema.  
* Added a `steps` feature to `run_setup` to be able to customize the steps taken for each setup, but not the order.  
* Removed deprecated functions.  




