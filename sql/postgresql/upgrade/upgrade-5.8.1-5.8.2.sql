

delete from cr_folder_type_map
       where content_type not in ( 'file_storage_object', 'content_folder', 'content_extlink')
       and folder_id in (
       select o2.object_id as folder_id  from acs_objects o1, acs_objects o2
       where o1.object_id in (select folder_id from fs_root_folders)
                and o2.tree_sortkey between o1.tree_sortkey
         and tree_right(o1.tree_sortkey)
         and o2.object_type = 'content_folder');


--- from file-storage-package-create.sql

CREATE OR REPLACE FUNCTION file_storage__new_folder(
   new_folder__name varchar,
   new_folder__folder_name varchar,
   new_folder__parent_id integer,
   new_folder__creation_user integer,
   new_folder__creation_ip varchar
)
RETURNS integer AS $$
DECLARE
        v_folder_id                   cr_folders.folder_id%TYPE;
        v_package_id                  acs_objects.package_id%TYPE;
BEGIN
        v_package_id := file_storage__get_package_id(new_folder__parent_id);

        -- Create a new folder
        v_folder_id := content_folder__new (
                            new_folder__name,           -- name
                            new_folder__folder_name,    -- label
                            null,                       -- description
                            new_folder__parent_id,      -- parent_id
                            null,                       -- context_id (default)
                            null,                       -- folder_id (default)
                            now(),                      -- creation_date
                            new_folder__creation_user,  -- creation_user
                            new_folder__creation_ip,    -- creation_ip
                            v_package_id                -- package_id
                            );

    -- Register the needed content types
    --
    -- GN: Maybe, when someone decides to really implement the half-cooked
    -- "image" content type, it should go in here as well.
    
        PERFORM content_folder__register_content_type(
                        v_folder_id,             -- folder_id
                        'file_storage_object',   -- content_type
                        't');                    -- include_subtypes
    
        PERFORM content_folder__register_content_type(
                        v_folder_id,        -- folder_id
                        'content_folder',       -- content_type
                        't');                   -- include_subtypes

        PERFORM content_folder__register_content_type(
                    v_folder_id,            -- folder_id
                'content_extlink',        -- content_types
            't');                   -- include_subtypes 


--        PERFORM content_folder__register_content_type(
--            v_folder_id,            -- folder_id
--                    'content_symlink',    -- content_types
--                    't');                   -- include_subtypes 

        -- Give the creator admin privileges on the folder
        PERFORM acs_permission__grant_permission (
                     v_folder_id,                -- object_id
                     new_folder__creation_user,  -- grantee_id
                     'admin'                   -- privilege
                     );

        return v_folder_id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION file_storage__new_root_folder(
   new_root_folder__package_id integer,
   new_root_folder__folder_name varchar,
   new_root_folder__url varchar,
   new_root_folder__description varchar
)
RETURNS integer AS $$
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

        insert into fs_root_folders (package_id, folder_id)
        values (new_root_folder__package_id, v_folder_id);

        --                
        -- Register the needed content types
        --
        -- GN: Maybe, when someone decides to really implement the half-cooked
        -- "image" content type, it should go in here as well.
    
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                'file_storage_object',  -- content_types
                'f');                   -- include_subtypes 
        
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                'content_folder',    -- content_types
                't');                   -- include_subtypes 

        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                'content_extlink',    -- content_types
                't');                   -- include_subtypes 

--        PERFORM content_folder__register_content_type(
--                v_folder_id,            -- folder_id
--                'content_symlink',      -- content_types
--                't');                   -- include_subtypes 
--                );

        return v_folder_id;
END;
$$ LANGUAGE plpgsql;

