-- Add user_id and IP to update_last_modified
-- $Id



-- added
select define_function_args('file_storage__new_file','title,folder_id,user_id,creation_ip,indb_p,item_id');

--
-- procedure file_storage__new_file/6
--
CREATE OR REPLACE FUNCTION file_storage__new_file(
   new_file__title --         varchar,
   new_file__folder_id integer,
   new_file__user_id integer,
   new_file__creation_ip varchar,
   new_file__indb_p boolean,
   new_file__item_id integer

) RETURNS integer AS $$
-- cr_items.item_id%TYPE
DECLARE
        v_item_id                       integer;
BEGIN

        if new_file__indb_p
        then 
            v_item_id := content_item__new (
                        new_file__title,            -- name
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
                        null                        -- data (default)
                    );
        else
            v_item_id := content_item__new (
                        new_file__title,            -- name
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
                        'file'                    -- storage_type
                    );

        end if;

        perform acs_object__update_last_modified(new_file__folder_id,new_file__user_id,new_file__creation_ip);

        return v_item_id;

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
        v_title                      cr_items.name%TYPE;
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
BEGIN

        -- We copy only the title from the file being copied, and attributes of the
        -- live revision
        select i.name,i.live_revision,r.title,r.description,r.mime_type,r.content_length,
               (case when i.storage_type = 'lob'
                     then true
                     else false
                end)
               into v_title,v_live_revision,v_filename,v_description,v_mime_type,v_content_length,v_indb_p
        from cr_items i, cr_revisions r
        where r.item_id = i.item_id
        and   r.revision_id = i.live_revision
        and   i.item_id = copy_file__file_id;

        -- We should probably use the copy functions of CR
        -- when we optimize this function
        v_new_file_id := file_storage__new_file(
                             v_title,                     -- title
                             copy_file__target_folder_id, -- folder_id
                             copy_file__creation_user,    -- creation_user
                             copy_file__creation_ip,      -- creation_ip
                             v_indb_p                     -- indb_p
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




-- added
select define_function_args('file_storage__move_file','file_id,target_folder_id,creation_user,creation_ip');

--
-- procedure file_storage__move_file/4
--
CREATE OR REPLACE FUNCTION file_storage__move_file(
   move_file__file_id --          integer,
   move_file__target_folder_id integer,
   move_file__creation_user integer,
   move_file__creation_ip varchar

) RETURNS integer AS $$
-- 0 for success
DECLARE
BEGIN

        perform content_item__move(
               move_file__file_id,              -- item_id
               move_file__target_folder_id      -- target_folder_id
               );

        perform acs_object__update_last_modified(move_file__target_folder_id,move_file__creation_user,move_file__creation_ip);

        return 0;
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('file_storage__new_version','filename,description,mime_type,item_id,creation_user,creation_ip');

--
-- procedure file_storage__new_version/6
--
CREATE OR REPLACE FUNCTION file_storage__new_version(
   new_version__filename --         --
       varchar,
   new_version__description varchar,
   new_version__mime_type varchar,
   new_version__item_id integer,
   new_version__creation_user integer,
   new_version__creation_ip varchar

) RETURNS integer AS $$
-- cr_revisions.revision_id
DECLARE
        v_revision_id                   cr_revisions.revision_id%TYPE;
        v_folder_id                     cr_items.parent_id%TYPE;
BEGIN
        -- Create a revision
        v_revision_id := content_revision__new (
                          new_version__filename,        -- title
                          new_version__description,     -- description
                          now(),                        -- publish_date
                          new_version__mime_type,       -- mime_type
                          null,                         -- nls_language
                          null,                         -- data (default)
                          new_version__item_id,         -- item_id
                          null,                         -- revision_id
                          now(),                        -- creation_date
                          new_version__creation_user,   -- creation_user
                          new_version__creation_ip      -- creation_ip
                          );

        -- Make live the newly created revision
        perform content_item__set_live_revision(v_revision_id);

        select cr_items.parent_id
        into v_folder_id
        from cr_items
        where cr_items.item_id = new_version__item_id;

        perform acs_object__update_last_modified(v_folder_id,new_version__creation_user,new_version__creation_ip);

        return v_revision_id;

END;
$$ LANGUAGE plpgsql;

