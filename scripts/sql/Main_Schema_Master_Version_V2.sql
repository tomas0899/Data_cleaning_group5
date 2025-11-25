#######################################################


#####--- Protocol ---#####

#1. Create a database in the local host (dcdm5) and enable SQL to load files into the database.
#2. Create merged_df and ipd_csv tables, import data, and connect them via a joining table based on parameter_id.
#3. Create dis_inf table, import data, connect to merged_df via joining table based on gene_accession_id. Construct specific tables to host do_disease and omim_id information.
#4. Create procedure_link table, import data from procedure.csv, link to ipd_csv via impc_parameter_orig_id. 
#5. Create procedure_data table. Migrate procedure_name, procedure_description and ismandatory status to a new procedure_data table.
#6. Create tables for parameter groupings (i.e. parameter_group and parameter_group_membership) - link to ipd_csv via impc_parameter_orig_id.


#######################################################


CREATE DATABASE dcdm5;


#######################################################


USE dcdm5;

SET GLOBAL local_infile = 1;    #Enables LOCAL INFILE on the server


#######################################################


#####---- Creating the table for merged_df ----#####
CREATE TABLE dcdm5.merged_df( 
    gene_accession_id varchar(15),    
    analysis_id varchar(30),  
    gene_symbol varchar(10), 
    mouse_strain varchar (6), 
    mouse_life_stage varchar (100),   
    parameter_id varchar (100),    
    parameter_name varchar (100),
    pvalue Decimal (10,8) NULL
);


####--- Loads the merged_df csv file into the merged_df table ---####
LOAD DATA LOCAL INFILE "/Users/kennieng/Downloads/DCDM_dataset/merged_df.csv"
INTO TABLE dcdm5.merged_df
FIELDS TERMINATED BY ','  #Each column in the csv file is seperated by a comma
OPTIONALLY ENCLOSED BY '"'  #If any values are wrapped in quotes ("value"), remove the quotes automatically 
LINES TERMINATED BY '\n'  #Each row in the file ends with a newline character (standard csv format)
IGNORE 1 ROWS;  #Skips the first row because it contains column headers, not data 


####--- Assigning a primary key to merged_df ---####
#Check to see if gene_accession_id is eligible to be a unique primary key. 
SELECT gene_accession_id, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.merged_df   #Check the data in selected table 
GROUP BY gene_accession_id   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1;  #Only shows id's that appear more than once 
#There are duplicates so it is not a primary key 

#Check to see if gene_symbol is eligible to be a unique primary key. 
SELECT gene_symbol, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.merged_df   #Check the data in selected table 
GROUP BY gene_symbol   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1;  #Only shows id's that appear more than once 
#There are duplicates so it is not a primary key 

#Check to see if parameter_id is eligible to be a unique primary key. 
SELECT parameter_id, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.merged_df   #Check the data in selected table 
GROUP BY parameter_id   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1;  #Only shows id's that appear more than once 
#There are duplicates so it is not a primary key 

#Check to see if analysis_id is eligible to be a unique primary key. 
SELECT analysis_id, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.merged_df   #Check the data in selected table 
GROUP BY analysis_id   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1;  #Only shows id's that appear more than once 
#There are no duplicates so it is a primary key 


####--- Making analysis_id a primary key ---####
ALTER TABLE dcdm5.merged_df
ADD PRIMARY KEY (analysis_id)


#--- Setting empty strrings to NULL ---#
UPDATE dcdm5.merged_df
set gene_accession_id = null where gene_accession_id = '' 

UPDATE dcdm5.merged_df
set gene_symbol = null where gene_symbol = ''
	
UPDATE dcdm5.merged_df
set mouse_strain = null where mouse_strain = ''

UPDATE dcdm5.merged_df
set mouse_life_stage = null where mouse_life_stage = ''
	

UPDATE dcdm5.merged_df
set parameter_id = null where parameter_id = '' 


UPDATE dcdm5.merged_df
set parameter_name = null where parameter_name = ''


####--- Adds "MGI" to the gene_accession_ids in merged_df ---####
UPDATE dcdm5.merged_df
SET gene_accession_id = concat('MGI:', gene_accession_id)
WHERE gene_accession_id NOT LIKE 'MGI:%'
	



#######################################################


####--- Creating the table for ipd ---####
CREATE TABLE dcdm5.ipd(
    parameter_id varchar (225),
    impc_parameter_orig_id varchar(15), #this is "not null" so it can be altered to primary key later
    parameter_name varchar (225),
    parameter_description varchar (1000)
);

