--
-- procedure file_storage__new_file/7
--
CREATE OR REPLACE FUNCTION file_storage__new_file(
   new_file__name varchar,
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
    



-- added

-- old define_function_args('file_storage__new_file','name,folder_id,user_id,creation_ip,indb_p,package_id')
-- new
select define_function_args('file_storage__new_file','name,folder_id,user_id,creation_ip,indb_p,item_id,package_id');


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
