--
-- packages/file-storage/sql/file-storage-package-create.sql
--
-- @author yon (yon@openforce.net)
-- @creation-date 2002-04-03
-- @version $Id$
--

create or replace package file_storage
as

    function get_root_folder(
        --
        -- Returns the root folder corresponding to a particular
        -- package instance.
        --
        package_id in apm_packages.package_id%TYPE
    ) return fs_root_folders.folder_id%TYPE;

    function get_package_id(
        item_id in cr_items.item_id%TYPE
    ) return fs_root_folders.package_id%TYPE;

    function new_root_folder(
        --
        -- Creates a new root folder
        --
        package_id in apm_packages.package_id%TYPE,
        folder_name in cr_folders.label%TYPE default null,
        description in cr_folders.description%TYPE default null
    ) return fs_root_folders.folder_id%TYPE;

    function new_file(
        --
        -- Create a file in CR in preparation for actual storage
        -- Wrapper for content_item.new
        --
        item_id in cr_items.item_id%TYPE default null,
        title in cr_items.name%TYPE,
        folder_id in cr_items.parent_id%TYPE,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE,
        indb_p in char default 't'
    ) return cr_items.item_id%TYPE;

    procedure delete_file(
        --
        -- Delete a file and all its version
        -- Wrapper to content_item.delete
        --
        file_id in cr_items.item_id%TYPE
    );

    procedure rename_file(
        --
        -- Rename a file and all
        -- Wrapper to content_item__rename
        --
        file_id in cr_items.item_id%TYPE,
        title in cr_items.name%TYPE
    );

    function copy_file(
        --
        -- Copy a file, but only copy the live_revision
        --
        file_id in cr_items.item_id%TYPE,
        target_folder_id in cr_items.parent_id%TYPE,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE
    ) return cr_revisions.revision_id%TYPE;

    procedure move_file(
        --
        -- Move a file, and all its versions, to a new folder
        --
        file_id in cr_items.item_id%TYPE,
        target_folder_id in cr_items.parent_id%TYPE,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE
    );

    function get_title(
        --
        -- Unfortunately, title in the file-storage context refers
        -- to the name attribute in cr_items, not the title attribute in
        -- cr_revisions
        item_id in cr_items.item_id%TYPE
    ) return varchar;

    function get_parent_id(
	item_id in cr_items.item_id%TYPE
    ) return cr_items.item_id%TYPE;

    function get_content_type(
        --
        -- Wrapper for content_item. get_content_type
        --
        item_id in cr_items.item_id%TYPE
    ) return cr_items.content_type%TYPE;

    function get_folder_name(
       --
       -- Wrapper for content_folder__get_label
       --
       folder_id in cr_folders.folder_id%TYPE
    ) return cr_folders.label%TYPE;

    function new_version(
        --
        -- Create a new version of a file
        -- Wrapper for content_revision.new
        --
        filename in cr_revisions.title%TYPE,
        description in cr_revisions.description%TYPE,
        mime_type in cr_revisions.mime_type%TYPE,
        item_id in cr_items.item_id%TYPE,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE
    ) return cr_revisions.revision_id%TYPE;

    function delete_version(
        --
        -- Delete a version of a file
        --
        file_id in cr_items.item_id%TYPE,
        version_id in cr_revisions.revision_id%TYPE
    ) return cr_items.parent_id%TYPE;

    function new_folder(
        --
        -- Create a folder
        --
        name in cr_items.name%TYPE,
        folder_name in cr_folders.label%TYPE,
        parent_id in cr_items.parent_id%TYPE,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE
    ) return cr_folders.folder_id%TYPE;

    procedure delete_folder(
        --
        -- Delete a folder
        --
        folder_id in cr_folders.folder_id%TYPE
    );

end file_storage;
/
show errors