####--- Loading the ipd csv into the ipd table ---####
LOAD DATA LOCAL INFILE "/Users/kennieng/Downloads/DCDM_dataset/ipd.csv"
INTO TABLE dcdm5.ipd
FIELDS TERMINATED BY ','  #Each column in the csv file is seperated by a comma
OPTIONALLY ENCLOSED BY '"'  #If any values are wrapped in quotes ("value"), remove the quotes automatically 
LINES TERMINATED BY '\n'  #Each row in the file ends with a newline character (standard csv format)
IGNORE 1 ROWS;  #Skips the first row because it contains column headers, not data 



####--- Assigning a primary key to ipd ---####
#Check to see if parameter_id is eligible to be a unique primary key 
SELECT parameter_id, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.ipd   #Check the data in selected table 
GROUP BY parameter_id   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1;  #Only shows id's that appear more than once 
#There are duplicates so it is not a primary key

#Running impc_parameter_orig_id gives duplicates. 
SELECT impc_parameter_orig_id, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.ipd   #Check the data in selected table 
GROUP BY impc_parameter_orig_id   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1;  #Only shows id's that appear more than once 
#There are no duplicates so is a primary key  


####--- Making impc_parameter_orig_id a primary key ---####
ALTER TABLE dcdm5.ipd
ADD PRIMARY KEY (impc_parameter_orig_id)

####--- Create a new column and name it as "parameter_id_nulled". It will occur after the original parameter_id column ---####
ALTER TABLE dcdm5.ipd
ADD COLUMN parameter_id_nulled varchar(100) AFTER parameter_id # insert the nulled_parameter_id column next to the gene_accession_id column

####--- Copy the parameter_id column into parameter_id_nulled ---####
UPDATE dcdm5.ipd
SET parameter_id_nulled = parameter_id


####--- Converting empty strings to NULL in ipd table ---####
UPDATE dcdm5.ipd
SET parameter_description = NULL
WHERE parameter_description = ''


#######################################################


####--- Creating the linking table between merged_df and ipd, called "param_id_merged_df" ---####
CREATE TABLE dcdm5.param_id_merged_df(
    parameter_id varchar (225) not null
)

update dcdm5.merged_df
set parameter_id = "NULL"
where parameter_id is null

####--- Selects the distinct (unique) parameter_id values taken from merged_df table, so we can set it as a primary key ---####
INSERT INTO dcdm5.param_id_merged_df (parameter_id)		#insert into param_id_merged_df (alias pimd)
SELECT DISTINCT md.parameter_id							#select unique parameter_ids
FROM dcdm5.merged_df md 								#from the source table merged_df (alias md)
LEFT JOIN dcdm5.param_id_merged_df pimd					#left join to pimd
    ON md.parameter_id = pimd.parameter_id				#match on parameter_id
WHERE pimd.parameter_id IS null 						#only insert ids that aren't already present in the pimd table

####--- Sets parameter_id to a primary key in param_id_merged_df linking table ---####
ALTER TABLE  dcdm5.param_id_merged_df 
ADD PRIMARY KEY (parameter_id)

####--- This compares the parameter_ids from the linking table with parameter_id_nulled in ipd table, and nulls any values that are not present ---####
UPDATE dcdm5.ipd
SET parameter_id_nulled = NULL
WHERE parameter_id_nulled NOT IN (
    SELECT parameter_id FROM dcdm5.param_id_merged_df
)


#######################################################


####--- Adding foreign keys to ipd and merged_df to link with param_id_merged_df ---####

ALTER TABLE dcdm5.ipd 
ADD FOREIGN KEY (parameter_id_nulled) REFERENCES dcdm5.param_id_merged_df (parameter_id)

ALTER TABLE dcdm5.merged_df 
ADD FOREIGN KEY (parameter_id) REFERENCES dcdm5.param_id_merged_df(parameter_id)


#######################################################

####--- Creating the disease information table ---####
CREATE TABLE dcdm5.dis_inf(
    do_disease_id varchar(15) not null,
	do_disease_name varchar(200),
	omim_id varchar(15),
	gene_accession_id varchar(15)
)


