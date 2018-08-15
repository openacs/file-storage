-- 
-- packages/file-storage/sql/oracle/upgrade/upgrade-5.2.0d5-5.2.0d6.sql
-- 
-- @author Malte Sussdorff (sussdorff@sussdorff.de)
-- @creation-date 2005-08-25
-- @cvs-id $Id$
--

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
              where (ci.content_type = 'content_extlink' or ci.content_type = 'file_storage_object')
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
        case
        when cr_items.content_type = 'content_folder'
        then acs_objects.last_modified
        else cr_revisions.publish_date
        end as last_modified,
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
