<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="folder_create">      
      <querytext>

	select file_storage__new_folder (
        	:name, 		-- name 
        	:folder_name, 	-- label
        	:parent_id, 	-- parent_id 
        	:user_id,    	-- creation_user
        	:creation_ip 	-- creation_ip
    		);

      </querytext>
</fullquery>

</queryset>