####--- Loading the dis_inf csv onto the dis_inf table ---####
LOAD DATA LOCAL INFILE "/Users/kennieng/Downloads/DCDM_dataset/dis_inf_1.csv"
INTO TABLE dcdm5.dis_inf
FIELDS TERMINATED BY ','  #Each column in the csv file is seperated by a comma
OPTIONALLY ENCLOSED BY '"'  #If any values are wrapped in quotes ("value"), remove the quotes automatically 
LINES TERMINATED BY '\n'  #Each row in the file ends with a newline character (standard csv format)
IGNORE 1 ROWS  #Skips the first row because it contains column headers, not data 


####--- Assigning a primary key ---####
#Check to see if do_disease_id is eligible to be a unique primary key. 
SELECT do_disease_id, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.dis_inf   #Check the data in selected table 
GROUP BY do_disease_id   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1  #Only shows id's that appear more than once 
#There are duplicates so it is not eligible to be a primary key 

#Check to see if omim_id is eligible to be a unique primary key. 
SELECT omim_id, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.dis_inf   #Check the data in selected table 
GROUP BY omim_id   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1  #Only shows id's that appear more than once 
#There are duplicates so it is not a primary key 

#Check to see if gene_accession_id is eligible to be a unique primary key. 
SELECT gene_accession_id, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.dis_inf   #Check the data in selected table 
GROUP BY gene_accession_id   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1  #Only shows id's that appear more than once 
#There are duplicates so it is not a primary key 


####--- Making disease_id a primary key ---####
ALTER TABLE dcdm5.dis_inf
ADD COLUMN disease_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY first

####--- Create a new column and name it as "gene_accession_id_nulled". It will occur after the original gene_accession_id column ---####
ALTER TABLE dcdm5.dis_inf
ADD COLUMN gene_accession_id_nulled varchar(15) AFTER gene_accession_id

####--- Copy the gene_accession_id column into gene_accession_id_nulled ---####
UPDATE dcdm5.dis_inf
SET gene_accession_id_nulled = gene_accession_id

    
#######################################################


####--- Creating do_disease table ---####
CREATE TABLE dcdm5.do_disease (
    do_disease_id varchar(15),
    do_disease_name varchar(225)
)


####--- Copying the do_disease_id and do_disease_name values from dis_inf table, into do_disease table ---####
INSERT INTO dcdm5.do_disease
SELECT do_disease_id, do_disease_name
FROM dcdm5.dis_inf


####--- Checking for duplicates in do_disease_id to assign a primary key ---####
SELECT do_disease_id, COUNT(*) AS count
FROM dcdm5.do_disease 
GROUP BY do_disease_id 
HAVING COUNT(*) > 1
# 423 do_disease_id contains duplicates #


####--- Assigning a surrogate primary key that will be used to remove the duplicates ---####
ALTER TABLE dcdm5.do_disease 
ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY FIRST


####--- THIS COMMAND MUST BE RUN ALL TOGETHER (lines 1-6): Common Table Expression (CTE) to rank rows based on 'row_id' ---####
WITH cte AS (                                                                          #cte is a temporary placeholder 
    SELECT row_id, do_disease_id, do_disease_name,                                     #selects the columns from do_disease table 
    ROW_NUMBER() OVER (PARTITION BY do_disease_id, do_disease_name ORDER BY row_id ASC) AS RowNum       #stores the row_number() value in <RowNum>
    FROM dcdm5.do_disease                   
)
DELETE FROM dcdm5.do_disease WHERE row_id IN (SELECT row_id FROM cte WHERE RowNum > 1); 
# ^Deletes rows from the 'do_disease' table where row number contained <cte> greater than 1
# so delete any instances of do_disease that occur for the 2nd time or more
# this code will only delete duplicates where the entire row is the same.
     

####--- Checking for duplicates in do_disease_id to assign a primary key ---####
SELECT do_disease_id, COUNT(*) AS count
FROM dcdm5.do_disease 
GROUP BY do_disease_id 
HAVING COUNT(*) > 1
# none found, do_disease_id can be used as a primary key #


####--- Since we have do_disease_name in our do_disease table, we don't need it in our dis_inf table. So we can drop it ---####
ALTER TABLE dcdm5.dis_inf
DROP COLUMN do_disease_name

####--- Since we now have a unique do_disease_id, we can drop the surrogate primary key and make do_disease_id the new primary key ---####
ALTER TABLE dcdm5.do_disease 
DROP COLUMN row_id


####--- Making do_disease_id a primary key ---####
ALTER TABLE dcdm5.do_disease 
ADD PRIMARY KEY (do_disease_id)


#######################################################


####--- Creating omim_disease table ---####
CREATE TABLE dcdm5.omim_disease (
    omim_id varchar(15),
    do_disease_id varchar(15)
)


