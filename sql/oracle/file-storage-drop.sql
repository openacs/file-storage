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
        -- JS: The RI constraints will cause acs_objects.del to fail
	-- JS: So I changed this to apm_package.del
        apm_package.del(v_root_folder.package_id);
    end loop;
end;
/
show errors

@@ file-storage-views-drop.sql

drop trigger fs_package_items_delete_trig;
drop trigger fs_root_folder_delete_trig;

drop table fs_root_folders;
drop package file_storage;

declare
  template_id integer;
begin
template_id := content_type.get_template(
  content_type => 'file_storage_object',
  use_context  => 'public'
);

content_type.unregister_template(
  template_id  => template_id
);

content_type.drop_type ( 
  content_type => 'file_storage_object'
);
end;
/
show errors

@ file-storage-notifications-drop.sql
