# setupAthena 0.5.0 (2021-08-12)  

* Added `vocabulary_version` to log  
* Added improved console messaging, including processing 
time to `indices()`  


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




