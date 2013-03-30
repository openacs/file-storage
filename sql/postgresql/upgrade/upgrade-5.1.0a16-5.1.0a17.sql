-- 
-- packages/file-storage/sql/postgresql/upgrade/upgrade-5.1.0a16-5.1.0a17.sql
-- 
-- @author Stan Kaufman (skaufman@epimetrics.com)
-- @creation-date 2005-09-28
-- @cvs-id $Id$
--

-- add package_id to acs_objects for all objects in FS (see Tip 42)



-- added
select define_function_args('file_storage__new_root_folder','package_id,folder_name,url,description');

--
-- procedure file_storage__new_root_folder/4
--
CREATE OR REPLACE FUNCTION file_storage__new_root_folder(
   new_root_folder__package_id --        --          --
       integer,
   new_root_folder__folder_name varchar,
   new_root_folder__url varchar,
   new_root_folder__description varchar

) RETURNS integer AS $$
--  fs_root_folders.folder_id%TYPE
DECLARE
        v_folder_id                         fs_root_folders.folder_id%TYPE;
BEGIN


        v_folder_id := content_folder__new (
            new_root_folder__url, -- name
            new_root_folder__folder_name, -- label
	    new_root_folder__description, -- description
            null,  -- parent_id (default)
	    new_root_folder__package_id, --context_id
	    null, --folder_id
	    null, --creation_date
	    null, --creation_user
	    null, --creation_ip
            new_root_folder__package_id --package_id
	);

        insert into fs_root_folders 
        (package_id, folder_id)
        values 
        (new_root_folder__package_id, v_folder_id);

        -- allow child items to be added
        -- JS: Note that we need to set include_subtypes to 
        -- JS: true since we created a new subtype.
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                'content_revision',   -- content_types
                't'                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                'content_folder',     -- content_types
                't'                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                'content_symlink',    -- content_types
                't'                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                'content_extlink',    -- content_types
                't'                   -- include_subtypes 
                );

        return v_folder_id;

END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('file_storage__new_file','name,folder_id,user_id,creation_ip,indb_p,item_id,package_id');

--
-- procedure file_storage__new_file/7
--
CREATE OR REPLACE FUNCTION file_storage__new_file(
   new_file__name --         varchar,
   new_file__folder_id integer,
   new_file__user_id integer,
   new_file__creation_ip varchar,
   new_file__indb_p boolean,
   new_file__item_id integer,
   new_file__package_id integer

) RETURNS integer AS $$
-- cr_items.item_id%TYPE
DECLARE
        v_item_id                       integer;
BEGIN

        if new_file__indb_p
        then 
            v_item_id := content_item__new (
                        new_file__name,            -- name
                        new_file__folder_id,      -- parent_id
                        new_file__item_id,        -- item_id (default)
                        null,                       -- locale (default)
                        now(),              -- creation_date (default)
                        new_file__user_id,        -- creation_user
                        new_file__folder_id,      -- context_id
                        new_file__creation_ip,    -- creation_ip
                        'content_item',         -- item_subtype (default)
                        'file_storage_object',  -- content_type (needed by site-wide search)
                        null,                       -- title (default)
                        null,                       -- description
                        'text/plain',     -- mime_type (default)
                        null,                       -- nls_language (default)
                        null,                       -- data (default)
                        new_file__package_id        -- package_id
                    );
        else
            v_item_id := content_item__new (
                        new_file__name,            -- name
                        new_file__folder_id,        -- parent_id
                        new_file__item_id,          -- item_id (default)
                        null,                       -- locale (default)
                        now(),              -- creation_date (default)
                        new_file__user_id,          -- creation_user
                        new_file__folder_id,        -- context_id
                        new_file__creation_ip,    -- creation_ip
                        'content_item',         -- item_subtype (default)
                        'file_storage_object',  -- content_type (needed by site-wide search)
                        null,                       -- title (default)
                        null,                       -- description
                        'text/plain',     -- mime_type (default)
                        null,                       -- nls_language (default)
                        null,                       -- text (default)
                        'file',                   -- storage_type
                        new_file__package_id        -- package_id
                    );

        end if;

        perform acs_object__update_last_modified(new_file__folder_id,new_file__user_id,new_file__creation_ip);

        return v_item_id;

END;
$$ LANGUAGE plpgsql;
    



