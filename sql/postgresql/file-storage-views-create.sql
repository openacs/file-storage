--
-- file-storage/sql/postgresql/file-storage-views-create.sql
--
-- @author Kevin Scaldeferri (kevin@arsdigita.com)
-- @creation-date 6 Nov 2000
-- @cvs-id $Id$
--

create view fs_urls_full
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

create view fs_objects
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
              where ci2.content_type <> 'content_folder'
                and ci2.tree_sortkey between cr_items.tree_sortkey and tree_right(cr_items.tree_sortkey))
        else cr_revisions.content_length
      end as content_size,
      case
        when cr_items.content_type = 'content_folder' then cr_folders.label
        when cr_items.content_type = 'content_extlink' then cr_extlinks.label
        else cr_items.name
      end as name,
      cr_revisions.title as file_upload_name,
      acs_objects.last_modified,
      cr_extlinks.url,
      cr_items.parent_id,
      cr_items.name as key,
      case
        when cr_items.content_type = 'content_folder' then 0
        else 1
      end as sort_key
    from cr_items left join cr_extlinks on (cr_items.item_id = cr_extlinks.extlink_id)
      left join cr_folders on (cr_items.item_id = cr_folders.folder_id)
      left join cr_revisions on (cr_items.live_revision = cr_revisions.revision_id)
      join acs_objects on (cr_items.item_id = acs_objects.object_id);
