-- dropped old version in d1-d2 upgrade script. 

create or replace function file_storage__new_root_folder (
       --
       -- Creates a new root folder
       --
       -- 
       -- A hackish function to get around the fact that we can not run
       -- code automatically when a new package instance is created.
       --
       integer,         -- apm_packages.package_id%TYPE
       varchar,         -- cr_folders.label%TYPE
       varchar,          -- cr_items.name%TYPE
       varchar
)
returns integer as '    --  fs_root_folders.folder_id%TYPE
declare
        new_root_folder__package_id         alias for $1;
        new_root_folder__folder_name        alias for $2;
	new_root_folder__url	            alias for $3;
        new_root_folder__description        alias for $4;
        v_folder_id                         fs_root_folders.folder_id%TYPE;
begin


        v_folder_id := content_folder__new (
            new_root_folder__url, -- name
            new_root_folder__folder_name, -- label
	    new_root_folder__description, -- description
            null,  -- parent_id (default)
	    new_root_folder__package_id, --context_id
	    null, --folder_id
	    null, --creation_date
	    null, --creation_user
	    null --creation_ip
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
                ''content_revision'',   -- content_types
                ''t''                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_folder'',     -- content_types
                ''t''                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_symlink'',    -- content_types
                ''t''                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_extlink'',    -- content_types
                ''t''                   -- include_subtypes 
                );

        return v_folder_id;

end;' language 'plpgsql';
