show databases
use nabiha_sql_2

###########################################


-- DIS_INF TABLE

create table nabiha_sql_2.dis_inf (disease_id int auto_increment not null,
do_disease_id varchar(1000) not null,
omim_id int null,
do_disease_name varchar(200),
gene_accession_id varchar(15),
primary key (disease_id)
)


 # select gene_accession_id from nabiha_sql_2.dis_inf di where di.do_disease_id = "12960"
 
 # select gene_accession_id from nabiha_sql_2.dis_inf di where di.do_disease_id = 12960
 
 # select gene_accession_id from nabiha_sql_2.dis_inf di where di.omim_id  = "101200"
  
 # select gene_accession_id from nabiha_sql_2.dis_inf di where di.omim_id  = 101200

  
  




#######################################################


-- PROCEDURE_CSV TABLE

create table nabiha_sql_2.procedure_csv (procedure_id int auto_increment not null,
name varchar(100) not null,
description varchar(1000) not null,
ismandatory varchar(6) not null, 
impc_parameter_orig_id varchar(5),
primary key (procedure_id)
)

alter table nabiha_sql_2.procedure_csv 
add foreign key (impc_parameter_orig_id) references nabiha_sql_2.ipd_csv(impc_parameter_orig_id)


##################################################


-- MERGE_DF TABLE:

create table nabiha_sql_2.merged_df (
gene_accession_id varchar(12),
analysis_id varchar(30),
gene_symbol varchar(10),
mouse_strain varchar(6),
mouse_life_stage varchar(100),
parameter_id varchar(100),
pvalue decimal(10,8),
primary key (analysis_id)
)

#alter table nabiha_sql_2.merged_df
#add foreign key (gene_accession_id) references dis_inf(gene_accession_id);

#alter table nabiha_sql_2.merged_df
#add foreign key (parameter_id) references ipd_csv(parameter_id)

#######################################################

-- IPD_CSV TABLE:

#create table nabiha_sql_2.ipd_csv (
#parameter_id varchar(100),
#impc_parameter_orig_id varchar(5),
#name varchar(100),
#description varchar(500),
#primary key (impc_parameter_orig_id)
#)



-- Creating ipd table (for the schema):
create table nabiha_sql_2.ipd_csv (
row_id int auto_increment not null,
parameter_id varchar(100),
impc_parameter_orig_id varchar(5) not null, #this is "not null" so it can be altered to primary key later
name varchar(100),
description varchar(500),
primary key (row_id)
)

alter table nabiha_sql_2.ipd_csv 
add constraint fk_ipd_parameter_id unique (parameter_id)


-- Checking for duplicates in ipd_csv
select impc_parameter_orig_id,
count(*)
from nabiha_sql_2.ipd_csv ic 
group by impc_parameter_orig_id
having count(*) > 1

-- Retrieving parameter_id for a specific impc_parameter_orig_id:
#select parameter_id from nabiha_sql_2.ipd_csv ic where impc_parameter_orig_id = 17587

-- Common Table Expression (CTE) to rank rows based on 'parameter_id'
with cte as ( #using cte as a temporary placeholder
    select row_id, impc_parameter_orig_id, parameter_id, name, description, #select the ipd_csv columns
    row_number() over (partition by impc_parameter_orig_id order by row_id asc) as RowNum #store the row_number() value in <RowNum>
    from nabiha_sql_2.ipd_csv
)
-- Delete rows from the 'ipd_csv' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from nabiha_sql_2.ipd_csv where row_id in (select row_id from cte where RowNum > 1)


-- A way to check that the CTE contains the correct data values BEFORE we delete anything
#select row_id, impc_parameter_orig_id 
#from cte
#where RowNum > 1


#We can now add 'impc_parameter_orig_id' as a primary key
#for ipd_csv as the values are now all unique.
alter table nabiha_sql_2.ipd_csv
drop column row_id

alter table nabiha_sql_2.ipd_csv
add primary key (impc_parameter_orig_id)

select count(*)
from nabiha_sql_2.ipd_csv ic 


