create database dcdm2
use dcdm2

-- DIS_INF TABLE

create table dcdm2.dis_inf (disease_id int auto_increment not null,
do_disease_id varchar(1000) not null,
omim_id int null,
do_disease_name varchar(200),
gene_accession_id varchar(15),
primary key (disease_id)
)

alter table dcdm2.dis_inf 
add foreign key (gene_accession_id) references dcdm2.gene_info_merged_df (gene_accession_id)


 # select gene_accession_id from dcdm_2.dis_inf di where di.do_disease_id = "12960"
 
 # select gene_accession_id from dcdm_2.dis_inf di where di.do_disease_id = 12960
 
 # select gene_accession_id from dcdm_2.dis_inf di where di.omim_id  = "101200"
  
 # select gene_accession_id from dcdm_2.dis_inf di where di.omim_id  = 101200

  
  




#######################################################


-- PROCEDURE_CSV TABLE

create table dcdm2.procedure_csv (procedure_id int auto_increment not null,
name varchar(100) not null,
description varchar(1000) not null,
ismandatory varchar(6) not null, 
impc_parameter_orig_id varchar(5),
primary key (procedure_id)
)

alter table dcdm2.procedure_csv 
drop column procedure_id

alter table dcdm2.procedure_csv 
add primary key (impc_parameter_orig_id)



##################################################


-- MERGE_DF TABLE:

create table dcdm2.merged_df (
gene_accession_id varchar(12),
analysis_id varchar(30),
gene_symbol varchar(10),
mouse_strain varchar(6),
mouse_life_stage varchar(100),
parameter_id varchar(100),
pvalue decimal(10,8),
primary key (analysis_id)
)


update dcdm2.merged_df md 
set gene_accession_id = concat('MGI:', gene_accession_id)
where gene_accession_id not like 'MGI:%'


###################################################################################################

-- IPD_CSV TABLE:

-- Creating ipd table (for the schema):
create table dcdm2.ipd_csv (
parameter_id varchar(100),
impc_parameter_orig_id varchar(5) not null, #this is "not null" so it can be altered to primary key later
name varchar(100),
description varchar(500),
primary key (impc_parameter_orig_id)
)

select count(*)
from dcdm_2.ipd_csv ic 


alter table dcdm2.procedure_csv 
add foreign key (impc_parameter_orig_id) references dcdm2.ipd_csv (impc_parameter_orig_id)


alter table dcdm2.ipd_csv 
add foreign key (parameter_id) references dcdm2.param_id_merged_df (parameter_id)



###########################################################


#GENE_INFO_MERGED_DF TABLE:

create table dcdm2.gene_info_merged_df (
gene_accession_id varchar(15) not null
)


insert into dcdm2.gene_info_merged_df 
select gene_accession_id
from dcdm2.merged_df 


select count(*)
from dcdm2.gene_info_merged_df #28,560


-- Checking for duplicates in gene_info(gene_accession_id)
select gene_accession_id,
count(*)
from dcdm2.gene_info_merged_df 
group by gene_accession_id
having count(*) > 1
#Result before deletion: 101 duplicates
#Result after deletion: 0 duplicates


alter table dcdm2.gene_info_merged_df 
add column row_id4 int primary key auto_increment not null


-- Common Table Expression (CTE) to rank rows based on 'row_id3'
with cte2 as ( #using cte as a temporary placeholder
    select row_id3, gene_accession_id, #select the parameter_data columns
    row_number() over (partition by gene_accession_id order by row_id3 asc) as RowNum #store the row_number() value in <RowNum>
    from dcdm2.gene_info_merged_df
)
-- Delete rows from the 'parameter_data' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from dcdm2.gene_info_merged_df where row_id3 in (select row_id3 from cte2 where RowNum > 1)

alter table dcdm2.gene_info_merged_df
drop column row_id3

alter table dcdm2.gene_info_merged_df
add primary key (gene_accession_id)

