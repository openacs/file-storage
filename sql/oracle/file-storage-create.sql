--
-- packages/file-storage/sql/file-storage-create.sql
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
    -- JS: I removed the on delete cascade constraint on folder_id
    folder_id   integer
                constraint fs_root_folder_folder_id_fk
                references cr_folders 
                constraint fs_root_folder_folder_id_un
                unique
);



create or replace package file_storage
as

    --
    -- Returns the root folder corresponding to a particulat
    -- package instance.
    --
    function get_root_folder (
        package_id in apm_packages.package_id%TYPE
    ) return fs_root_folders.folder_id%TYPE;

    --
    -- Creates a new root folder
    --
    function new_root_folder (
        package_id in apm_packages.package_id%TYPE
    ) return fs_root_folders.folder_id%TYPE;

end file_storage;
/
show errors

create or replace package body file_storage
as

    function get_root_folder (
        package_id in apm_packages.package_id%TYPE
    ) return fs_root_folders.folder_id%TYPE 
    is
        v_folder_id     fs_root_folders.folder_id%TYPE;
        v_count         integer;
    begin

        select count(*) into v_count 
        from fs_root_folders
        where package_id = get_root_folder.package_id;

        if v_count > 0 then
            select folder_id into v_folder_id 
            from fs_root_folders
            where package_id = get_root_folder.package_id;
        else
            -- must be a new instance.  Gotta create a new root folder
            v_folder_id := new_root_folder(package_id);
        end if;

        return v_folder_id;

    end get_root_folder;


    -- 
    -- A hackish function to get around the fact that we can't run
    -- code automatically when a new package instance is created.
    --

    function new_root_folder (
        package_id in apm_packages.package_id%TYPE
    ) return fs_root_folders.folder_id%TYPE
    is
        v_folder_id     fs_root_folders.folder_id%TYPE;
        v_package_name  apm_packages.instance_name%TYPE;
        v_package_key   apm_packages.package_key%TYPE;
    begin

        select instance_name, package_key 
        into v_package_name, v_package_key
        from apm_packages
        where package_id = new_root_folder.package_id;

        v_folder_id := content_folder.new (
            name => v_package_key || '_' || package_id,
            label => v_package_name || ' Root Folder',
            description => 'Root folder for the file-storage system.  All other folders in file storage are subfolders of this one.'
        );

        insert into fs_root_folders 
        (package_id, folder_id)
        values 
        (package_id, v_folder_id);

        -- allow child items to be added
        content_folder.register_content_type(v_folder_id,'content_revision');
        content_folder.register_content_type(v_folder_id,'content_folder');

        -- set up default permissions
        acs_permission.grant_permission (
            object_id => v_folder_id,
            grantee_id => acs.magic_object_id('the_public'),
            privilege => 'read'
        );
        acs_permission.grant_permission (
            object_id => v_folder_id,
            grantee_id => acs.magic_object_id('registered_users'),
            privilege => 'write'
        );

        return v_folder_id;

    end new_root_folder;        

end file_storage;
/
show errors;    


-- JS: BEFORE DELETE TRIGGER to clean up CR
create or replace trigger fs_package_items_delete_trig
before delete on fs_root_folders
for each row
declare

	cursor v_cursor is
		select item_id,content_type
		from cr_items
		where item_id != :old.folder_id
		connect by parent_id = prior item_id
		start with item_id = :old.folder_id
                order by level desc;
begin
	for v_rec in v_cursor
	loop

		-- We delete the item. On delete cascade should take care
		-- of deletion of revisions.
		if v_rec.content_type = 'content_revision'
		then
		    content_item.delete(v_rec.item_id);
		end if;

		-- Instead of doing an if-else, we make sure we are deleting a folder.
		if v_rec.content_type = 'content_folder'
		then
		    content_folder.delete(v_rec.item_id);
		end if;

		-- We may have to delete other items here, e.g., symlinks (future feature)

	end loop;
end;
/
show errors;


-- JS: AFTER DELETE TRIGGER to clean up last entry in CR
create or replace trigger fs_root_folder_delete_trig
after delete on fs_root_folders
for each row
begin
	content_folder.delete(:old.folder_id);
end;
/
show errors;