-- Explanation for the above ^:
-- There were 14 duplicates in the impc_parameter_orig_id column, so this column could not be used as a primary key like we wanted.
-- To resolve this:
-- 1. created an auto_increment int <row_id> column as the initial primary key for the ipd_csv table
-- 2. using row_number() sorted the data by row_id + partitioned by impc_parameter_orig_id > stored this in temporary cte
-- 3. deleted the rows that satisfied the cte conditions, i.e. deleted all duplicates after the first instance of a specific impc_parameter_orig_id
-- 4. dropped the row_id column from the ipd_csv table (aka the primary key)
-- 5. added the new primary key (impc_parameter_orig_id) which was already constrained as 'not null' when ipd_csv was first created


##########################################


#PARAMETER_DATA TABLE:

create table nabiha_sql_2.parameter_data (
#row_id2 int auto_increment not null,
parameter_id varchar(100) not null,
name varchar(100),
description varchar(500)
#primary key (row_id2)
)


insert into nabiha_sql_2.parameter_data 
select parameter_id, name, description
from nabiha_sql_2.ipd_csv 

select count(*)
from nabiha_sql_2.parameter_data pd 

alter table nabiha_sql_2.parameter_data 
add column row_id2 int primary key auto_increment not null

-- Checking for duplicates in parameter_data
select parameter_id,
count(*)
from nabiha_sql_2.parameter_data pd 
group by parameter_id
having count(*) > 1

select name, description from nabiha_sql_2.parameter_data pd where parameter_id = "IMPC_EYE_034_001"


-- Common Table Expression (CTE) to rank rows based on 'row_id'
with cte1 as ( #using cte as a temporary placeholder
    select row_id2, parameter_id, name, description, #select the parameter_data columns
    row_number() over (partition by parameter_id order by row_id2 asc) as RowNum #store the row_number() value in <RowNum>
    from nabiha_sql_2.parameter_data
)
-- Delete rows from the 'parameter_data' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from nabiha_sql_2.parameter_data where row_id2 in (select row_id2 from cte1 where RowNum > 1)

alter table nabiha_sql_2.parameter_data 
drop column row_id2

alter table nabiha_sql_2.parameter_data 
add primary key (parameter_id)

alter table nabiha_sql_2.ipd_csv 
add constraint fk_ipd_parameter_id
foreign key (parameter_id) references nabiha_sql_2.parameter_data(parameter_id)

alter table nabiha_sql_2.ipd_csv 
drop column name

alter table nabiha_sql_2.ipd_csv
drop column description




###########################################################





#GENE_INFO TABLE:

create table nabiha_sql_2.gene_info (
gene_accession_id varchar(15) not null,
disease_id int
)


insert into nabiha_sql_2.gene_info 
select gene_accession_id, disease_id
from nabiha_sql_2.dis_inf


select count(*)
from nabiha_sql_2.gene_info gi 


-- Checking for duplicates in gene_info(gene_accession_id)
select gene_accession_id,
count(*)
from nabiha_sql_2.gene_info gi 
group by gene_accession_id
having count(*) > 1
#Result: 650 duplicates

alter table nabiha_sql_2.gene_info 
add column row_id3 int primary key auto_increment not null



-- Common Table Expression (CTE) to rank rows based on 'row_id3'
with cte2 as ( #using cte as a temporary placeholder
    select row_id3, gene_accession_id, disease_id, #select the parameter_data columns
    row_number() over (partition by parameter_id order by row_id3 asc) as RowNum #store the row_number() value in <RowNum>
    from nabiha_sql_2.parameter_data
)
-- Delete rows from the 'parameter_data' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from nabiha_sql_2.parameter_data where row_id3 in (select row_id3 from cte2 where RowNum > 1)








#############################################################


#NEW_DATA TABLE:

create table nabiha_sql.new_data (
new_data_id int auto_increment not null,
analysis_id varchar(30),
gene_accession_id varchar(12),
disease_id int,
primary key (new_data_id)
)



