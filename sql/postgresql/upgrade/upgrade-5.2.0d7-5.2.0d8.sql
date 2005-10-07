create or replace function file_storage__new_file(
       -- 
       -- Create a file in CR in preparation for actual storage
       -- Wrapper for content_item__new
       --
       -- DRB: I added this version to allow one to predefine item_id, among other things to
       -- make it easier to use with ad_form
       varchar,         -- cr_items.name%TYPE,
       integer,         -- cr_items.parent_id%TYPE,
       integer,         -- acs_objects.creation_user%TYPE,
       varchar,         -- acs_objects.creation_ip%TYPE,
       boolean,         -- store in db? 
       integer,           -- cr_items.item_id%TYPE,
       integer        -- apm_packages.package_id%TYPE
) returns integer as ' -- cr_items.item_id%TYPE
declare
        new_file__name                 alias for $1;
        new_file__folder_id             alias for $2;
        new_file__user_id               alias for $3;
        new_file__creation_ip           alias for $4;
        new_file__indb_p                alias for $5;
        new_file__item_id               alias for $6;
        new_file__package_id            alias for $7;
        v_item_id                       integer;
begin

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
                        ''content_item'',         -- item_subtype (default)
                        ''file_storage_object'',  -- content_type (needed by site-wide search)
                        null,                       -- title (default)
                        null,                       -- description
                        ''text/plain'',     -- mime_type (default)
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
                        ''content_item'',         -- item_subtype (default)
                        ''file_storage_object'',  -- content_type (needed by site-wide search)
                        null,                       -- title (default)
                        null,                       -- description
                        ''text/plain'',     -- mime_type (default)
                        null,                       -- nls_language (default)
                        null,                       -- text (default)
                        ''file'',                   -- storage_type
                        new_file__package_id        -- package_id
                    );

        end if;

        perform acs_object__update_last_modified(new_file__folder_id,new_file__user_id,new_file__creation_ip);

        return v_item_id;

end;' language 'plpgsql';
    

create or replace function file_storage__new_file(
       varchar,         -- cr_items.name%TYPE,
       integer,         -- cr_items.parent_id%TYPE,
       integer,         -- acs_objects.creation_user%TYPE,
       varchar,         -- acs_objects.creation_ip%TYPE,
       boolean,          -- store in db? 
       integer        -- apm_packages.package_id%TYPE       
) returns integer as ' -- cr_items.item_id%TYPE
declare
        new_file__name                  alias for $1;
        new_file__folder_id             alias for $2;
        new_file__user_id               alias for $3;
        new_file__creation_ip           alias for $4;
        new_file__indb_p                alias for $5;
        new_file__package_id            alias for $6;
begin
        return file_storage__new_file(
             new_file__name,            -- name
             new_file__folder_id,       -- parent_id
             new_file__user_id,         -- creation_user
             new_file__creation_ip,     -- creation_ip
             new_file__indb_p,          -- storage_type
             null,                      -- item_id
             new_file__package_id       -- pacakge_id
        );

end;' language 'plpgsql';