create or replace package body file_storage
as

    function get_root_folder(
        package_id in apm_packages.package_id%TYPE
    ) return fs_root_folders.folder_id%TYPE
    is
        v_folder_id             fs_root_folders.folder_id%TYPE;
        v_count                 integer;
    begin
        select count(*)
        into v_count
        from fs_root_folders
        where package_id = get_root_folder.package_id;

        if v_count > 0 then
            select folder_id
            into v_folder_id
            from fs_root_folders
            where package_id = get_root_folder.package_id;
        else
            -- must be a new instance.  Gotta create a new root folder
            v_folder_id := new_root_folder(package_id);
        end if;

        return v_folder_id;
    end get_root_folder;

    function get_package_id(
        item_id in cr_items.item_id%TYPE
    ) return fs_root_folders.package_id%TYPE
    is
        v_package_id            fs_root_folders.package_id%TYPE;
    begin
        select fs_root_folders.package_id
        into v_package_id
        from fs_root_folders,
             (select cr_items.item_id
              from cr_items
              connect by prior cr_items.parent_id = cr_items.item_id
              start with cr_items.item_id = get_package_id.item_id) this
        where fs_root_folders.folder_id = this.item_id;

        return v_package_id;

    exception when NO_DATA_FOUND then
        return null;
    end get_package_id;

    function new_root_folder(
        --
        -- A hackish function to get around the fact that we can't run
        -- code automatically when a new package instance is created.
        --
        package_id in apm_packages.package_id%TYPE,
        folder_name in cr_folders.label%TYPE default null,
        description in cr_folders.description%TYPE default null
    ) return fs_root_folders.folder_id%TYPE
    is
        v_folder_id             fs_root_folders.folder_id%TYPE;
        v_package_name          apm_packages.instance_name%TYPE;
        v_package_key           apm_packages.package_key%TYPE;
        v_folder_name           cr_folders.label%TYPE;
        v_description           cr_folders.description%TYPE;
    begin
        select instance_name, package_key
        into v_package_name, v_package_key
        from apm_packages
        where package_id = new_root_folder.package_id;

        if new_root_folder.folder_name is null
        then
            v_folder_name := v_package_name || ' Root Folder';
        else
            v_folder_name := folder_name;
        end if;

        if new_root_folder.description is null
        then
            v_description := 'Root folder for the file-storage system. All other folders in file storage are subfolders of this one.';
        else
            v_description := description;
        end if;

        v_folder_id := content_folder.new(
            name => v_package_key || '_' || package_id,
            label => v_folder_name,
            description => v_description
        );

        insert
        into fs_root_folders
        (package_id, folder_id)
        values
        (package_id, v_folder_id);

        -- allow child items to be added
        content_folder.register_content_type(v_folder_id,'content_revision','t');
        content_folder.register_content_type(v_folder_id,'content_folder','t');
        content_folder.register_content_type(v_folder_id,'content_extlink','t');
        content_folder.register_content_type(v_folder_id,'content_symlink','t');

        -- set up default permissions
        acs_permission.grant_permission(
            object_id => v_folder_id,
            grantee_id => acs.magic_object_id('the_public'),
            privilege => 'read'
        );

        acs_permission.grant_permission(
            object_id => v_folder_id,
            grantee_id => acs.magic_object_id('registered_users'),
            privilege => 'write'
        );

        return v_folder_id;
    end new_root_folder;

    function new_file(
        --
        -- Create a file in CR in preparation for actual storage
        -- Wrapper for content_item.new
        --
        item_id in cr_items.item_id%TYPE default null,
        title in cr_items.name%TYPE,
        folder_id in cr_items.parent_id%TYPE,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE,
        indb_p in char default 't'
    ) return cr_items.item_id%TYPE
    is
        v_item_id               cr_items.item_id%TYPE;
    begin
        if new_file.indb_p = 't'
        then
            v_item_id := content_item.new(
                item_id => new_file.item_id,
                name => new_file.title,
                parent_id => new_file.folder_id,
                creation_user => new_file.creation_user,
                context_id => new_file.folder_id,
                creation_ip => new_file.creation_ip,
                content_type => 'file_storage_object',
                item_subtype => 'content_item'
            );
        else
            v_item_id := content_item.new(
                name => new_file.title,
                parent_id => new_file.folder_id,
                creation_user => new_file.creation_user,
                context_id => new_file.folder_id,
                creation_ip => new_file.creation_ip,
                content_type => 'file_storage_object',
                item_subtype => 'content_item',
                storage_type => 'file'
            );
        end if;

        acs_object.update_last_modified(file_storage.new_file.folder_id,new_file.creation_user,new_file.creation_ip);

        return v_item_id;
    end new_file;

    procedure delete_file(
        --
        -- Delete a file and all its version
        -- Wrapper to content_item__delete
        --
        file_id in cr_items.item_id%TYPE
    )
    is
    begin
        content_item.del(item_id => file_storage.delete_file.file_id);
    end delete_file;

    procedure rename_file(
        --
        -- Rename a file and all
        -- Wrapper to content_item__rename
        --
        file_id in cr_items.item_id%TYPE,
        title in cr_items.name%TYPE
    )
    is
    begin
        content_item.rename(
            item_id => file_storage.rename_file.file_id,
            name => file_storage.rename_file.title
        );
    end rename_file;

    function copy_file(
        --
        -- Copy a file, but only copy the live_revision
        --
        file_id in cr_items.item_id%TYPE,
        target_folder_id in cr_items.parent_id%TYPE,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE
    ) return cr_revisions.revision_id%TYPE
    is
        v_title                 cr_items.name%TYPE;
        v_live_revision         cr_items.live_revision%TYPE;
        v_filename              cr_revisions.title%TYPE;
        v_description           cr_revisions.description%TYPE;
        v_mime_type             cr_revisions.mime_type%TYPE;
        v_content_length        cr_revisions.content_length%TYPE;
        v_lob                   cr_revisions.content%TYPE;
        v_file_path             cr_revisions.filename%TYPE;
        v_new_file_id           cr_items.item_id%TYPE;
        v_new_version_id        cr_revisions.revision_id%TYPE;
        v_indb_p                char;
    begin
        -- We copy only the title from the file being copied, and attributes of the
        -- live revision
        select i.name, i.live_revision, r.title, r.description,
               r.mime_type, r.content, r.filename, r.content_length,
               decode(i.storage_type,'lob','t','f')
        into v_title, v_live_revision, v_filename, v_description,
             v_mime_type, v_lob, v_file_path, v_content_length,
             v_indb_p
        from cr_items i, cr_revisions r
        where r.item_id = i.item_id
        and r.revision_id = i.live_revision
        and i.item_id = file_storage.copy_file.file_id;

        -- We should probably use the copy functions of CR
        -- when we optimize this function
        v_new_file_id := file_storage.new_file(
            title => v_title,
            folder_id => file_storage.copy_file.target_folder_id,
            creation_user => file_storage.copy_file.creation_user,
            creation_ip => file_storage.copy_file.creation_ip,
            indb_p => v_indb_p
        );

        v_new_version_id := file_storage.new_version(
            filename => v_filename,
            description => v_description,
            mime_type => v_mime_type,
            item_id => v_new_file_id,
            creation_user => file_storage.copy_file.creation_user,
            creation_ip => file_storage.copy_file.creation_ip
        );

        -- Oracle is easier, since lobs are true lobs
        -- For now, we simply copy the file name
        update cr_revisions
        set filename = v_file_path,
            content = v_lob,
            content_length = v_content_length
        where revision_id = v_new_version_id;

        acs_object.update_last_modified(file_storage.copy_file.target_folder_id,file_storage.copy_file.creation_user,file_storage.copy_file.creation_ip);

        return v_new_version_id;
    end copy_file;

    procedure move_file(
        --
        -- Move a file, and all its versions, to a new folder
        --
        file_id in cr_items.item_id%TYPE,
        target_folder_id in cr_items.parent_id%TYPE,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE
    )
    is
    begin
        content_item.move(
            item_id => file_storage.move_file.file_id,
            target_folder_id => file_storage.move_file.target_folder_id
        );

        acs_object.update_last_modified(file_storage.move_file.target_folder_id,file_storage.move_file.creation_user,file_storage.move_file.creation_ip);

    end;

    function new_version(
        --
        -- Create a new version of a file
        -- Wrapper for content_revision.new
        --
        filename in cr_revisions.title%TYPE,
        description in cr_revisions.description%TYPE,
        mime_type in cr_revisions.mime_type%TYPE,
        item_id in cr_items.item_id%TYPE,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE
    ) return cr_revisions.revision_id%TYPE
    is
        v_revision_id           cr_revisions.revision_id%TYPE;
        v_folder_id             cr_items.parent_id%TYPE;
    begin
        -- Create a revision
        v_revision_id := content_revision.new(
            title => new_version.filename,
            description => new_version.description,
            mime_type => new_version.mime_type,
            item_id => new_version.item_id,
            creation_user => new_version.creation_user,
            creation_ip => new_version.creation_ip
        );

        -- Make live the newly created revision
        content_item.set_live_revision(revision_id => v_revision_id);

        select cr_items.parent_id
        into v_folder_id
        from cr_items
        where cr_items.item_id = file_storage.new_version.item_id;

        acs_object.update_last_modified(v_folder_id,new_version.creation_user,new_version.creation_ip);

        return v_revision_id;

        exception when NO_DATA_FOUND then
            return v_revision_id;
    end new_version;

    function get_title(
        --
        -- Unfortunately, title in the file-storage context refers
        -- to the name attribute in cr_items, not the title attribute in
        -- cr_revisions
        item_id in cr_items.item_id%TYPE
    ) return varchar
    is
        v_title                 cr_items.name%TYPE;
        v_content_type          cr_items.content_type%TYPE;
    begin
        select content_type
        into v_content_type
        from cr_items
        where item_id = get_title.item_id;

        if v_content_type = 'content_folder'
        then
             select label
             into v_title
             from cr_folders
             where folder_id = get_title.item_id;
        else if v_content_type = 'content_symlink'
            then
                select label into v_title
                from cr_symlinks
                where symlink_id = get_title.item_id;
            else
                select name into v_title
                from cr_items
                where item_id = get_title.item_id;
            end if;
        end if;

        return v_title;
    end get_title;

    function get_parent_id(
        item_id in cr_items.item_id%TYPE
    ) return cr_items.item_id%TYPE
    is
        v_parent_id             cr_items.item_id%TYPE;
    begin
        select parent_id
        into v_parent_id
        from cr_items
        where item_id = get_parent_id.item_id;

	return v_parent_id;
    end get_parent_id;

    function get_content_type(
        --
        -- Wrapper for content_item. get_content_type
        --
        item_id in cr_items.item_id%TYPE
    ) return cr_items.content_type%TYPE
    is
        v_content_type          cr_items.content_type%TYPE;
    begin
        v_content_type := content_item.get_content_type(
            item_id => file_storage.get_content_type.item_id
        );

        return v_content_type;
    end get_content_type;

    function get_folder_name(
        --
        -- Wrapper for content_folder.get_label
        --
        folder_id in cr_folders.folder_id%TYPE
    ) return cr_folders.label%TYPE
    is
       v_folder_name            cr_folders.label%TYPE;
    begin
        v_folder_name := content_folder.get_label(
            folder_id => file_storage.get_folder_name.folder_id
        );

        return v_folder_name;
    end get_folder_name;

    function delete_version(
        --
        -- Delete a version of a file
        --
        file_id in cr_items.item_id%TYPE,
        version_id in cr_revisions.revision_id%TYPE
    ) return cr_items.parent_id%TYPE
    is
        v_parent_id             cr_items.parent_id%TYPE;
    begin
        if file_storage.delete_version.version_id = content_item.get_live_revision(file_storage.delete_version.file_id)
        then
            content_revision.del(file_storage.delete_version.version_id);
            content_item.set_live_revision(
                content_item.get_latest_revision(file_storage.delete_version.file_id)
            );
        else
            content_revision.del(file_storage.delete_version.version_id);
        end if;

        -- If the live revision is null, we have deleted the last version above
        select decode(live_revision, null, parent_id, 0)
        into v_parent_id
        from cr_items
        where item_id = file_storage.delete_version.file_id;

        -- Unfortunately, due to PostgreSQL behavior with regards referential integrity,
        -- we cannot delete the content_item entry if there are no more revisions.
        return v_parent_id;
    end delete_version;

    function new_folder(
        --
        -- Create a folder
        --
        name in cr_items.name%TYPE,
        folder_name in cr_folders.label%TYPE,
        parent_id in cr_items.parent_id%TYPE,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE
    ) return cr_folders.folder_id%TYPE
    is
        v_folder_id             cr_folders.folder_id%TYPE;
    begin
        -- Create a new folder
        v_folder_id := content_folder.new(
            name => file_storage.new_folder.name,
            label => file_storage.new_folder.folder_name,
            parent_id => file_storage.new_folder.parent_id,
            creation_user => file_storage.new_folder.creation_user,
            creation_ip => file_storage.new_folder.creation_ip
        );

        -- register the standard content types
        content_folder.register_content_type(
            v_folder_id,                -- folder_id
            'content_revision',        -- content_type
            't'                        -- include_subtypes
        );

        content_folder.register_content_type(
            v_folder_id,                -- folder_id
            'content_folder',        -- content_type
            't'                        -- include_subtypes
        );

        content_folder.register_content_type(
            v_folder_id,               -- folder_id
            'content_extlink',         -- content_type
            't'                        -- include_subtypes
        );

        content_folder.register_content_type(
            v_folder_id,               -- folder_id
            'content_symlink',         -- content_type
            't'                        -- include_subtypes
        );

        -- Give the creator admin privileges on the folder
        acs_permission.grant_permission(
            v_folder_id,                             -- object_id
            file_storage.new_folder.creation_user,  -- grantee_id
            'admin'                                     -- privilege
        );

        return v_folder_id;
    end new_folder;

    procedure delete_folder(
        --
        -- Delete a folder
        --
        folder_id in cr_folders.folder_id%TYPE
    )
    is
    begin
        content_folder.del(
            folder_id => file_storage.delete_folder.folder_id
        );
    end delete_folder;

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
        if v_rec.content_type = 'file_storage_object'
        then
            content_item.del(v_rec.item_id);
        end if;

        -- Instead of doing an if-else, we make sure we are deleting a folder.
        if v_rec.content_type = 'content_folder'
        then
            content_folder.del(v_rec.item_id);
        end if;

        -- Instead of doing an if-else, we make sure we are deleting a folder.
        if v_rec.content_type = 'content_symlink'
        then
            content_symlink.del(v_rec.item_id);
        end if;

        -- Instead of doing an if-else, we make sure we are deleting a folder.
        if v_rec.content_type = 'content_extlink'
        then
            content_extlink.del(v_rec.item_id);
        end if;

    end loop;
end;
/
show errors;

-- JS: AFTER DELETE TRIGGER to clean up last entry in CR
create or replace trigger fs_root_folder_delete_trig
after delete on fs_root_folders
for each row
begin
    content_folder.del(:old.folder_id);
end;
/
show errors;
