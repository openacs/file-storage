-- DRB: As if the following union view weren't unscalable enough for PG
-- (which can't optimize them at all) the following view with its
-- summing of content items sucks to no end.

drop view fs_folders;
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

-- DRB: This used to be a plain union view requiring a sort
-- and unique sweep.  Union all speeds it up a bit.

drop view fs_objects;
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
