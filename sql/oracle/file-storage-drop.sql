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
-- delete the root folders  (JS: this is just plain wrong. The only reason
-- this works is because of the triggers I added)
--

declare
    cursor c_root_folders
    is
    select folder_id
    from   fs_root_folders;
begin
    for v_root_folder in c_root_folders loop
        acs_object.delete(v_root_folder.folder_id);
    end loop;
end;
/
show errors

drop trigger fs_package_items_delete_trig;
drop trigger fs_root_folder_delete_trig;

drop table fs_root_folders;
drop package file_storage;

