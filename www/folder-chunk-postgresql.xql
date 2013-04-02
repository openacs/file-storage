<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>
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
                   case
                     when fs_objects.last_modified >= (now() - cast('$n_past_days days' as interval))
                     then 1
                     else 0
                   end as new_p
            from fs_objects
            where fs_objects.parent_id = :folder_id
              and exists (select 1
                   from acs_object_party_privilege_map m
                   where m.object_id = fs_objects.object_id
                     and m.party_id = :viewing_user_id
                     and m.privilege = 'read')
                $categories_limitation
		$orderby
        </querytext>
    </fullquery>

    <fullquery name="dbqd.file-storage.www.folder-chunk.select_folder_contents">
        <rdbms><type>postgresql</type><version>8.4</version></rdbms>
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
                   case
                     when fs_objects.last_modified >= (now() - cast('$n_past_days days' as interval))
                     then 1
                     else 0
                   end as new_p,
                   case
                    when fs_objects.type = 'folder' then
                        (select description from cr_folders where folder_id = fs_objects.object_id)
                    when fs_objects.type = 'url' then
                        (select description from cr_extlinks where extlink_id = fs_objects.object_id)
                   else
                       (select description from cr_revisions where revision_id = fs_objects.live_revision)
                   end as description
            from fs_objects
            where fs_objects.parent_id = :folder_id
              and acs_permission__permission_p(fs_objects.object_id, :viewing_user_id,'read')
        $orderby
        </querytext>
    </fullquery>

    <fullquery name="get_folder_path">
        <querytext>

            select content_item__get_path(:folder_id, :root_folder_id);

        </querytext>
    </fullquery>

    <partialquery name="categories_limitation">
        <querytext>

            and fs_objects.object_id in ( select object_id from category_object_map where category_id = :category_id )

        </querytext>
    </partialquery>

</queryset>
