create database dcdm4

set global local_infile = 1
use dcdm4

-- PROCEDURE_LINK TABLE

create table dcdm4.procedure_link (
name varchar(100) not null,
description varchar(1000) not null,
ismandatory varchar(6) not null, 
impc_parameter_orig_id int
)

load data local infile "C:/Users/Owner/OneDrive - King's College London/1 MSc Applied Bioinformatics/2 Data Cleaning and Management/Group 5 Coursework/18.11.25 csv files/procedure.csv"
into table dcdm4.procedure_link
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- Checking for duplicates in (impc_parameter_orig_id)
select impc_parameter_orig_id,
count(*)
from dcdm2.procedure_link 
group by impc_parameter_orig_id
having count(*) > 1 
# none found, impc_parameter_orig_id can be used as a primary key

alter table dcdm4.procedure_link 
add primary key (impc_parameter_orig_id)

create table dcdm4.procedure_data (
name varchar(100) not null,
description varchar(1000) not null,
ismandatory varchar(6) not null
)

insert into dcdm4.procedure_data 
select name, description, ismandatory
from dcdm4.procedure_link

-- Checking for duplicates in (name)
select name,
count(*)
from dcdm4.procedure_data
group by name
having count(*) > 1 
# result: 51


alter table dcdm4.procedure_data 
add column row_id1 int primary key auto_increment not null


-- Common Table Expression (CTE) to rank rows based on 'row_id1'
with cte1 as ( #using cte as a temporary placeholder
    select row_id1, name, description, ismandatory, #select the procedure_data columns
    row_number() over (partition by name order by row_id1 asc) as RowNum #store the row_number() value in <RowNum>
    from dcdm4.procedure_data
)
-- Delete rows from the 'parameter_data' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from dcdm4.procedure_data where row_id1 in (select row_id1 from cte1 where RowNum > 1)


-- Checking for duplicates in (name)
select name,
count(*)
from dcdm4.procedure_data
group by name
having count(*) > 1 
# none found, impc_parameter_orig_id can be used as a primary key


alter table dcdm4.procedure_data
drop column row_id1

alter table dcdm4.procedure_data 
add primary key(name)

alter table dcdm4.procedure_link 
drop column description

alter table dcdm4.procedure_link 
drop column ismandatory

alter table dcdm4.procedure_link 
add foreign key (name) references dcdm4.procedure_data(name)

##############################################################

-- IPD_CSV
-- Creating ipd table:
create table dcdm4.ipd_csv (
impc_parameter_orig_id varchar(5) not null, #this is "not null" so it can be altered to primary key later
parameter_id varchar(100),
parameter_id_nulled varchar(100),
name varchar(100),
description varchar(500)
)

load data local infile "C:/Users/Owner/OneDrive - King's College London/1 MSc Applied Bioinformatics/2 Data Cleaning and Management/Group 5 Coursework/18.11.25 csv files/ipd_null.csv"
into table dcdm4.ipd_csv
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows

-- Checking for duplicates in ipd_csv(impc_parameter_orig_id)
select impc_parameter_orig_id,
count(*)
from dcdm4.ipd_csv ic  
group by impc_parameter_orig_id
having count(*) > 1 
# none found, impc_parameter_orig_id can be used as a primary key

alter table dcdm4.ipd_csv 
add primary key (impc_parameter_orig_id)


#############################################################################


-- MERGED_DF:

create table dcdm4.merged_df (
gene_accession_id varchar(12),
analysis_id varchar(30),
gene_symbol varchar(10),
mouse_strain varchar(6),
mouse_life_stage varchar(100),
parameter_id varchar(100),
parameter_name varchar(200),
pvalue decimal (10,8) null
);

load data local infile "C:/Users/Owner/OneDrive - King's College London/1 MSc Applied Bioinformatics/2 Data Cleaning and Management/Group 5 Coursework/18.11.25 csv files/merged_df.csv"
into table dcdm4.merged_df
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


-- Checking for duplicates in merged_df(analysis_id)
select analysis_id,
count(*)
from dcdm4.merged_df 
group by analysis_id
having count(*) > 1 
# none found, analysis_id can be used as a primary key

alter table dcdm4.merged_df
add primary key(analysis_id)


update dcdm4.merged_df
set gene_accession_id = concat('MGI:', gene_accession_id)
where gene_accession_id not like 'MGI:%'


#####################################################

-- PARAM_ID_MERGED_DF

create table dcdm4.param_id_merged_df (
parameter_id varchar(100) not null
)

insert into dcdm4.param_id_merged_df (parameter_id)
select distinct md.parameter_id
from dcdm4.merged_df md 
left join dcdm4.param_id_merged_df pimd
    on md.parameter_id = pimd.parameter_id
where pimd.parameter_id is null;


update dcdm4.ipd_csv
SET parameter_id_nulled = NULL
where parameter_id_nulled not in (
    select parameter_id FROM dcdm4.param_id_merged_df
);

alter table dcdm4.param_id_merged_df 
add primary key (parameter_id)



#################################################################################

-- ADDING FOREIGN KEYS:

alter table dcdm4.ipd_csv 
add foreign key (parameter_id_nulled) references dcdm4.param_id_merged_df (parameter_id)


alter table dcdm4.merged_df 
add foreign key (parameter_id) references dcdm4.param_id_merged_df(parameter_id)



##################################################################################

-- DIS_INF TABLE:
create table dcdm4.dis_inf (
do_disease_id varchar(1000) not null,
do_disease_name varchar(200),
omim_id varchar(15),
gene_accession_id varchar(15),
gene_accession_id_nulled varchar(15)
)

load data local infile "C:/Users/Owner/OneDrive - King's College London/1 MSc Applied Bioinformatics/2 Data Cleaning and Management/Group 5 Coursework/18.11.25 csv files/dis_inf_null.csv"
into table dcdm4.dis_inf
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

alter table dcdm4.dis_inf 
add column disease_id int primary key auto_increment not null


##################################################################################

-- GENE_ID_MERGED_DF TABLE

create table dcdm4.gene_id_merged_df (
gene_accession_id varchar(15) not null
)


insert into dcdm4.gene_id_merged_df (gene_accession_id)
select distinct md.gene_accession_id
from dcdm4.merged_df md
left join dcdm4.gene_id_merged_df gimd 
	on md.gene_accession_id = gimd.gene_accession_id
where gimd.gene_accession_id is null

alter table dcdm4.gene_id_merged_df 
add primary key (gene_accession_id)

alter table dcdm4.merged_df 
add foreign key (gene_accession_id) references dcdm4.gene_id_merged_df 

update dcdm4.dis_inf
SET gene_accession_id_nulled = NULL
where gene_accession_id_nulled not in (
    select gene_accession_id FROM dcdm4.gene_id_merged_df gimd
);


alter table dcdm4.dis_inf
add foreign key (gene_accession_id_nulled) references dcdm4.gene_id_merged_df 



alter table dcdm4.procedure_link   
modify impc_parameter_orig_id varchar(5)

alter table dcdm4.procedure_link   
add foreign key (impc_parameter_orig_id) references dcdm4.ipd_csv (impc_parameter_orig_id)

SELECT DISTINCT i.name
FROM dcdm4.ipd_csv i
LEFT JOIN dcdm4.procedure_link pl 
    ON i.name = pl.name
WHERE pl.name IS NULL;


