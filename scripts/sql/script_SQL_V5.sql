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
# none found, 'name' can be used as a primary key


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



alter table dcdm4.procedure_link   
modify impc_parameter_orig_id varchar(5)

alter table dcdm4.procedure_link   
add foreign key (impc_parameter_orig_id) references dcdm4.ipd_csv (impc_parameter_orig_id)

############################################################################

-- Changing column names so they are clearer:

alter table dcdm4.ipd_csv 
rename column name to parameter_name

alter table dcdm4.ipd_csv
rename column description to parameter_description

alter table dcdm4.procedure_data 
rename column name to procedure_name

alter table dcdm4.procedure_data 
rename column description to procedure_description

alter table dcdm4.procedure_link 
rename column name to procedure_name

###############################################################
-- DIS_INF2 - testing

-- DIS_INF2 TABLE:
create table dcdm4.dis_inf2 (
do_disease_id varchar(15) not null,
do_disease_name varchar(200),
omim_id varchar(15),
gene_accession_id varchar(15),
gene_accession_id_nulled varchar(15)
)

load data local infile "C:/Users/Owner/OneDrive - King's College London/1 MSc Applied Bioinformatics/2 Data Cleaning and Management/Group 5 Coursework/18.11.25 csv files/dis_inf_null.csv"
into table dcdm4.dis_inf2
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

alter table dis_inf2 
add column disease_id int primary key auto_increment not null


# DISEASE_DO TABLE

create table do_disease (
do_disease_id varchar(15) not null,
do_disease_name varchar(200)
)


insert into dcdm4.do_disease 
select do_disease_id, do_disease_name
from dcdm4.dis_inf2


-- Checking for duplicates in (do_disease_id)
select do_disease_id,
count(*)
from dcdm4.do_disease dd 
group by do_disease_id
having count(*) > 1 
# result: 423 duplicates


alter table dcdm4.do_disease 
add column row_id3 int primary key auto_increment not null


-- Common Table Expression (CTE) to rank rows based on 'row_id1'
with cte3 as ( #using cte as a temporary placeholder
    select row_id3, do_disease_id, do_disease_name, #select the merged_df columns
    row_number() over (partition by do_disease_id order by row_id3 asc) as RowNum #store the row_number() value in <RowNum>
    from dcdm4.do_disease dd 
)
-- Delete rows from the 'parameter_data' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from dcdm4.do_disease where row_id3 in (select row_id3 from cte3 where RowNum > 1)


-- Checking for duplicates in (do_disease_id)
select do_disease_id,
count(*)
from dcdm4.do_disease dd  
group by do_disease_id
having count(*) > 1 
# none found, do_disease_id can be used as a primary key


alter table dcdm4.do_disease 
drop column row_id3


alter table dcdm4.do_disease  
add primary key (do_disease_id)

##############################################################

-- OMIM_DISEASE TABLE:

create table omim_disease (
omim_id varchar(15),
do_disease_id varchar(15)
)

insert into dcdm4.omim_disease
select omim_id, do_disease_id
from dcdm4.dis_inf2


-- Checking for duplicates in (omim_id)
select omim_id,
count(*)
from dcdm4.omim_disease
group by omim_id
having count(*) > 1 
# result: 579 duplicates


alter table dcdm4.omim_disease 
add column row_id4 int primary key auto_increment not null


-- Common Table Expression (CTE) to rank rows based on 'row_id1'
with cte4 as ( #using cte as a temporary placeholder
    select row_id4, omim_id, do_disease_id, #select the merged_df columns
    row_number() over (partition by omim_id order by row_id4 asc) as RowNum #store the row_number() value in <RowNum>
    from dcdm4.omim_disease 
)
-- Delete rows from the 'parameter_data' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from dcdm4.omim_disease where row_id4 in (select row_id4 from cte4 where RowNum > 1)


-- Checking for duplicates in (do_disease_id)
select do_disease_id,
count(*)
from dcdm4.do_disease dd  
group by do_disease_id
having count(*) > 1 
# none found, omim_id can be used as a primary key


alter table dcdm4.omim_disease  
drop column row_id4


alter table dcdm4.omim_disease 
add primary key (omim_id)

alter table dis_inf2 
drop column do_disease_name

alter table dis_inf2 
drop column omim_id

#############################################################################

-- GENE_ID_MERGED_DF TABLE

create table dcdm4.gene_id_merged_df (
gene_accession_id varchar(15) not null,
gene_symbol varchar(10)
)


insert into dcdm4.gene_id_merged_df 
select gene_accession_id, gene_symbol
from dcdm4.merged_df


alter table dcdm4.gene_id_merged_df  
add column row_id2 int primary key auto_increment not null


-- Common Table Expression (CTE) to rank rows based on 'row_id1'
with cte2 as ( #using cte as a temporary placeholder
    select row_id2, gene_accession_id, gene_symbol, #select the merged_df columns
    row_number() over (partition by gene_accession_id order by row_id2 asc) as RowNum #store the row_number() value in <RowNum>
    from dcdm4.gene_id_merged_df
)
-- Delete rows from the 'parameter_data' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from dcdm4.gene_id_merged_df where row_id2 in (select row_id2 from cte2 where RowNum > 1)


-- Checking for duplicates in (gene_accession_id)
select gene_accession_id,
count(*)
from dcdm4.gene_id_merged_df gimd 
group by gene_accession_id
having count(*) > 1 
# none found, gene_accession_id can be used as a primary key


alter table dcdm4.gene_id_merged_df 
drop column row_id2


alter table dcdm4.gene_id_merged_df 
add primary key (gene_accession_id)

alter table dcdm4.merged_df 
add foreign key (gene_accession_id) references dcdm4.gene_id_merged_df 


update dcdm4.dis_inf2
SET gene_accession_id_nulled = NULL
where gene_accession_id_nulled not in (
    select gene_accession_id FROM dcdm4.gene_id_merged_df gimd
);


alter table dcdm4.dis_inf2
add foreign key (gene_accession_id_nulled) references dcdm4.gene_id_merged_df 


alter table dis_inf2 
add foreign key (do_disease_id) references dcdm4.do_disease (do_disease_id)

alter table omim_disease 
add foreign key (do_disease_id) references dcdm4.do_disease 