####--- Copying the omim_id do_disease_id values from dis_inf table, into omim_disease table ---####
INSERT INTO dcdm5.omim_disease 
SELECT omim_id, do_disease_id
FROM dcdm5.dis_inf


####--- Checking for duplicates in omim_id to assign it as a primary key ---####
SELECT omim_id, COUNT(*) AS count
FROM dcdm5.omim_disease 
GROUP BY omim_id 
HAVING COUNT(*) > 1
# 579 omim_id contains duplicates #


####--- Assigning a surrogate primary key ---####
ALTER TABLE dcdm5.omim_disease 
ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY FIRST


####--- Common Table Expression (CTE) to rank rows based on 'row_id' ---####
WITH cte AS (                                                                            #cte is a temporary placeholder 
    SELECT row_id, omim_id, do_disease_id,                                               #selects the columns from do_disease table 
    ROW_NUMBER() OVER (PARTITION BY omim_id, do_disease_id ORDER BY row_id ASC) AS RowNum               #stores the row_number() value in <RowNum>
    FROM dcdm5.omim_disease                   
)
DELETE FROM dcdm5.omim_disease WHERE row_id IN (SELECT row_id FROM cte WHERE RowNum > 1) #Deletes rows from the 'do_disease' table where row number contained <cte> greater than 1


####--- Checking for duplicates in omim_id to assign it as a primary key ---####
SELECT omim_id, COUNT(*) AS count
FROM dcdm5.omim_disease 
GROUP BY omim_id 
HAVING COUNT(*) > 1
# 1 duplicate found, so omim_id cannot be used as a primary key unfortunately


#So, we retain the auto_incremenent row_id4 column as a primary key
# but rename to omim_pk for better readability.
alter table dcdm5.omim_disease
rename column row_id to omim_pk

####--- Since we have omim_id in our omim_disease table, we don't need it in our dis_inf table. So we can drop it ---####
ALTER TABLE dcdm5.dis_inf 
DROP COLUMN omim_id


#######################################################


####--- Adding foreign keys to dis_inf and omim_disease tables to link with do_disease ---####
ALTER TABLE dcdm5.dis_inf 
ADD FOREIGN KEY (do_disease_id) REFERENCES dcdm5.do_disease (do_disease_id)

ALTER TABLE dcdm5.omim_disease 
ADD FOREIGN KEY (do_disease_id) REFERENCES dcdm5.do_disease(do_disease_id)


#######################################################

####--- Creating the gene table that consists of gene_accession_id and gene_symbol ---####
CREATE TABLE dcdm5.gene_table (
    gene_accession_id varchar (15),
    gene_symbol varchar (10)
)


update dcdm5.merged_df
set parameter_id = "NULL"
where parameter_id is null


####--- Copying the gene_accession_id and gene_symbol values from merged_df table, into gene_table table ---####
INSERT INTO dcdm5.gene_table 
SELECT gene_accession_id, gene_symbol
FROM dcdm5.merged_df


####--- Checking for duplicates in gene_accsession_id to assign it as a primary key ---####
SELECT gene_accession_id, COUNT(*) AS count
FROM dcdm5.gene_table
GROUP BY gene_accession_id 
HAVING COUNT(*) > 1
# 101 gene_accession_id contains duplicates #


####--- Assigning a surrogate primary key ---####
ALTER TABLE dcdm5.gene_table 
ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY FIRST


####--- Common Table Expression (CTE) to rank rows based on 'row_id' ---####
WITH cte AS (                                                                          #cte is a temporary placeholder 
    SELECT row_id, gene_accession_id, gene_symbol,                                     #selects the columns from do_disease table 
    ROW_NUMBER() OVER (PARTITION BY gene_accession_id, gene_symbol ORDER BY row_id ASC) AS RowNum   #stores the row_number() value in <RowNum>
    FROM dcdm5.gene_table                   
)
DELETE FROM dcdm5.gene_table WHERE row_id IN (SELECT row_id FROM cte WHERE RowNum > 1) #Deletes rows from the 'do_disease' table where row number contained <cte> greater than 1


