<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>
    <fullquery name="select_folder_contents">
        <querytext>

            select fs_objects.object_id,
                   fs_objects.name,
                   fs_objects.live_revision,
                   fs_objects.type,
                   to_char(fs_objects.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,
                   fs_objects.content_size,
                   fs_objects.url,
                   content_item.get_path(fs_objects.object_id, :root_folder_id) as file_url,
                   fs_objects.sort_key,
                   fs_objects.file_upload_name,
                   case when fs_objects.last_modified >= (sysdate - :n_past_days) then 1 else 0 end as new_p,
                   case
                     when type = 'url'
                     then acs_permission.permission_p(fs_objects.object_id, :viewing_user_id, 'delete')
                     else 't'
                   end as delete_p,
                   case
                     when type = 'url'
                     then acs_permission.permission_p(fs_objects.object_id, :viewing_user_id, 'write')
                     else 't'
                   end as write_p
            from fs_objects
            where fs_objects.parent_id = :folder_id
              and exists (select 1
                   from acs_object_party_privilege_map m
                   where m.object_id = fs_objects.object_id
                     and m.party_id = :viewing_user_id
                     and m.privilege = 'read')
            order by fs_objects.sort_key, fs_objects.name

        </querytext>
    </fullquery>
</queryset>