alter table dcdm2.merged_df 
add foreign key (gene_accession_id) references dcdm2.gene_info_dis_inf (gene_accession_id) 




#############################################################


# PARAMETER_ID_MERGED_DF:

create table param_id_merged_df (
parameter_id varchar(100) not null
)

insert into dcdm2.param_id_merged_df 
select parameter_id
from dcdm2.merged_df 


-- Checking for duplicates in param_id_merged_df(parameter_id)
select parameter_id,
count(*)
from dcdm2.param_id_merged_df pimd 
group by parameter_id
having count(*) > 1
#Result before deletion: 198 duplicates
#Result after deletion: 0 duplicates

alter table dcdm2.param_id_merged_df 
add column row_id5 int primary key auto_increment not null


-- Common Table Expression (CTE) to rank rows based on 'row_id3'
with cte4 as ( #using cte as a temporary placeholder
    select row_id5, parameter_id, #select the parameter_data columns
    row_number() over (partition by parameter_id order by row_id5 asc) as RowNum #store the row_number() value in <RowNum>
    from dcdm2.param_id_merged_df
)
-- Delete rows from the 'parameter_data' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from dcdm2.param_id_merged_df  where row_id5 in (select row_id5 from cte4 where RowNum > 1)

alter table dcdm2.param_id_merged_df 
drop column row_id5

alter table dcdm2.param_id_merged_df  
add primary key (parameter_id)

alter table dcdm2.merged_df 
add foreign key (parameter_id) references dcdm2.param_id_merged_df (parameter_id)


alter table dcdm2.gene_info_merged_df  
drop column disease_id

alter table dcdm2.dis_inf 
add foreign key (gene_accession_id) references dcdm2.gene_info_merged_df (gene_accession_id)



##########################################################################################

#GENE_INFO_DIS_INF:

create table dcdm4.gene_info_dis_inf (
gene_accession_id varchar(15) not null,
disease_id int not null
)

insert into dcdm4.gene_info_dis_inf 
select gene_accession_id, disease_id
from dcdm2.dis_inf  

-- Checking for duplicates in gene_info_dis_inf(gene_accession_id)
select disease_id,
count(*)
from dcdm4.gene_info_dis_inf 
group by disease_id
having count(*) > 1
#Result before deletion: 0 duplicates
#Result after deletion: 0 duplicates


alter table dcdm4.gene_info_dis_inf 
add column row_id1 int primary key auto_increment not null



-- Common Table Expression (CTE) to rank rows based on 'row_id3'
with cte1 as ( #using cte as a temporary placeholder
    select disease_id, gene_accession_id, #select the parameter_data columns
    row_number() over (partition by gene_accession_id order by disease_id asc) as RowNum #store the row_number() value in <RowNum>
    from dcdm4.gene_info_dis_inf
)
-- Delete rows from the 'parameter_data' table where the row number contained in <cte> is greater than 1
-- so delete any instances of impc_parameter_orig_id that occur for the 2nd time or more
delete from dcdm4.gene_info_dis_inf  where disease_id in (select disease_id from cte1 where RowNum > 1)

alter table dcdm4.gene_info_dis_inf 
drop column row_id1

alter table dcdm4.gene_info_dis_inf  
add primary key (gene_accession_id)

alter table dcdm4.gene_info_dis_inf 
add foreign key (disease_id) references dcdm4.dis_inf (disease_id)

alter table dcdm4.gene_info_dis_inf 
add primary key (disease_id)

alter table dcdm4.merged_df  
add foreign key (gene_accession_id) references dcdm4.gene_info_dis_inf (gene_accession_id)



##########################################################################





#select the name in ipd csv where gene symbol = Hmgn2

select name
FROM dcdm2.ipd_csv ic 
JOIN dcdm2.merged_df md 
    on merged_df(gene_symbol) = ipd_csv(gene_symbol)
WHERE merged_df(gene_symbol) = 'Hmgn2'

