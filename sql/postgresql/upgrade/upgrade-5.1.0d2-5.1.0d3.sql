-- 

-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2004-05-09
-- @cvs-id $Id$
--

create or replace function file_storage__delete_folder(
       --
       -- Delete a folder
       --
       integer          -- cr_folders.folder_id%TYPE
) returns integer as '  -- 0 for success
declare
        delete_folder__folder_id        alias for $1; 
begin

        return file_storage__delete_folder(
                    delete_folder__folder_id,  -- folder_id
                    ''f''
                    );

end;' language 'plpgsql';

create or replace function file_storage__delete_folder(
       --
       -- Delete a folder
       --
       integer,          -- cr_folders.folder_id%TYPE
       boolean
) returns integer as '  -- 0 for success
declare
        delete_folder__folder_id        alias for $1; 
        delete_folder__cascade_p        alias for $2;
begin

        return content_folder__delete(
                    delete_folder__folder_id,  -- folder_id
                    delete_folder__cascade_p
                    );

end;' language 'plpgsql';
