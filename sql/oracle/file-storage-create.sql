--
-- packages/file-storage/sql/file-storage-create.sql
--
-- @author Kevin Scaldeferri(kevin@arsdigita.com)
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
-- JS: 2) The title attribute in cr_revisions will store the filename
-- JS: of each version, which may be different among versions of the same title.
-- JS:
-- JS: 3)   Version notes will still be stored in the description attribute.
-- JS:
-- JS: The unfortunate result is that the use of "title" and "name" in
-- JS: cr_revisions and cr_items, respectively, are interchanged.
-- JS:

--
-- We need to create a root folder in the content repository for
-- each instance of file storage
--

create table fs_root_folders (
    -- ID for this package instance
    package_id                  integer
                                constraint fs_root_folder_package_id_fk
                                references apm_packages on delete cascade
                                constraint fs_root_folder_package_id_pk
                                primary key,
    -- the ID of the root folder
    -- JS: I removed the on delete cascade constraint on folder_id
    folder_id                   integer
                                constraint fs_root_folder_folder_id_fk
                                references cr_folders
                                constraint fs_root_folder_folder_id_un
                                unique
);



-- To enable site-wide search to distinguish CR items as File Storage items
-- we create an item subtype of content_item in the ACS Object Model
begin
    content_type.create_type(
        content_type => 'file_storage_object',
        pretty_name => 'File Storage Object',
        pretty_plural => 'File Storage Objects',
        supertype => 'content_revision',
        table_name => 'fs_root_folders',
        id_column => 'folder_id',
        name_method => 'file_storage.get_title'
    );
end;
/
show errors;

@ file-storage-package-create.sql

@ file-storage-simple-create.sql
@ file-storage-simple-package-create.sql

@ file-storage-views-create.sql