####--- Checking for duplicates in gene_accession_id to assign it as a primary key ---####
SELECT gene_accession_id, COUNT(*) AS count
FROM dcdm5.gene_table 
GROUP BY gene_accession_id 
HAVING COUNT(*) > 1
# 12 gene_accession_id contains duplicates. Thus,it cannot be used as a primary key.
# When we look into it, the reason for all duplicates is due to the next column (gene_symbol) contains no data.
# Therefore, we can remove the entire row if the gene_symbol column contains null, or no data.
## There are also another 12 replicates in gene_accession_id that contains data 'NULL'
## In those replicates, their gene_symbol has already been shown in the other row with complete gene_accession_id
## Therefore, we can also remove the entire row when the gene_accession_id is exactly 'MGI:'.
### This removal will not cause any data lost



# Delete the entire rows if one of the following criteria is met:
# Criteria 1. The gene_accession_id shows Null
# Criteria 2. The gene_symbol shows null
# Criteria 3. The gene_symbol contains no data
DELETE FROM dcdm5.gene_table
WHERE gene_accession_id is NULL
   OR gene_symbol IS NULL
   OR gene_symbol = ''
   
   
-- Checking for duplicates in (gene_accession_id)
select gene_accession_id,
count(*)
from dcdm5.gene_table gimd
group by gene_accession_id
having count(*) > 1 
# no duplicate is found in gene_accession_id
# Therefore, it can be the table's primary key later
   
-- Checking for duplicates in (gene_symbol) 
select gene_symbol,
count(*)
from dcdm5.gene_table gimd 
group by gene_symbol
having count(*) > 1 
# no duplicate is found in gene_symbol 
# Therefore, it shows that each gene_symbol only correspond to one gene_accession_id 


# Insert a nulled column just to fullfill the job of the linking table.
INSERT INTO dcdm5.gene_table (gene_accession_id, gene_symbol)
VALUES ('', '')

####--- Naming the NULL value in gene_accession_id to 'NULL' so we can set gene_accession_id as a primary key ---####
UPDATE dcdm5.gene_table
SET gene_accession_id = 'NULL'
WHERE gene_accession_id = ""


####--- Since we now have a unique gene_accession_id, we can drop the surrogate primary key and make this the new primary key ---####
ALTER TABLE dcdm5.gene_table 
DROP COLUMN row_id


####--- Making gene_accession_id a primary key ---####
ALTER TABLE dcdm5.gene_table 
ADD PRIMARY KEY (gene_accession_id)
# We have now assigned gene_accession_id to a primary key #


#######################################################


####--- Adding foreign keys to merged_df and dis_inf tables to link with gene_table ---####
ALTER TABLE dcdm5.merged_df 
ADD FOREIGN KEY (gene_accession_id) REFERENCES dcdm5.gene_table(gene_accession_id)


####--- The dis_inf table contains gene_accession_id values that do NOT exist in gene_table ---####
# We connect gene_accession_id_nulled in dis_inf table, to gene_acession_id in gene_table, as it has IDs that exist in the gene_table #

UPDATE dcdm5.dis_inf
SET gene_accession_id_nulled = NULL
WHERE gene_accession_id_nulled NOT IN (
    SELECT dcdm5.gene_table.gene_accession_id FROM dcdm5.gene_table
)


####--- Adding foreign keys to dis_inf table to link with gene_table ---####
ALTER TABLE dcdm5.dis_inf 
ADD FOREIGN KEY (gene_accession_id_nulled) REFERENCES dcdm5.gene_table(gene_accession_id)


#######################################################


####--- Creating procedure_data table ---####
CREATE TABLE dcdm5.procedure_data (
    procedure_name varchar(100),
    procedure_description varchar(1000),
    ismandatory varchar(6),
    impc_parameter_orig_id varchar(15)
)

####--- Adding procdure csv into procedure_data table ---#### 
LOAD DATA LOCAL INFILE "/Users/kennieng/Downloads/DCDM_dataset/procedure.csv"
INTO TABLE dcdm5.procedure_data
FIELDS TERMINATED BY ','              #Each column in the csv file is seperated by a comma
OPTIONALLY ENCLOSED BY '"'            #If any values are wrapped in quotes ("value"), remove the quotes automatically 
LINES TERMINATED BY '\n'              #Each row in the file ends with a newline character (standard csv format)
IGNORE 1 ROWS                         #Skips the first row because it contains column headers, not data 


####--- Creating procedure_link table ---####
CREATE TABLE dcdm5.procedure_link( 
    impc_parameter_orig_id varchar(15),
    procedure_name varchar (225)
)


####--- Inserting data from procedure_data into procedure_link table ---####
INSERT INTO dcdm5.procedure_link
SELECT impc_parameter_orig_id, procedure_name
FROM dcdm5.procedure_data


