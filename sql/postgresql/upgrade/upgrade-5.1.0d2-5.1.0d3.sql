-- 

-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2004-05-09
-- @cvs-id $Id$
--



-- added

--
-- procedure file_storage__delete_folder/1
--
CREATE OR REPLACE FUNCTION file_storage__delete_folder(
   delete_folder__folder_id --        --
       integer

) RETURNS integer AS $$
-- 0 for success
DECLARE
BEGIN

        return file_storage__delete_folder(
                    delete_folder__folder_id,  -- folder_id
                    'f'
                    );

END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('file_storage__delete_folder','folder_id,cascade_p');

--
-- procedure file_storage__delete_folder/2
--
CREATE OR REPLACE FUNCTION file_storage__delete_folder(
   delete_folder__folder_id --        --
       integer,
   delete_folder__cascade_p boolean

) RETURNS integer AS $$
-- 0 for success
DECLARE
BEGIN

        return content_folder__delete(
                    delete_folder__folder_id,  -- folder_id
                    delete_folder__cascade_p
                    );

END;
$$ LANGUAGE plpgsql;
