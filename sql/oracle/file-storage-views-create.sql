--
-- packages/file-storage/sql/oracle/file-storage-views-create.sql
--
-- @author yon (yon@openforce.net)
-- @creation-date 2002-04-03
-- @version $Id$
--

create or replace view fs_urls_full
as
    select cr_extlinks.extlink_id as url_id,
           cr_extlinks.url,
           cr_items.parent_id as folder_id,
           cr_extlinks.label as name,
           cr_extlinks.description,
           acs_objects.*
    from cr_extlinks,
         cr_items,
         acs_objects
    where cr_extlinks.extlink_id = cr_items.item_id
    and cr_items.item_id = acs_objects.object_id;

create or replace view fs_folders
as
    select cr_folders.folder_id,
           cr_folders.label as name,
           acs_objects.last_modified,
            (select count(*)
             from cr_items ci
	     where ci.content_type <> 'content_folder'
	     connect by prior ci.item_id = ci.parent_id
	     start with ci.item_id = cr_folders.folder_id) as content_size,
           cr_items.parent_id,
           cr_items.name as key
    from cr_folders,
         cr_items,
         acs_objects
    where cr_folders.folder_id = cr_items.item_id
    and cr_folders.folder_id = acs_objects.object_id;

create or replace view fs_files
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

create or replace view fs_objects
as
    select cr_items.item_id as object_id,
      cr_items.live_revision,
      case
        when cr_items.content_type = 'content_folder' then 'folder'
        when cr_items.content_type = 'content_extlink' then 'url'
        else cr_revisions.mime_type
      end as type,
      case
        when cr_items.content_type = 'content_folder'
        then (select count(*)
              from cr_items ci
              where ci.content_type <> 'content_folder'
              connect by prior ci.item_id = ci.parent_id
              start with ci.item_id = cr_folders.folder_id)
        else cr_revisions.content_length
      end as content_size,
      case
        when cr_items.content_type = 'content_folder' then cr_folders.label
        when cr_items.content_type = 'content_extlink' then cr_extlinks.label
        else cr_items.name
      end as name,
      cr_items.name as file_upload_name,
      cr_revisions.title,
      acs_objects.last_modified,
      cr_extlinks.url,
      cr_items.parent_id,
      cr_items.name as key,
      cr_mime_types.label as pretty_type,
      case
        when cr_items.content_type = 'content_folder' then 0
        else 1
      end as sort_key
    from cr_items, cr_extlinks, cr_folders, cr_revisions, acs_objects, cr_mime_types
    where cr_items.item_id = cr_extlinks.extlink_id(+)
      and cr_items.item_id = cr_folders.folder_id(+)
      and cr_items.item_id = acs_objects.object_id
      and cr_items.live_revision = cr_revisions.revision_id(+)
      and cr_revisions.mime_type = cr_mime_types.mime_type(+);
