set global local_infile = 1
use dcdm2

-- PROCEDURE_LINK TABLE

create table dcdm2.procedure_link (
name varchar(100) not null,
description varchar(1000) not null,
ismandatory varchar(6) not null, 
impc_parameter_orig_id int
)

load data local infile "C:/Users/Owner/OneDrive - King's College London/1 MSc Applied Bioinformatics/2 Data Cleaning and Management/Group 5 Coursework/18.11.25 csv files/procedure.csv"
into table procedure_link
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

alter table dcdm2.procedure_link 
add primary key (impc_parameter_orig_id)

create table dcdm2.procedure_data (
name varchar(100) not null,
description varchar(1000) not null,
ismandatory varchar(6) not null
)

insert into dcdm2.procedure_data 
select name, description, ismandatory
from dcdm2.procedure_link

-- Checking for duplicates in (name)
select name,
count(*)
from dcdm2.procedure_data
group by name
having count(*) > 1 
# result:


alter table dcdm2.procedure_data 
add column row_id1 int primary key auto_increment not null


-- Common Table Expression (CTE) to rank rows based on 'row_id1'
with cte1 as ( #using cte as a temporary placeholder
    select row_id1, name, description, ismandatory, #select the procedure_data columns
    row_number() over (partition by name order by row_id1 asc) as RowNum #store the row_number() value in <RowNum>
    from dcdm2.procedure_data
)
-- Delete rows from the 'parameter_data' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from dcdm2.procedure_data where row_id1 in (select row_id1 from cte1 where RowNum > 1)


-- Checking for duplicates in (name)
select name,
count(*)
from dcdm2.procedure_data
group by name
having count(*) > 1 
# none found, impc_parameter_orig_id can be used as a primary key


alter table dcdm2.procedure_data
drop column row_id1

alter table dcdm2.procedure_data 
add primary key(name)

alter table dcdm2.procedure_link 
drop column description

alter table dcdm2.procedure_link 
drop column ismandatory

alter table dcdm2.procedure_link 
add foreign key (name) references dcdm2.procedure_data(name)


alter table dcdm2.ipd_csv 
add foreign key (impc_parameter_orig_id) references dcdm2.procedure_link (impc_parameter_orig_id)

##############################################################

-- IPD_CSV
-- Creating ipd table:
create table dcdm2.ipd_csv (
parameter_id varchar(100),
impc_parameter_orig_id varchar(5) not null, #this is "not null" so it can be altered to primary key later
name varchar(100),
description varchar(500)
)

load data local infile "C:/Users/Owner/OneDrive - King's College London/1 MSc Applied Bioinformatics/2 Data Cleaning and Management/Group 5 Coursework/18.11.25 csv files/ipd.csv"
into table ipd_csv
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows

-- Checking for duplicates in ipd_csv(impc_parameter_orig_id)
select impc_parameter_orig_id,
count(*)
from dcdm2.ipd_csv ic  
group by impc_parameter_orig_id
having count(*) > 1 
# none found, impc_parameter_orig_id can be used as a primary key

alter table dcdm2.ipd_csv 
add primary key (impc_parameter_orig_id)

alter table dcdm2.ipd_csv 
modify impc_parameter_orig_id int

-- MERGED_DF:

create table dcdm2.merged_df (
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
into table merged_df
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


-- Checking for duplicates in merged_df(analysis_id)
select analysis_id,
count(*)
from dcdm2.merged_df md   
group by analysis_id
having count(*) > 1 
# none found, analysis_id can be used as a primary key

alter table dcdm2.merged_df 
add primary key(analysis_id)


update dcdm2.merged_df md 
set gene_accession_id = concat('MGI:', gene_accession_id)
where gene_accession_id not like 'MGI:%'


#####################################################

-- PARAM_ID_MERGED_DF:

create table param_id_merged_df (
parameter_id varchar(100) not null
)

-- Checking for duplicates in merged_df(parameter_id)
select parameter_id,
count(*)
from dcdm2.merged_df md   
group by parameter_id
having count(*) > 1 
# 198 found

insert into dcdm2.param_id_merged_df 
select distinct md.parameter_id
from dcdm2.merged_df md 
left join dcdm2.param_id_merged_df pimd 
	on md.parameter_id = pimd.parameter_id
where pimd.parameter_id is null


-- Checking for duplicates in param_id_merged_df(parameter_id)
select parameter_id,
count(*)
from dcdm2.param_id_merged_df pimd 
group by parameter_id
having count(*) > 1 
# none found, can be made primary key

alter table dcdm2.param_id_merged_df 
add primary key (parameter_id)

#################################################################################

-- ADDING FOREIGN KEYS:

alter table dcdm2.merged_df 
add foreign key (parameter_id) references dcdm2.param_id_merged_df(parameter_id)



##################################################################################

-- PARAM_ID_IPD

create table param_id_ipd (
parameter_id varchar(100) not null
)

-- Checking for duplicates in ipd_csv(parameter_id)
select parameter_id,
count(*)
from dcdm2.ipd_csv ic 
group by parameter_id
having count(*) > 1 
# 1107 found

insert into dcdm2.param_id_ipd (parameter_id)
select distinct ic.parameter_id
from dcdm2.ipd_csv ic
left join dcdm2.param_id_ipd pii 
	on ic.parameter_id = pii.parameter_id
where pii.parameter_id is null


-- Checking for duplicates in param_id_ipd(parameter_id)
select parameter_id,
count(*)
from dcdm2.param_id_merged_df pimd 
group by parameter_id
having count(*) > 1 
# none found, can be made primary key

alter table dcdm2.param_id_ipd
add primary key (parameter_id)

alter table dcdm2.ipd_csv 
add foreign key (parameter_id) references dcdm2.param_id_ipd(parameter_id)


update dcdm2.ipd_csv
SET parameter_id = NULL
where parameter_id not in (
    select parameter_id FROM dcdm2.param_id_merged_df
);

alter table dcdm2.ipd_csv 
add foreign key (parameter_id) references dcdm2.param_id_merged_df (parameter_id)



#################################################################################

-- DIS_INF TABLE:
create table dcdm2.dis_inf (
do_disease_id varchar(1000) not null,
do_disease_name varchar(200),
omim_id varchar(15),
gene_accession_id varchar(15)
)

load data local infile "C:/Users/Owner/OneDrive - King's College London/1 MSc Applied Bioinformatics/2 Data Cleaning and Management/Group 5 Coursework/18.11.25 csv files/dis_inf (from 18.11).csv"
into table dis_inf
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

alter table dcdm2.dis_inf 
add column disease_id int primary key auto_increment not null


##################################################################################

-- GENE_ID_MERGED_DF_TABLE

create table gene_id_merged_df (
gene_accession_id varchar(15) not null
)


insert into dcdm2.gene_id_merged_df (gene_accession_id)
select distinct md.gene_accession_id
from dcdm2.merged_df md 
left join dcdm2.gene_id_merged_df gimd 
	on md.gene_accession_id = gimd.gene_accession_id
where gimd.gene_accession_id is null

alter table dcdm2.gene_id_merged_df 
add primary key (gene_accession_id)

alter table dcdm2.merged_df 
add foreign key (gene_accession_id) references dcdm2.gene_id_merged_df 

update dcdm2.dis_inf
SET gene_accession_id = NULL
where gene_accession_id not in (
    select gene_accession_id FROM dcdm2.gene_id_merged_df gimd
);


alter table dcdm2.dis_inf
add foreign key (gene_accession_id) references dcdm2.gene_id_merged_df 









