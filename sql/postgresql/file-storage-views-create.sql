--
-- file-storage/sql/postgresql/file-storage-views-create.sql
--
-- @author Kevin Scaldeferri (kevin@arsdigita.com)
-- @creation-date 6 Nov 2000
-- @cvs-id $Id$
--

create view fs_urls_full
as
    select fs_urls.url_id,
           fs_urls.url,
           fs_simple_objects.folder_id,
           fs_simple_objects.name,
           fs_simple_objects.description,
           acs_objects.*
    from fs_urls,
         fs_simple_objects,
         acs_objects
    where fs_urls.url_id = fs_simple_objects.object_id
    and fs_simple_objects.object_id = acs_objects.object_id;

create view fs_folders
as
    select cr_folders.folder_id,
           cr_folders.label as name,
           acs_objects.last_modified, -- JCD needs to walk tree as oracle ver
           (select count(*) -- DRB: needs to walk tree and won't scale worth shit
            from cr_items ci2
	    where ci2.content_type <> 'content_folder'
              and ci2.tree_sortkey between ci.tree_sortkey and tree_right(ci.tree_sortkey)) as content_size,
           ci.parent_id,
           ci.name as key
    from cr_folders,
         cr_items ci,
         acs_objects
    where cr_folders.folder_id = ci.item_id
    and cr_folders.folder_id = acs_objects.object_id;


create view fs_files
as
    select cr_revisions.item_id as file_id,
           cr_revisions.revision_id as live_revision,
           cr_revisions.mime_type as type,
           cr_revisions.title as file_upload_name,
           cr_revisions.content_length as content_size,
           cr_items.name,
           acs_objects.last_modified,
           cr_items.parent_id,
           cr_items.name as key
    from cr_revisions,
         cr_items,
         acs_objects
    where cr_revisions.revision_id = cr_items.live_revision
    and cr_revisions.item_id = cr_items.item_id
    and cr_items.content_type = 'file_storage_object'
    and cr_revisions.revision_id = acs_objects.object_id;

-- DRB: Simple advice: don't use this view in PostgreSQL because, unlike in Oracle, it is
-- *never* optimized ...

create view fs_objects
as
    select fs_folders.folder_id as object_id,
           0 as live_revision,
           'folder' as type,
           fs_folders.content_size,
           fs_folders.name,
           '' as file_upload_name,
           fs_folders.last_modified,
           '' as url,
           fs_folders.parent_id,
           fs_folders.key,
           0 as sort_key
    from fs_folders
    union all
    select fs_files.file_id as object_id,
           fs_files.live_revision,
           fs_files.type,
           fs_files.content_size,
           fs_files.name,
           fs_files.file_upload_name,
           fs_files.last_modified,
           '' as url,
           fs_files.parent_id,
           fs_files.key,
           1 as sort_key
    from fs_files
    union all
    select fs_urls_full.url_id as object_id,
           0 as live_revision,
           'url' as type,
           0 as content_size,
           fs_urls_full.name,
           fs_urls_full.name as file_upload_name,
           fs_urls_full.last_modified,
           fs_urls_full.url,
           fs_urls_full.folder_id as parent_id,
           fs_urls_full.url as key,
           1 as sort_key
    from fs_urls_full;