####--- Checking for duplicates in (impc_parameter_orig_id) ---####
SELECT impc_parameter_orig_id,
COUNT(*) AS count
from dcdm5.procedure_link 
group by impc_parameter_orig_id
having count(*) > 1 
# none found, impc_parameter_orig_id can be used as a primary key


####--- Assigning impc_parameter_orig_id as a primary key ---####
ALTER TABLE dcdm5.procedure_link 
ADD PRIMARY KEY (impc_parameter_orig_id)


####--- Finding the primary key for procedure_data ---####
SELECT procedure_name, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.procedure_data   #Check the data in selected table 
GROUP BY procedure_name   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1;  #Only shows id's that appear more than once 
# Running procedure_name gives duplicates #
# We need procedure_name to be the primary key and be unique so that it can link to the procedure_name foreign key in procedure linking table at a later stage #


####--- Assigning a surrogate primary key for procedure_data ---####
ALTER TABLE dcdm5.procedure_data
ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY FIRST


####--- Common Table Expression (CTE) to rank rows based on 'row_id1' for procedure_data ---####
# Run the whole block of code from "with" to ">1)" #
WITH cte AS (                                                                              #cte is a temporary placeholder 
    SELECT row_id, procedure_name, procedure_description, ismandatory,                      #selects the columns from do_disease table 
    ROW_NUMBER () OVER (PARTITION BY procedure_name, procedure_description, ismandatory ORDER BY row_id ASC) AS RowNum          #stores the row_number() value in <RowNum>
    FROM dcdm5.procedure_data                   
)
DELETE FROM dcdm5.procedure_data WHERE row_id IN (SELECT row_id FROM cte WHERE RowNum > 1) #Deletes rows from the 'do_disease' table where row number contained <cte> greater than 1


####--- Checking to see if procedure_name is now eligible to be the primary key for procedure_data ---####
SELECT procedure_name, COUNT(*) AS count  #Shows each id and how many rows use that id 
FROM dcdm5.procedure_data   #Check the data in selected table 
GROUP BY procedure_name   #Puts rows with the same ID into the same bucket 
HAVING COUNT(*) >1  #Only shows id's that appear more than once 
# 4 name (Electrocardiogram(ECG), Viability Primary Screen, Housing and Husbandary, and Experimental design)column contains duplicate
# Therefore, name cannot yet be used as a primary key for the procedure_data table.
# When we look into the duplicates, we found out that every duplicates are having forms of better described row and worse described row. 
# We remove the duplicated row with less description.



#Removing of duplicated row with less description

DELETE FROM dcdm5.procedure_data
WHERE procedure_name = 'Electrocardiogram (ECG)'
  AND procedure_description = ' to provide a high throughput method to obtain electrocardiograms in a conscious mouse.'
  
DELETE FROM dcdm5.procedure_data
WHERE procedure_name = 'Viability Primary Screen'
  AND procedure_description = ''

DELETE FROM dcdm5.procedure_data
WHERE procedure_name = 'Housing and Husbandry'
  AND procedure_description = ''
  
DELETE FROM dcdm5.procedure_data
WHERE procedure_name = 'Experimental design'
  AND procedure_description = ''
  
  
-- Checking for duplicates in procedure_name again 
select procedure_name,
count(*)
from dcdm5.procedure_data
group by procedure_name
having count(*) > 1   
# no duplicates
  


####--- We can now drop the row_id column as we will set procedure_name as the primary key ---####
ALTER TABLE dcdm5.procedure_data
DROP COLUMN row_id


####--- Setting procedure_name as the primary key ---####
ALTER TABLE dcdm5.procedure_data 
ADD PRIMARY KEY (procedure_name)


####--- Drop the impc_parameter_orig_id in procedure_data as we now have a copy of the entire column in procedure_link ---####
ALTER TABLE dcdm5.procedure_data
DROP COLUMN impc_parameter_orig_id


####--- Converting empty strings to NULL in procedure_data table ---####
UPDATE dcdm5.procedure_data
SET procedure_description = NULL
WHERE procedure_description = ''


#######################################################


####--- Adding foreign keys for procedure_link and ipd so that they all link ---####
ALTER TABLE dcdm5.procedure_link
ADD FOREIGN KEY (procedure_name) references dcdm5.procedure_data(procedure_name)

ALTER TABLE dcdm5.ipd
ADD FOREIGN KEY (impc_parameter_orig_id) references dcdm5.procedure_link(impc_parameter_orig_id)


#######################################################
