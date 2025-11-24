#######################################################


#######################################################



#######################################################

use dcdm5



#Creating Parameter_Group table

CREATE TABLE parameter_group (
    parameter_group_id INT AUTO_INCREMENT PRIMARY KEY,  
    parameter_group_name VARCHAR (100) UNIQUE
)

#Inserting 6 parameters intop parameter_group_name 

INSERT INTO parameter_group (parameter_group_name)
Values
('weight'),
('images'),
('brain'),
('hematocrit'),
('pupil dilation'),
('neutrophil cell count')


#######################################################



#Creating Membership table 
USE dcdm5;

CREATE TABLE parameter_group_membership (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    impc_parameter_orig_id varchar(15),   #From Parameter table, a primary key
    Parameter_Group_id INT	 #From ParemterGroup_table, a primary key
);



#Adding weight into Parameter_Group_Membership

INSERT INTO parameter_group_membership (impc_parameter_orig_id, parameter_group_id) #Inserts new rows into the membership table.
SELECT ic.impc_parameter_orig_id, pg.parameter_group_id                             #select the primary key of the parameter AND parameter group
FROM ipd ic                                                                         #Use the ipd table, giving it the alias "p"
JOIN parameter_group pg ON pg.parameter_group_name = 'weight'                       #Join to the Parameter_Group table (alias "g") BUT only where the group name is exactly 'weight'. This ensures we are assigning parameters to the wight group only
WHERE ic.parameter_name LIKE '%weight%';                                            #Select only parameters whose name contains the word "weight". The % means "anything before or after". So this matches weight, body weight etc





#Adding images into Parameter_Group_Membership

INSERT INTO parameter_group_membership (impc_parameter_orig_id, parameter_group_id)
SELECT ic.impc_parameter_orig_id, pg.Parameter_Group_id
FROM ipd ic
JOIN parameter_group pg
ON pg.parameter_group_name = 'images'
WHERE ic.parameter_name LIKE '%image%';



#Adding brain into Parameter_Group_Membership

INSERT INTO parameter_group_membership (impc_parameter_orig_id, parameter_group_id)
SELECT ic.impc_parameter_orig_id, pg.Parameter_Group_id
FROM ipd ic
JOIN parameter_group pg
ON pg.parameter_group_name = 'brain'
WHERE ic.parameter_name LIKE '%brain%';




#Adding hematocrit into Parameter_Group_Membership

INSERT INTO parameter_group_membership (impc_parameter_orig_id, Parameter_Group_id)
SELECT ic.impc_parameter_orig_id, pg.Parameter_Group_id
FROM ipd ic
JOIN parameter_group pg
ON pg.parameter_group_name = 'hematocrit'
WHERE ic.parameter_name LIKE '%hemato%' OR ic.parameter_name LIKE '%hct%';





#Adding pupil dilation into Parameter_Group_Membership

INSERT INTO parameter_group_membership (impc_parameter_orig_id, Parameter_Group_id)
SELECT ic.impc_parameter_orig_id, pg.Parameter_Group_id
FROM ipd ic
JOIN parameter_group pg
ON pg.parameter_group_name = 'pupil dilation'
WHERE ic.parameter_name LIKE '%pupil%'
OR ic.parameter_name LIKE '%eye%';





#Adding neutrophil cell count into Parameter_Group_Membership

INSERT INTO parameter_group_membership (impc_parameter_orig_id, Parameter_Group_id)
SELECT ic.impc_parameter_orig_id, pg.Parameter_Group_id
FROM ipd ic
JOIN parameter_group pg
ON pg.parameter_group_name = 'neutrophil cell count'
WHERE ic.parameter_name LIKE '%neutrophil%'
OR ic.parameter_name LIKE '%cell count%';


use dcdm5

alter table parameter_group_membership 
add foreign key (impc_parameter_orig_id) references ipd(impc_parameter_orig_id)



alter table parameter_group_membership 
add FOREIGN KEY (parameter_group_id) REFERENCES parameter_group(parameter_group_id)