--
-- procedure file_storage__new_file/6
--
CREATE OR REPLACE FUNCTION file_storage__new_file(
   new_file__name varchar,
   new_file__folder_id integer,
   new_file__user_id integer,
   new_file__creation_ip varchar,
   new_file__indb_p boolean,
   new_file__package_id integer
) RETURNS integer AS $$
-- cr_items.item_id%TYPE
DECLARE
BEGIN
        return file_storage__new_file(
             new_file__name,            -- name
             new_file__folder_id,       -- parent_id
             new_file__user_id,         -- creation_user
             new_file__creation_ip,     -- creation_ip
             new_file__indb_p,          -- storage_type
             null,                      -- item_id
             new_file__package_id       -- pacakge_id
        );

END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('file_storage__copy_file','file_id,target_folder_id,creation_user,creation_ip');

--
-- procedure file_storage__copy_file/4
--
CREATE OR REPLACE FUNCTION file_storage__copy_file(
   copy_file__file_id --        --
       integer,
   copy_file__target_folder_id integer,
   copy_file__creation_user integer,
   copy_file__creation_ip varchar

) RETURNS integer AS $$
-- cr_revisions.revision_id%TYPE
DECLARE
        v_name                      cr_items.name%TYPE;
        v_live_revision              cr_items.live_revision%TYPE;
        v_filename                   cr_revisions.title%TYPE;
        v_description                cr_revisions.description%TYPE;
        v_mime_type                  cr_revisions.mime_type%TYPE;
        v_content_length             cr_revisions.content_length%TYPE;
        v_lob_id                     cr_revisions.lob%TYPE;
        v_new_lob_id                 cr_revisions.lob%TYPE;
        v_file_path                  cr_revisions.content%TYPE;
        v_new_file_id                cr_items.item_id%TYPE;
        v_new_version_id                     cr_revisions.revision_id%TYPE;
        v_indb_p                     boolean;
        v_package_id                 apm_packages.package_id%TYPE;
BEGIN

        -- We copy only the title from the file being copied, and attributes of the
        -- live revision
        select i.name,i.live_revision,r.title,r.description,r.mime_type,r.content_length,
               (case when i.storage_type = 'lob'
                     then true
                     else false
                end)
               into v_name,v_live_revision,v_filename,v_description,v_mime_type,v_content_length,v_indb_p
        from cr_items i, cr_revisions r
        where r.item_id = i.item_id
        and   r.revision_id = i.live_revision
        and   i.item_id = copy_file__file_id;

        select package_id into v_package_id from acs_objects where object_id = copy_file__file_id;

        -- We should probably use the copy functions of CR
        -- when we optimize this function
        v_new_file_id := file_storage__new_file(
                             v_name,                     -- name
                             copy_file__target_folder_id, -- folder_id
                             copy_file__creation_user,    -- creation_user
                             copy_file__creation_ip,      -- creation_ip
                             v_indb_p,                    -- indb_p
                             v_package_id                 -- package_id
                             );

        v_new_version_id := file_storage__new_version (
                             v_filename,                  -- title
                             v_description,               -- description
                             v_mime_type,                 -- mime_type
                             v_new_file_id,               -- item_id
                             copy_file__creation_user,    -- creation_user
                             copy_file__creation_ip       -- creation_ip
                             );
                             
        if v_indb_p
        then

                -- Lob to copy from
                select lob into v_lob_id
                from cr_revisions
                where revision_id = v_live_revision;

                -- New lob id
                v_new_lob_id := empty_lob();

                -- copy the blob
                perform lob_copy(v_lob_id,v_new_lob_id);

                -- Update the lob id on the new version
                update cr_revisions
                set lob = v_new_lob_id,
                    content_length = v_content_length
                where revision_id = v_new_version_id;

        else

                -- For now, we simply copy the file name
                select content into v_file_path
                from cr_revisions
                where revision_id = v_live_revision;

                -- Update the file path
                update cr_revisions
                set content = v_file_path,
                    content_length = v_content_length
                where revision_id = v_new_version_id;

        end if;

        perform acs_object__update_last_modified(copy_file__target_folder_id,copy_file__creation_user,copy_file__creation_ip);

        return v_new_version_id;

END;
$$ LANGUAGE plpgsql;

-- upgrade existing data
-- do in transaction since we're bashing acs_objects in a major way
begin;
lock table acs_objects;

-- prevent loss of last_modified dates in all objects        
drop trigger acs_objects_last_mod_update_tr on acs_objects;
-- the FS root folders for each package instance
update cr_folders set package_id = file_storage__get_package_id(folder_id) where folder_id in (select folder_id from fs_root_folders);
-- all the rest of the FS objects
update acs_objects set package_id = file_storage__get_package_id(object_id) where object_id in (select object_id from fs_objects);
-- restart last_mod updating
create trigger acs_objects_last_mod_update_tr before update on acs_objects for each row execute procedure acs_objects_last_mod_update_tr ();

commit;

