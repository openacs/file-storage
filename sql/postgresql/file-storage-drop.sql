--
-- packages/file-storage/sql/file-storage-drop.sql
--
-- @author Kevin Scaldeferri (kevin@arsdigita.com)
-- @creation-date 6 Now 2000
-- @cvs-id $Id$
--
-- drop script for file-storage
--

--
-- content repository is set up to cascade, so we should just have to 
-- delete the root folders
--

create function inline_0() 
returns integer as '
declare
	rec_root_folder		record;
begin

    for rec_root_folder in 
        select folder_id
	from fs_root_folders
    loop
        PERFORM acs_object__delete(rec_root_folder.folder_id);
    end loop;

    return 0;

end;' language 'plpgsql';

select inline_0();
drop function inline_0();

drop table fs_root_folders;
select drop_package('file_storage');

