<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="folder_create">      
      <querytext>

	select content_folder__new (
        	:name, 		-- name 
        	:folder_name, 	-- label
		null,		-- description
        	:parent_id, 	-- parent_id 
		null,		-- context_id (default)
		null,		-- folder_id (default)
		now(),		-- creation_date
        	:user_id,    	-- creation_user
        	:creation_ip 	-- creation_ip
    		);

      </querytext>
</fullquery>

 
<fullquery name="register_content">      
      <querytext>

    	select content_folder__register_content_type(
		:folder_id, 		-- folder_id
		'content_revision',	-- content_type
		'f'			-- include_subtypes (default)
		);
    	select content_folder__register_content_type(
		:folder_id,		-- folder_id
		'content_folder',	-- content_type
		'f'			-- include_subtypes (default)
		);
      </querytext>
</fullquery>

 
<fullquery name="grant_admin_perms">      
      <querytext>

    	select acs_permission__grant_permission (
        	:folder_id, 	-- object_id
        	:user_id,	-- grantee_id
        	'admin'		-- privilege
    		);

      </querytext>
</fullquery>

 
</queryset>

