<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>
    <fullquery name="select_folder_contents">
        <querytext>

            select fs_objects.object_id,
                   fs_objects.name,
                   fs_objects.live_revision,
                   fs_objects.type,
                   to_char(fs_objects.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified,
                   fs_objects.content_size,
                   fs_objects.url,
                   fs_objects.sort_key,
                   fs_objects.file_upload_name,
                   case when fs_objects.last_modified >= (now() - interval '$n_past_days days') then 1 else 0 end as new_p,
                   delete_p,
                   write_p
            from
              (select fs_folders.folder_id as object_id,
                 0 as live_revision,
                 'folder' as type,
                 fs_folders.content_size,
                 fs_folders.name,
                 '' as file_upload_name,
                 fs_folders.last_modified,
                 '' as url,
                 fs_folders.parent_id,
                 cast('f' as bool) as write_p,
                 cast('f' as bool) as delete_p,
                 0 as sort_key
               from fs_folders
               where fs_folders.parent_id = :folder_id
                 and exists (select 1
                             from acs_object_party_privilege_map m
                             where m.object_id = fs_folders.folder_id
                             and m.party_id = :viewing_user_id
                             and m.privilege = 'read')
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
                 cast('f' as bool) as write_p,
                 cast('f' as bool) as delete_p,
                 1 as sort_key
               from fs_files
               where fs_files.parent_id = :folder_id
                 and exists (select 1
                             from acs_object_party_privilege_map m
                             where m.object_id = fs_files.file_id
                               and m.party_id = :viewing_user_id
                               and m.privilege = 'read')
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
                 acs_permission__permission_p(fs_urls.url_id, :viewing_user_id, 'write') as write_p,
                 acs_permission__permission_p(fs_urls.url_id, :viewing_user_id, 'delete') as delete_p,
                 1 as sort_key
               from fs_urls_full
               where fs_urls_full.folder_id = :folder_id
                 and exists (select 1
                             from acs_object_party_privilege_map m
                             where m.object_id = fs_urls_full.url_id
                               and m.party_id = :viewing_user_id
                               and m.privilege = 'read')) as fs_objects
            order by fs_objects.sort_key, fs_objects.name

        </querytext>
    </fullquery>
</queryset>
