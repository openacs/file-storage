<?xml version="1.0"?>
<queryset>

  <fullquery name="select_subscrs">
    <querytext>
      select subscr_id, short_name, folder_id
      from fs_rss_subscrs
      where folder_id = :folder_id
      order by upper(short_name)
    </querytext>
  </fullquery>

  <fullquery name="select_folder_contents">
    <querytext>
      select fs_objects.object_id,
             fs_objects.mime_type,
             fs_objects.name,
             fs_objects.live_revision,
             fs_objects.type,
             fs_objects.pretty_type,
             to_char(fs_objects.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,
             fs_objects.content_size,
             fs_objects.url,
             fs_objects.sort_key,
             -fs_objects.sort_key as sort_key_desc,
             fs_objects.file_upload_name,
             fs_objects.title,
             case
               when :folder_path is null
               then fs_objects.file_upload_name
               else :folder_path || fs_objects.file_upload_name
             end as file_url,
             fs_objects.last_modified >= (current_timestamp - cast('$n_past_days days' as interval)) as new_p
      from fs_objects
      where fs_objects.parent_id = :folder_id
      and   acs_permission.permission_p(fs_objects.object_id, :viewing_user_id, 'read')
      and   (:categories_p = 'f' or
             :category_id is null or
             fs_objects.object_id in (select object_id from category_object_map
                                       where category_id = :category_id)
             )
      $orderby

    </querytext>
  </fullquery>

</queryset>
