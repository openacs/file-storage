<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="file_select">
        <querytext>
            select cr_items.item_id as file_id,
                   cr_items.name as name,
                   cr_items.live_revision,
                   cr_revisions.mime_type as type,
                   to_char(acs_objects.last_modified,'YYYY-MM-DD HH24:MI') as last_modified,
                   cr_revisions.content_length as content_size,
                   1 as ordering_key
            from cr_items,
                 cr_revisions,
                 acs_objects
            where cr_items.parent_id = :folder_id
            and cr_items.content_type = 'file_storage_object'
            and 't' = acs_permission.permission_p(cr_items.item_id, :user_id, 'read')
            and cr_items.item_id = acs_objects.object_id
            and cr_items.live_revision = cr_revisions.revision_id (+)
            UNION
            select cr_items.item_id as file_id,
                   cr_folders.label as name,
                   0 as live_revision,
                   'Folder' as type,
                   NULL as last_modified,
                   0 as content_size,
                   0 as ordering_key
            from cr_items,
                 cr_folders
            where cr_items.parent_id = :folder_id
            and cr_items.item_id = cr_folders.folder_id
            and 't' = acs_permission.permission_p(cr_folders.folder_id, :user_id, 'read')
            order by ordering_key, name
        </querytext>
    </fullquery>

</queryset>
