-- 
-- packages/file-storage/sql/postgresql/upgrade/upgrade-5.2.0d5-5.2.0d6.sql
-- 
-- @author Malte Sussdorff (sussdorff@sussdorff.de)
-- @creation-date 2005-08-25
-- @arch-tag: 8a2322db-a227-4ea7-bafc-a42164675c1b
-- @cvs-id $Id$
--

drop view fs_objects;

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
              from cr_items ci2
              where ci2.content_type in ('content_extlink','file_storage_object')
                and ci2.tree_sortkey between cr_items.tree_sortkey and tree_right(cr_items.tree_sortkey))
        else cr_revisions.content_length
      end as content_size,
      case
        when cr_items.content_type = 'content_folder' then cr_folders.label
        when cr_items.content_type = 'content_extlink' then cr_extlinks.label
        else cr_items.name
      end as name,
      cr_items.name as file_upload_name,
      cr_revisions.title,
      cr_revisions.mime_type,
      acs_objects.last_modified,
      cr_extlinks.url,
      cr_items.parent_id,
      cr_items.name as key,
      case
        when cr_items.content_type = 'content_folder' then 0
        else 1
      end as sort_key,
      cr_mime_types.label as pretty_type

    from cr_items left join cr_extlinks on (cr_items.item_id = cr_extlinks.extlink_id)
      
      left join cr_folders on (cr_items.item_id = cr_folders.folder_id)
      left join cr_revisions on (cr_items.live_revision = cr_revisions.revision_id)
      left join cr_mime_types on (cr_revisions.mime_type = cr_mime_types.mime_type)
      join acs_objects on (cr_items.item_id = acs_objects.object_id);
