<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="item_add">      
      <querytext>

    	select content_item__new (
        	:filename,           -- name
        	:folder_id,          -- parent_id
		null,	             -- item_id (default)
		null,	             -- locale (default)
	        now(),	             -- creation_date (default)
        	:user_id,            -- creation_user
        	:folder_id,          -- context_id
        	:creation_ip,        -- creation_ip
		'file_storage_item', -- item_subtype (needed by site-wide search)
		'content_revision',  -- content_type (default)
		null,		     -- title (default)
		null,		     -- description
		'text/plain',	     -- mime_type (default)
		null,	             -- nls_language (default)
		null		     -- data (default)
   		);

      </querytext>
</fullquery>

 
<fullquery name="revision_add">      
      <querytext>

    	select content_revision__new (
        		:title,		-- title
        		:description, 	-- description
			now(),		-- publish_date
        		:mime_type,	-- mime_type
			null,		-- nls_language
			null,		-- data (default)
        		:item_id,	-- item_id
			null,		-- revision_id
			now(),		-- creation_date
        		:user_id,	-- creation_user
        		:creation_ip	-- creation_ip
    			);

      </querytext>
</fullquery>

 
<fullquery name="content_add">      
      <querytext>

	update cr_revisions
 	set lob = [set __lob_id [db_string get_lob_id "select empty_lob()"]]
	where revision_id = :revision_id

     </querytext>
</fullquery>

 
<fullquery name="make_live">      
      <querytext>

    	select content_item__set_live_revision(:revision_id);

      </querytext>
</fullquery>

 
</queryset>
