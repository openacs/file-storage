--
-- file-storage/sql/postgresql/file-storage-create.sql
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
    -- JS: It is superfluous, and causes a lot of RI headaches
    folder_id   integer
                constraint fs_root_folder_folder_id_fk
                references cr_folders
                constraint fs_root_folder_folder_id_un
                unique
);

-- Create a subtype of content_revision so that site-wide-search can
-- distinguish file-storage items (v.s. generic content repository
-- items) in the search results
select content_type__create_type (
       'file_storage_object',    -- content_type
       'content_revision',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'File Storage Object',    -- pretty_name
       'File Storage Objects',   -- pretty_plural
       'fs_root_folders',        -- table_name
       'folder_id',	         -- id_column
       'file_storage__get_title' -- name_method
);

\i file-storage-package-create.sql

\i file-storage-simple-create.sql
\i file-storage-simple-package-create.sql

\i file-storage-views-create.sql
