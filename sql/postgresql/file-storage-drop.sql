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
        template_id             integer;
begin

    for rec_root_folder in 
        select package_id
	from fs_root_folders
    loop
        -- JS: The RI constraints will cause acs_objects__delete to fail
	-- JS: So I changed this to apm_package__delete
        PERFORM apm_package__delete(rec_root_folder.package_id);
    end loop;

    -- Unregister the content template
    template_id := content_type__get_template(''file_storage_object'',''public'');

    perform content_type__unregister_template (''file_storage_object'', template_id, ''public'');
    perform content_template__del(template_id);
    return 0;

end;' language 'plpgsql';

select inline_0();
drop function inline_0();

\i file-storage-views-drop.sql;
drop trigger fs_package_items_delete_trig on fs_root_folders;
drop function fs_package_items_delete_trig();

drop trigger fs_root_folder_delete_trig on fs_root_folders;
drop function fs_root_folder_delete_trig();


select content_type__drop_type (
       'file_storage_object',	 -- content_type
       'f',			 -- drop_children_p
       'f'			 -- drop_table_p
);

-- this data model added by file-storage patch number 146 from 
-- openacs.org bugtracker

\i file-storage-notifications-drop.sql

drop table fs_root_folders cascade;

drop table fs_rss_subscrs;

select drop_package('file_storage');
