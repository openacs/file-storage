--
-- packages/file-storage/sql/file-storage-create.sql
--
-- @author Kevin Scaldeferri (kevin@arsdigita.com)
-- @creation-date 6 Nov 2000
-- @cvs-id $Id$
--

-- JS: I changed the way file storage uses the CR:  cr_items will store
-- JS: a file's meta-data, while cr_revisions will store specifics of a
-- JS: file's version.  Every file has at least one version.
-- JS:
-- JS: 1) The name attribute in cr_items will store the "title" of the 
-- JS:     of the file, and all its versions. 
-- JS:
-- JS: 2) The title attribute in cr_revisions  will store the filename 
-- JS: of each version, which may be different among versions of the same title.
-- JS:
-- JS: 3)   Version notes will still be stored in the description attribute. 
-- JS:
-- JS: The unfortunate result is that the use of "title" and "name" in 
-- JS: cr_revisions and cr_items, respectively, are interchanged.
-- JS:


-- 
-- To enable site-wide search to distinguish CR items as File Storage items
-- we create an item subtype of content_item in the ACS Object Model
begin
 acs_object_type.create_type (
   object_type   => 'file_storage_item',
   pretty_name   => 'File Storage Item',
   pretty_plural => 'File Storage Items',
   supertype     => 'content_item',
   table_name    => 'fs_root_folders',  -- JS: Will not do anything, but we have to insert something
   id_column     => 'folder_id'         -- JS: Same.
 );
