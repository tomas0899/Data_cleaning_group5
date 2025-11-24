use dcdm5
set global local_infile = 1

##################################################################################################

# GENE SYMBOLS TO QUERY: Ica1, Dclk1, Lpcat1, Irag2

##################################################################################################

-- QUERIES TO SELECT THE DISTINCT PARAMETERS ASSOCIATED WITH EACH GENOTYPE

#### Explanation: ####
# Select the distinct parameter_name in merged_df 
# where the gene_symbol is 'x'

select distinct parameter_name from merged_df where gene_symbol = "Ica1"; #171 results

select distinct parameter_name from merged_df where gene_symbol = "Dclk1"; #175 results

select distinct parameter_name from merged_df where gene_symbol = "Lpcat1"; #174 results

select distinct parameter_name from merged_df where gene_symbol = "Irag2"; #175 results




-- QUERIES TO SELECT THE PARAMETER_GROUP_IDs + PARAMETER_GROUP_NAMEs
-- THAT ARE ASSOCIATED WITH EACH GENOTYPE:


#### EXPLANATION:####
# 1. Filtering by gene_symbol = 'x', we start from merged_df(parameter_id),
# 2. Join to param_id_merged_df (alias pimd) table (which contains unique parameter_ids that are sourced from merged_df)
#	 So looking for parameter_ids that are the same in merged_df and pimd.
#	 This does not add new information, but enforces consistency
# 3. Join to ipd_csv, where parameter_ids match between ipd and pimd
#	 Allows us to fetch the impc_parameter_orig_id, which links ipd to procedure info
# 4. Join to parameter_group_membership, based on impc_parameter_orig_ids that match between parameter_group_membership and ipd
# 5. Join to parameter_group, based on parameter_group_ids that match between the parameter_group_membership and parameter_group tables
# 6. Retrieve/select the parameter_group_id and the parameter_group_names of the parameters associated with gene_symbol 'x'.
### We can now know which parameter groups are associated with gene_symbol 'x' based on its parameters.



select distinct       # Select the distinct group_ids and group_names (so you only get one result for each)
    pg.Parameter_Group_id,
    pg.Parameter_Group_name
from merged_df m 				# Starting from the merged_df, alias 'm' (it contains the parameter_id, linking to pimd).
join param_id_merged_df pimd 	# Join to param_id_merged_df, alias 'pimd' > this is our linking table between merged_df and ipd_csv.
    on m.parameter_id = pimd.parameter_id 	# based on when parameter_id is the same in m and in pimd
join ipd ipd 							# Join to ipd_csv, alias 'ipd' > contains impc_parameter_orig_id which links to our parameter group info
    on m.parameter_id = ipd.parameter_id 	# based on when m. and ipd. parameter_ids are the same
join parameter_group_membership pgm 		# Join to parameter_group_membership, alias 'pgm' table, which links impc ids to parameter_Group_Id
    on ipd.impc_parameter_orig_id = pgm.impc_parameter_orig_id		# based on matching impc_parameter_orig_id
join parameter_group pg 										# Finally, join to parameter_group, alias 'pg', which contains or parameter_group_name and id info
    on pgm.Parameter_Group_id = pg.Parameter_Group_id 			# based on matching parameter_group_ids
where m.gene_symbol = 'Ica1'; 									# Filtering all results based on gene_symbol = 'x'



select distinct       # Select the distinct group_ids and group_names (so you only get one result for each)
    pg.Parameter_Group_id,
    pg.Parameter_Group_name
from merged_df m 				# Starting from the merged_df, alias 'm' (it contains the parameter_id, linking to pimd).
join param_id_merged_df pimd 	# Join to param_id_merged_df, alias 'pimd' > this is our linking table between merged_df and ipd_csv.
    on m.parameter_id = pimd.parameter_id 	# based on when parameter_id is the same in m and in pimd
join ipd ipd 							# Join to ipd_csv, alias 'ipd' > contains impc_parameter_orig_id which links to our parameter group info
    on m.parameter_id = ipd.parameter_id 	# based on when m. and ipd. parameter_ids are the same
join parameter_group_membership pgm 		# Join to parameter_group_membership, alias 'pgm' table, which links impc ids to parameter_Group_Id
    on ipd.impc_parameter_orig_id = pgm.impc_parameter_orig_id		# based on matching impc_parameter_orig_id
join parameter_group pg 										# Finally, join to parameter_group, alias 'pg', which contains or parameter_group_name and id info
    on pgm.Parameter_Group_id = pg.Parameter_Group_id 			# based on matching parameter_group_ids
where m.gene_symbol = 'Dclk1'; 									# Filtering all results based on gene_symbol = 'x'





select distinct       # Select the distinct group_ids and group_names (so you only get one result for each)
    pg.Parameter_Group_id,
    pg.Parameter_Group_name
from merged_df m 				# Starting from the merged_df, alias 'm' (it contains the parameter_id, linking to pimd).
join param_id_merged_df pimd 	# Join to param_id_merged_df, alias 'pimd' > this is our linking table between merged_df and ipd_csv.
    on m.parameter_id = pimd.parameter_id 	# based on when parameter_id is the same in m and in pimd
