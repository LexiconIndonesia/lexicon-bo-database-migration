-- POSTGRESQL
-- renamce date column to case_date
ALTER TABLE cases RENAME COLUMN "date" TO "case_date";

-- change benificiary_ownership type to text
ALTER TABLE cases ALTER COLUMN benificiary_ownership TYPE TEXT USING benificiary_ownership::TEXT

-- add punishment_start column
ALTER TABLE cases ADD COLUMN punishment_start DATE;

-- add punishment_end column
ALTER TABLE cases ADD COLUMN punishment_end DATE

-- move data from punishment_duration to punishment_start and punishment_end the format of the data is 03 Sep 2014 s/d 02 Sep 2015 split the data with s/d the first one become start and the second one become end
UPDATE cases c
SET punishment_start = (
  SELECT TO_DATE(
    SUBSTRING(x.punishment_duration, 0, POSITION('s/d' IN x.punishment_duration)-1), 'DD Mon YYYY')
  FROM cases x
  WHERE c.id = x.id
  ),
punishment_end = (
  SELECT TO_DATE(
    SUBSTRING(x.punishment_duration, POSITION('s/d' IN x.punishment_duration)+3), 'DD Mon YYYY')
  FROM cases x
  WHERE c.id = x.id
  )
WHERE POSITION('s/d' IN c.punishment_duration) > 0;


alter table cases drop column "punishment_duration";

ALTER TABLE cases ADD COLUMN case_type SMALLINT;

UPDATE cases SET case_type = 1 WHERE "type" = 'verdict';
UPDATE cases SET case_type = 2 WHERE "type" = 'blacklist';
UPDATE cases SET case_type = 3 WHERE "type" = 'sanction';

-- drop type column
ALTER TABLE cases DROP COLUMN "type";


-- add summary_formatted column
ALTER TABLE cases ADD COLUMN "summary_formatted" text null default NULL;

-- update summary_formatted
UPDATE cases SET summary_formatted = summary;

-- Add status column
ALTER TABLE cases ADD COLUMN "status" smallint DEFAULT 2;


-- add CreatedBy, UpdatedBy, DeletedBy
ALTER TABLE cases ADD COLUMN created_by bpchar(26);
ALTER TABLE cases ADD COLUMN updated_by bpchar(26);
ALTER TABLE cases ADD COLUMN deleted_by bpchar(26);


-- add column subject_type_temp
ALTER TABLE cases ADD COLUMN subject_type_temp smallint;

-- update subject_type_temp from subject type, if subject type is individual then value 1, else 2
UPDATE cases SET subject_type_temp = 1 WHERE subject_type = 'individual';
UPDATE cases SET subject_type_temp = 2 WHERE subject_type = 'company';
UPDATE cases SET subject_type_temp = 3 WHERE subject_type = 'organization';

-- delete subject_type
ALTER TABLE cases DROP COLUMN subject_type;

-- rename subject_type_temp to subject_type
ALTER TABLE cases RENAME COLUMN subject_type_temp TO subject_type


-- create new one
CREATE INDEX idx_search_filter ON cases (subject_type, year, case_type, nation, "status");


update cases set status = 1;

update cases set person_in_charge = null where person_in_charge  = '-'