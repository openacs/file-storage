--
-- packages/file-storage/sql/postgresql/file-storage-create.sql
--
-- @author Kevin Scaldeferri (kevin@arsdigita.com)
-- @creation-date 6 Nov 2000
-- @cvs-id $Id$
--

--
-- We need to create a root folder in the content repository for 
-- each instance of file storage
--


create table fs_root_folders (
    -- ID for this package instance
    package_id  integer
                constraint fs_root_folder_package_id_fk
                references apm_packages on delete cascade
                constraint fs_root_folder_package_id_pk
                primary key,
    -- the ID of the root folder
    folder_id   integer
                constraint fs_root_folder_folder_id_fk
                references cr_folders on delete cascade
                constraint fs_root_folder_folder_id_un
                unique
);



-- file_storage API
--
-- function get_root_folder (
--        package_id in apm_packages.package_id%TYPE
--    ) return fs_root_folders.folder_id%TYPE;
--
--
-- function new_root_folder (
--        package_id in apm_packages.package_id%TYPE
--    ) return fs_root_folders.folder_id%TYPE;


create function file_storage__get_root_folder (
       --
       -- Returns the root folder corresponding to a particular
       -- package instance.
       --
       integer        -- apm_packages.package_id%TYPE
)
returns integer as '  -- fs_root_folders.folder_id%TYPE 
declare
	get_root_folder__package_id  alias for $1;
        v_folder_id		     fs_root_folders.folder_id%TYPE;
        v_count			     integer;
begin

        select count(*) into v_count 
        from fs_root_folders
        where package_id = get_root_folder__package_id;

        if v_count > 0 then
            select folder_id into v_folder_id 
            from fs_root_folders
            where package_id = get_root_folder__package_id;
        else
            -- must be a new instance.  Gotta create a new root folder
            v_folder_id := file_storage__new_root_folder(get_root_folder__package_id);
        end if;

        return v_folder_id;

end;' language 'plpgsql';



create function file_storage__new_root_folder (
       --
       -- Creates a new root folder
       --
       -- 
       -- A hackish function to get around the fact that we can not run
       -- code automatically when a new package instance is created.
       --
       integer		-- apm_packages.package_id%TYPE
)
returns integer as '	--  fs_root_folders.folder_id%TYPE
declare
	new_root_folder__package_id  alias for $1;
        v_folder_id		    fs_root_folders.folder_id%TYPE;
        v_package_name		    apm_packages.instance_name%TYPE;
        v_package_key		    apm_packages.package_key%TYPE;
begin

        select instance_name, package_key 
        into v_package_name, v_package_key
        from apm_packages
        where package_id = new_root_folder__package_id;

        v_folder_id := content_folder__new (
            v_package_key || ''_'' || new_root_folder__package_id, -- name
            v_package_name || '' Root Folder'',    -- label
            ''Root folder for the file-storage system.  All other folders in file storage are subfolders of this one.'', -- description
	    null				  -- parent_id (default)
        );

        insert into fs_root_folders 
        (package_id, folder_id)
        values 
        (new_root_folder__package_id, v_folder_id);

        -- allow child items to be added
        PERFORM content_folder__register_content_type(
		v_folder_id,	        -- folder_id
		''content_revision'',   -- content_types
		''f''			-- include_subtypes (default)
		);
        PERFORM content_folder__register_content_type(
		v_folder_id,		-- folder_id
		''content_folder'',	-- content_types
		''f''			-- include_subtypes (default)
		);

        -- set up default permissions
        PERFORM acs_permission__grant_permission (
		v_folder_id,                          -- object_id
		acs__magic_object_id(''the_public''), -- grantee_id 
		''read''			      -- privilege
		);

        PERFORM acs_permission__grant_permission (
		v_folder_id,			            -- object_id 
		acs__magic_object_id(''registered_users''), -- grantee_id
		''write''				    -- privilege
		);

	return v_folder_id;

end;' language 'plpgsql';
    