end;
/
show errors;

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

    function get_root_folder (
       --
       -- Returns the root folder corresponding to a particulat
       -- package instance.
       --
       package_id in apm_packages.package_id%TYPE
    ) return fs_root_folders.folder_id%TYPE;

    function new_root_folder (
       --
       -- Creates a new root folder
       --
       package_id in apm_packages.package_id%TYPE
    ) return fs_root_folders.folder_id%TYPE;

    function new_file(
       -- 
       -- Create a file in CR in preparation for actual storage
       -- Wrapper for content_item.new
       --
       title		in cr_items.name%TYPE,
       folder_id	in cr_items.parent_id%TYPE,
       creation_user	in acs_objects.creation_user%TYPE,
       creation_ip	in acs_objects.creation_ip%TYPE,
       indb_p		in char default 't'
    ) return cr_items.item_id%TYPE;

    procedure delete_file (
       --
       -- Delete a file and all its version
       -- Wrapper to content_item__delete
       --
       file_id	in cr_items.item_id%TYPE
    );

    procedure rename_file (
       --
       -- Rename a file and all
       -- Wrapper to content_item__rename
       --
       file_id	in cr_items.item_id%TYPE,
       title	in cr_items.name%TYPE
    );

    function copy_file(
       --
       -- Copy a file, but only copy the live_revision
       --
       file_id		in cr_items.item_id%TYPE,
       target_folder_id in cr_items.parent_id%TYPE,
       creation_user	in acs_objects.creation_user%TYPE,
       creation_ip	in acs_objects.creation_ip%TYPE
    ) return cr_revisions.revision_id%TYPE;

    function get_path (
       --
       -- Get the virtual path, but replace title with name at the end
       -- Wrapper for content_item.get_path
       --
       item_id		in cr_items.item_id%TYPE,
       root_folder_id	in cr_items.parent_id%TYPE,
       revision_id	in cr_revisions.revision_id%TYPE
    ) return varchar;


    function get_title (
       --
       -- Unfortunately, title in the file-storage context refers
       -- to the name attribute in cr_items, not the title attribute in 
       -- cr_revisions
       item_id		in cr_items.item_id%TYPE
    ) return varchar;

    function get_content_type (
       --
       -- Wrapper for content_item. get_content_type
       -- 
       item_id	      in cr_items.item_id%TYPE
    ) return cr_items.content_type%TYPE;

    function get_folder_name (
       --
       -- Wrapper for content_folder__get_label
       -- 
       folder_id	in cr_folders.folder_id%TYPE
    ) return cr_folders.label%TYPE;

    function new_version (
       --
       -- Create a new version of a file
       -- Wrapper for content_revision.new
       --
       filename		in cr_revisions.title%TYPE,
       description	in cr_revisions.description%TYPE,
       mime_type	in cr_revisions.mime_type%TYPE,
       item_id		in cr_items.item_id%TYPE,
       creation_user	in acs_objects.creation_user%TYPE,
       creation_ip	in acs_objects.creation_ip%TYPE
    ) return cr_revisions.revision_id%TYPE;

    function delete_version (
       --
       -- Delete a version of a file
       --
       file_id		in cr_items.item_id%TYPE,
       version_id	in cr_revisions.revision_id%TYPE
    ) return cr_items.parent_id%TYPE;

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


    function new_root_folder (
       -- 
       -- A hackish function to get around the fact that we can't run
       -- code automatically when a new package instance is created.
       --
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


    function new_file (
       -- 
       -- Create a file in CR in preparation for actual storage
       -- Wrapper for content_item.new
       --
       title		in cr_items.name%TYPE,
       folder_id	in cr_items.parent_id%TYPE,
       creation_user	in acs_objects.creation_user%TYPE,
       creation_ip	in acs_objects.creation_ip%TYPE,
       indb_p		in char default 't'
    ) return cr_items.item_id%TYPE
    is
	v_item_id	cr_items.item_id%TYPE;
    begin

	   if new_file.indb_p = 't'
	   then 
		v_item_id := content_item.new (
			      name => new_file.title,
			      parent_id => new_file.folder_id,
			      creation_user => new_file.creation_user,
			      context_id => new_file.folder_id, 
			      creation_ip => new_file.creation_ip,
			      item_subtype => 'file_storage_item'
			      );
	   else
		v_item_id := content_item.new (
			      name => new_file.title,
			      parent_id => new_file.folder_id,
			      creation_user => new_file.creation_user,
			      context_id => new_file.folder_id,
			      creation_ip => new_file.creation_ip,
			      item_subtype => 'file_storage_item',
			      storage_type => 'file'
			      );

	   end if;

	   return v_item_id;

    end new_file;


    procedure delete_file (
       --
       -- Delete a file and all its version
       -- Wrapper to content_item__delete
       --
       file_id	in cr_items.item_id%TYPE
    ) 
    is
    begin

	content_item.delete(item_id => file_storage.delete_file.file_id);

    end delete_file;


    procedure rename_file (
       --
       -- Rename a file and all
       -- Wrapper to content_item__rename
       --
       file_id	in cr_items.item_id%TYPE,
       title	in cr_items.name%TYPE
    )
    is
    begin

	content_item.rename(
	       item_id => file_storage.rename_file.file_id,  -- item_id
	       name => file_storage.rename_file.title        -- name
	       );

    end rename_file;


    function copy_file(
       --
       -- Copy a file, but only copy the live_revision
       --
       file_id		in cr_items.item_id%TYPE,
       target_folder_id in cr_items.parent_id%TYPE,
       creation_user	in acs_objects.creation_user%TYPE,
       creation_ip	in acs_objects.creation_ip%TYPE
    ) return cr_revisions.revision_id%TYPE 
    is
	v_title			     cr_items.name%TYPE;
	v_live_revision		     cr_items.live_revision%TYPE;
	v_filename		     cr_revisions.title%TYPE;
	v_description		     cr_revisions.description%TYPE;
	v_mime_type		     cr_revisions.mime_type%TYPE;
	v_content_length	     cr_revisions.content_length%TYPE;
	v_lob			     cr_revisions.content%TYPE;
	v_file_path		     cr_revisions.filename%TYPE;
	v_new_file_id		     cr_items.item_id%TYPE;
	v_new_version_id	     cr_revisions.revision_id%TYPE;
	v_indb_p		     char;
    begin

	-- We copy only the title from the file being copied, and attributes of the
	-- live revision
	select i.name,i.live_revision,r.title,r.description,
	       r.mime_type,r.content,r.filename,r.content_length,
	       decode(i.storage_type,'lob','t','f')
	  into v_title,v_live_revision,v_filename,v_description,
	       v_mime_type,v_lob,v_file_path,v_content_length,
	       v_indb_p
	from cr_items i, cr_revisions r
	where r.item_id = i.item_id
	and   r.revision_id = i.live_revision
	and   i.item_id = file_storage.copy_file.file_id;

	-- We should probably use the copy functions of CR
	-- when we optimize this function
	v_new_file_id := file_storage.new_file(
				 title => v_title,
				 folder_id => file_storage.copy_file.target_folder_id, 
				 creation_user => file_storage.copy_file.creation_user,
				 creation_ip => file_storage.copy_file.creation_ip,
				 indb_p => v_indb_p
				 );

	v_new_version_id := file_storage.new_version (
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

	return v_new_version_id;

    end copy_file;


    function new_version (
       --
       -- Create a new version of a file
       -- Wrapper for content_revision.new
       --
       filename		in cr_revisions.title%TYPE,
       description	in cr_revisions.description%TYPE,
       mime_type	in cr_revisions.mime_type%TYPE,
       item_id		in cr_items.item_id%TYPE,
       creation_user	in acs_objects.creation_user%TYPE,
       creation_ip	in acs_objects.creation_ip%TYPE
    ) return cr_revisions.revision_id%TYPE
    is 
	v_revision_id	cr_revisions.revision_id%TYPE;
    begin
	-- Create a revision
    	v_revision_id := content_revision.new (
			  title => new_version.filename,
			  description => new_version.description,	
			  mime_type => new_version.mime_type,
			  item_id => new_version.item_id,
			  creation_user => new_version.creation_user,
			  creation_ip => new_version.creation_ip	
			  );

	-- Make live the newly created revision
    	content_item.set_live_revision(revision_id => v_revision_id);

	return v_revision_id;

    end new_version;


    function get_path (
       --
       -- Get the virtual path, but replace title with name at the end
       -- Wrapper for content_item__get_path
       --
       item_id		in cr_items.item_id%TYPE,
       root_folder_id	in cr_items.parent_id%TYPE,
       revision_id	in cr_revisions.revision_id%TYPE default null
    ) return varchar
    is
	v_filename	cr_revisions.title%TYPE;
	v_content_type	cr_items.content_type%TYPE;
	v_live_revision	cr_items.live_revision%TYPE;
	v_revision_id	cr_revisions.revision_id%TYPE;
    begin

	select content_type,live_revision 
	       into v_content_type,v_live_revision
	from cr_items
	where item_id = file_storage.get_path.item_id;

	if v_content_type = 'content_revision'
	then
	
	     if file_storage.get_path.revision_id is null
	     then
		   v_revision_id := v_live_revision;
	     else
		   v_revision_id := file_storage.get_path.revision_id;
	     end if;

	     select title into v_filename
	     from cr_revisions
	     where revision_id = v_revision_id;

	     return content_item.get_path(
			item_id => file_storage.get_path.item_id,
			root_folder_id => file_storage.get_path.root_folder_id
			) || '/../' || v_filename;

        else

	     return content_item.get_path(
			item_id => file_storage.get_path.item_id,
			root_folder_id => file_storage.get_path.root_folder_id
			);

	end if;

    end get_path;


    function get_title (
       --
       -- Unfortunately, title in the file-storage context refers
       -- to the name attribute in cr_items, not the title attribute in 
       -- cr_revisions
       item_id		in cr_items.item_id%TYPE
    ) return varchar
    is
        v_title              cr_items.name%TYPE;
	v_content_type       cr_items.content_type%TYPE;
    begin
  
	select content_type into v_content_type 
	from cr_items 
	where item_id = get_title.item_id;

	if v_content_type = 'content_folder' 
	then
	     select label into v_title 
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


    function get_content_type (
       --
       -- Wrapper for content_item. get_content_type
       -- 
       item_id	      in cr_items.item_id%TYPE
    ) return cr_items.content_type%TYPE
    is
	v_content_type	cr_items.content_type%TYPE;
    begin
	v_content_type := content_item.get_content_type(
		            item_id => file_storage.get_content_type.item_id
			    );

	return v_content_type;

    end get_content_type;

    function get_folder_name (
       --
       -- Wrapper for content_folder.get_label
       --
       folder_id      in cr_folders.folder_id%TYPE
    ) return cr_folders.label%TYPE
    is
       v_folder_name	cr_folders.label%TYPE;
    begin
	v_folder_name := content_folder.get_label(
		            folder_id => file_storage.get_folder_name.folder_id
			    );

	return v_folder_name;

    end get_folder_name;


    function delete_version (
       --
       -- Delete a version of a file
       --
       file_id		in cr_items.item_id%TYPE,
       version_id	in cr_revisions.revision_id%TYPE
    ) return cr_items.parent_id%TYPE
    is
	v_parent_id			cr_items.parent_id%TYPE;
    begin

        if file_storage.delete_version.version_id =  content_item.get_live_revision(file_storage.delete_version.file_id) 
	then
            content_revision.delete(file_storage.delete_version.version_id);
            content_item.set_live_revision(
			content_item.get_latest_revision(file_storage.delete_version.file_id)
			);
        else
            content_revision.delete(file_storage.delete_version.version_id);
        end if;

	-- If the live revision is null, we have deleted the last version above
        select decode(live_revision,null,parent_id,0) into v_parent_id 
        from cr_items
        where item_id = file_storage.delete_version.file_id;

	-- Unfortunately, due to PostgreSQL behavior with regards referential integrity,
	-- we cannot delete the content_item entry if there are no more revisions.
	return v_parent_id;

    end delete_version;

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





