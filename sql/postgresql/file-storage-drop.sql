--
-- file-storage/sql/postgresql/file-storage-drop.sql
--
-- @author Kevin Scaldeferri (kevin@arsdigita.com)
-- @creation-date 6 Now 2000
-- @cvs-id $Id$
--
-- drop script for file-storage
--

-- Site-wide search interface
\i file-storage-sc-drop.sql

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
        select package_id
	from fs_root_folders
    loop
        -- JS: The RI constraints will cause acs_objects__delete to fail
	-- JS: So I changed this to apm_package__delete
        PERFORM apm_package__delete(rec_root_folder.package_id);
    end loop;

    return 0;

end;' language 'plpgsql';

select inline_0();
drop function inline_0();

\i file-storage-views-drop.sql;

drop function fs_package_items_delete_trig();
drop trigger fs_package_items_delete_trig on fs_root_folders;

drop function fs_root_folder_delete_trig();
drop trigger fs_root_folder_delete_trig on fs_root_folders;

drop table fs_root_folders;
select drop_package('file_storage');

-- Unregister the content template
select content_type__unregister_template (
       'file-storage-object',
       content_type__get_template('file-storage-object','public'),
       'public'
);

-- Remove subtype of content_revision so that site-wide-search
-- can distinguish file-storage items in the search results
select content_type__drop_type (
       'file_storage_object',	 -- content_type
       'f',			 -- drop_children_p
       'f'			 -- drop_table_p
);
