<?xml version="1.0"?>
<queryset>

<fullquery name="fs_folder_copy.get_folder_data">
<querytext>
    SELECT fsf.name,
           fsf.key as pretty_name,
           fsf.parent_id,
           ao.creation_user,
           ao.creation_ip,
           crf.description 
    FROM  fs_folders as fsf,
          acs_objects as ao,
          cr_folders as crf
    WHERE ao.object_id=:old_folder_id and crf.folder_id=ao.object_id and fsf.folder_id=ao.object_id
</querytext>
</fullquery>

<fullquery name="fs_folder_copy.get_subfolders_list">
<querytext>
    SELECT folder_id as subfolders_list
    FROM fs_folders
    WHERE parent_id= :old_folder_id
</querytext>
</fullquery>


<fullquery name="fs_folder_copy.get_file_list">
<querytext>
    SELECT ao.object_id,
           ao.creation_user,
           ao.creation_ip 
    FROM acs_objects as ao, fs_files as fsf
    WHERE ao.context_id=:old_folder_id and fsf.file_id=ao.object_id
</querytext>
</fullquery>

<fullquery name="fs_folder_copy.file_copy">      
      <querytext>

	select file_storage__copy_file (
            	:file_id,	     -- file_id
            	:new_folder_id,  -- taget_folder_id
            	:user_id,	     -- creation_user
            	:ip_address	     -- creation_ip
        	);

      </querytext>
</fullquery>



</queryset>
