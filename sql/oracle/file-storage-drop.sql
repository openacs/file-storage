--
-- packages/file-storage/sql/oracle/file-storage-drop.sql
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
declare
    cursor c_root_folders
    is
    select package_id
    from   fs_root_folders;
begin
    for v_root_folder in c_root_folders loop
        -- JS: The RI constraints will cause acs_objects.delete to fail
	-- JS: So I changed this to apm_package.delete
        apm_package.delete(v_root_folder.package_id);
    end loop;
end;
/
show errors

drop trigger fs_package_items_delete_trig;
drop trigger fs_root_folder_delete_trig;

drop table fs_root_folders;
drop package file_storage;

begin
acs_object_type.drop_type ( 
  object_type => 'file_storage_item');
end;
/
show errors