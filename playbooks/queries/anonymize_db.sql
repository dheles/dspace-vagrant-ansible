UPDATE eperson SET email = 'test+' || eperson_id || '@jhu.edu';
UPDATE eperson SET netid = eperson_id;
UPDATE eperson SET jhu_hopkinsid = eperson_id;
UPDATE eperson SET jhu_jhedid = eperson_id;
UPDATE eperson SET phone = '410-555-1212';
UPDATE eperson SET password = NULL;
TRUNCATE registrationdata;
VACUUM registrationdata;