join ipd ipd 							# Join to ipd_csv, alias 'ipd' > contains impc_parameter_orig_id which links to our parameter group info
    on m.parameter_id = ipd.parameter_id 	# based on when m. and ipd. parameter_ids are the same
join parameter_group_membership pgm 		# Join to parameter_group_membership, alias 'pgm' table, which links impc ids to parameter_Group_Id
    on ipd.impc_parameter_orig_id = pgm.impc_parameter_orig_id		# based on matching impc_parameter_orig_id
join parameter_group pg 										# Finally, join to parameter_group, alias 'pg', which contains or parameter_group_name and id info
    on pgm.Parameter_Group_id = pg.Parameter_Group_id 			# based on matching parameter_group_ids
where m.gene_symbol = 'Lpcat1'; 									# Filtering all results based on gene_symbol = 'x'



select distinct       # Select the distinct group_ids and group_names (so you only get one result for each)
    pg.Parameter_Group_id,
    pg.Parameter_Group_name
from merged_df m 				# Starting from the merged_df, alias 'm' (it contains the parameter_id, linking to pimd).
join param_id_merged_df pimd 	# Join to param_id_merged_df, alias 'pimd' > this is our linking table between merged_df and ipd_csv.
    on m.parameter_id = pimd.parameter_id 	# based on when parameter_id is the same in m and in pimd
join ipd ipd 							# Join to ipd_csv, alias 'ipd' > contains impc_parameter_orig_id which links to our parameter group info
    on m.parameter_id = ipd.parameter_id 	# based on when m. and ipd. parameter_ids are the same
join parameter_group_membership pgm 		# Join to parameter_group_membership, alias 'pgm' table, which links impc ids to parameter_Group_Id
    on ipd.impc_parameter_orig_id = pgm.impc_parameter_orig_id		# based on matching impc_parameter_orig_id
join parameter_group pg 										# Finally, join to parameter_group, alias 'pg', which contains or parameter_group_name and id info
    on pgm.Parameter_Group_id = pg.Parameter_Group_id 			# based on matching parameter_group_ids
where m.gene_symbol = 'Irag2'; 									# Filtering all results based on gene_symbol = 'x'





############################################################################################################

-- QUERIES TO SELECT THE PROCEDURE NAME, DESCRIPTION, AND IS_MANDATORY STATUS
-- FOR EACH GENOTYPE:

#### EXPLANATION:####
# 1. Filtering by gene_symbol = "x", we start from merged_df(parameter_id),
# 2. Join to param_id_merged_df (alias pimd) table (which contains unique parameter_ids that are sourced from merged_df)
#	 So looking for parameter_ids that are the same in merged_df and pimd.
#	 This does not add new information, but enforces consistency
# 3. Join to ipd_csv, where parameter_ids match between ipd and pimd
#	 Allows us to fetch the impc_parameter_orig_id, which links ipd to procedure info
# 4. Join to procedure_link, based on impc ids that match between procedure_link and ipd
# 5. Join to procedure_data, based on procedure_names that match between procedure_link and procedure_data
# 6. Retrieve/select the procedure_name, procedure_description, and ismandatory status
#    of the procedure that each parameter belongs to, based on the gene_symbol 'x'.



-- FOR GENE SYMBOL ICA1
select distinct
    pd.procedure_name,
    pd.procedure_description,
    pd.ismandatory
from merged_df m #Starting from the merged_df, alias 'm' (it contains the parameter_id, linking to pimd)
join param_id_merged_df pimd #Join to param_id_merged_df, alias 'pimd' > this is our linking table between merged_df and ipd_csv
    on m.parameter_id = pimd.parameter_id
join ipd ipd #Join to ipd
    on pimd.parameter_id = ipd.parameter_id #where parameter_ids in m. and ipd. are the same
join procedure_link pl #Join to pl
	on ipd.impc_parameter_orig_id = pl.impc_parameter_orig_id #where impc_id is the same in ipd. and pl.
join procedure_data pd #Join to pd.
	on pl.procedure_name = pd.procedure_name #where procedure_name is the same in pl. and pd.
where m.gene_symbol = 'Ica1';




-- FOR GENE_SYMBOL 'DCKL1'
select distinct
    pd.procedure_name,
    pd.procedure_description,
    pd.ismandatory
from merged_df m #Starting from the merged_df, alias 'm' (it contains the parameter_id, linking to pimd)
join param_id_merged_df pimd #Join to param_id_merged_df, alias 'pimd' > this is our linking table between merged_df and ipd_csv
    on m.parameter_id = pimd.parameter_id
join ipd ipd #Join to ipd
    on pimd.parameter_id = ipd.parameter_id #where parameter_ids in m. and ipd. are the same
join procedure_link pl #Join to pl
	on ipd.impc_parameter_orig_id = pl.impc_parameter_orig_id #where impc_id is the same in ipd. and pl.
