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
    -- DAVEB: I put it back. I have no idea what JS is referring to.
    -- DAVEB: If you ever want to delete a root folder, say by deleting a
    -- DAVEB: package instance of file-storage, you need this.
    -- DAVEB: You DO have to delete all the folder contents and use CR pl/sql
    -- DAVEB: procs to delete the folder, when you do that the on delete
    -- DAVEB: cascade works fine.    
    folder_id                   integer
                                constraint fs_root_folder_folder_id_fk
                                references cr_folders on delete cascade
                                constraint fs_root_folder_folder_id_un
                                unique
);



-- To enable site-wide search to distinguish CR items as File Storage items
-- we create an item subtype of content_item in the ACS Object Model

-- DAVEB: acs_object_types supports a null table name so we do that  
-- instead of passing a false value so we can actually use the
-- content repository instead of duplicating all the code in file-storage
set escape on

declare
    template_id integer;
begin
    content_type.create_type(
        content_type => 'file_storage_object',
        pretty_name => 'File Storage Object',
        pretty_plural => 'File Storage Objects',
        supertype => 'content_revision',
        table_name => NULL,
        id_column => NULL,
        name_method => 'file_storage.get_title'
    );

    -- Create the (default) file_storage_object content type template

    template_id := content_template.new( 
      name      => 'file-storage-default',
      text      => '<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="displayed_object_id">@item_id;noquote@</property>
\@text;noquote@'
    );

    -- Register the template for the file_storage_object content type

    content_type.register_template(
      content_type => 'file_storage_object',
      template_id  => template_id,
      use_context  => 'public',
      is_default   => 't'
    );

end;
/
show errors;


@ file-storage-package-create.sql

@ file-storage-views-create.sql

@ file-storage-notifications-create.sql

@ file-storage-rss-create.sql

