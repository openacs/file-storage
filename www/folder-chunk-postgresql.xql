<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>
    <fullquery name="select_folder_contents">
        <querytext>
            select  fs_objects.object_id,
                         fs_objects.name,
                         fs_objects.live_revision,
                         fs_objects.type,
                         to_char(fs_objects.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified,      
                         fs_objects.content_size,
                         fs_objects.url,
                         fs_objects.key,
                         fs_objects.sort_key,
			 fs_objects.file_upload_name,
                         case when fs_objects.last_modified >= (now() - interval '$n_past_days days') then 1 else 0 end as new_p
                  from fs_objects
                  where fs_objects.parent_id = :folder_id
	          order by sort_key, name
        </querytext>
    </fullquery>
</queryset>