join procedure_data pd #Join to pd.
	on pl.procedure_name = pd.procedure_name #where procedure_name is the same in pl. and pd.
where m.gene_symbol = 'Dclk1';



-- FOR GENE_SYMBOL 'IRAG2'
select distinct
    pd.procedure_name,
    pd.procedure_description,
    pd.ismandatory
from merged_df m #Starting from the merged_df, alias 'm' (it contains the parameter_id, linking to pimd)
join param_id_merged_df pimd #Join to param_id_merged_df, alias 'pimd' > this is our linking table between merged_df and ipd_csv
    on m.parameter_id = pimd.parameter_id
join ipd ipd #Join to ipd
    on pimd.parameter_id = ipd.parameter_id #where parameter_ids in m. and ipd. are the same
join procedure_link pl #Join to pl
	on ipd.impc_parameter_orig_id = pl.impc_parameter_orig_id #where impc_id is the same in ipd. and pl.
join procedure_data pd #Join to pd.
	on pl.procedure_name = pd.procedure_name #where procedure_name is the same in pl. and pd.
where m.gene_symbol = 'Irag2';


-- FOR GENE_SYMBOL 'LPCAT1'
select distinct
    pd.procedure_name,
    pd.procedure_description,
    pd.ismandatory
from merged_df m #Starting from the merged_df, alias 'm' (it contains the parameter_id, linking to pimd)
join param_id_merged_df pimd #Join to param_id_merged_df, alias 'pimd' > this is our linking table between merged_df and ipd_csv
    on m.parameter_id = pimd.parameter_id
join ipd ipd #Join to ipd
    on pimd.parameter_id = ipd.parameter_id #where parameter_ids in m. and ipd. are the same
join procedure_link pl #Join to pl
	on ipd.impc_parameter_orig_id = pl.impc_parameter_orig_id #where impc_id is the same in ipd. and pl.
join procedure_data pd #Join to pd.
	on pl.procedure_name = pd.procedure_name #where procedure_name is the same in pl. and pd.
where m.gene_symbol = 'Lpcat1';






############################################################################################

######################################################################################################

-- QUERIES TO RETRIEVE THE DISEASES LINKED TO EACH GENE_SYMBOL


SELECT gene_accession_id
FROM dcdm5.gene_table
WHERE gene_symbol = 'Ica1'
# result = MGI:96391

SELECT do_disease_id
FROM dcdm5.dis_inf
WHERE gene_accession_id_nulled = 'MGI:96391'
# no result
-------------------------------------------------------------

SELECT gene_accession_id
FROM dcdm5.gene_table
WHERE gene_symbol = 'Dclk1'
# result = MGI:1330861

SELECT do_disease_id
FROM dcdm5.dis_inf
WHERE gene_accession_id_nulled = 'MGI:1330861'
# no result
--------------------------------------------------------------

SELECT gene_accession_id
FROM dcdm5.gene_table
WHERE gene_symbol = 'Lpcat1'
# result = MGI:2384812

SELECT do_disease_id
FROM dcdm5.dis_inf
WHERE gene_accession_id_nulled = 'MGI:2384812'
# No result
-------------------------------------------------------------

SELECT gene_accession_id
FROM dcdm5.gene_table
WHERE gene_symbol = 'Irag2'
# result = MGI:108424

SELECT do_disease_id
FROM dcdm5.dis_inf
WHERE gene_accession_id_nulled = 'MGI:108424'
# no result



----------------------------------------------------------------------------

################################

-- QUERIES TO RETRIEVE THE PVALUE AND ASSOCIATED DATA FOR EACH GENOTYPE
-- WITH OPTION TO ONLY SELECT DATA ASSOCIATED WITH SPECIFIC PVALUES RANGES (i.e. greater than or less than 0.05)

USE dcdm5;


#### Genotype Ica1 ####
SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Ica1';

SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Ica1' AND pvalue < 0.05;

SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Ica1' AND pvalue > 0.05;



#### Genotype Dclk1 ####
SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Dclk1';

SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Ica1' AND pvalue < 0.05;

SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Ica1' AND pvalue > 0.05;





#### Genotype Lpcat1 ####
SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Lpcat1';

SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Lpcat1' AND pvalue < 0.05;

SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Lpcat1' AND pvalue > 0.05;





#### Genotype Irag2 ####
SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Irag2';

SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Irag2' AND pvalue < 0.05;

SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol = 'Irag2' AND pvalue > 0.05;


#### Querying P values for all 4 genotypes ####
SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol IN ('Ica1', 'Dclk1', 'Lpcat1', 'Irag2');

SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol IN ('Ica1', 'Dclk1', 'Lpcat1', 'Irag2') AND pvalue < 0.05;

SELECT 
    gene_symbol,
    mouse_strain,
    mouse_life_stage,
    parameter_name,
    pvalue
FROM merged_df
WHERE gene_symbol IN ('Ica1', 'Dclk1', 'Lpcat1', 'Irag2') AND pvalue > 0.05;







