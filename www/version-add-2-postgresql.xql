<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="revision_add">      
      <querytext>

    	select content_revision__new (
        	:name,		-- title
        	:description,	-- description
        	:mime_type,	-- mime_type
        	:file_id,	-- item_id
        	:user_id,	-- creation_user
        	:ip_addr	-- creation_ip
    		);

      </querytext>
</fullquery>

 
<fullquery name="content_add">      
      <querytext>

	update cr_revisions
	set    content = empty_blob()
	where  revision_id = :revision_id
	returning content into :1

      </querytext>
</fullquery>

 
<fullquery name="make_live">      
      <querytext>

    	select content_item__set_live_revision(:revision_id);

      </querytext>
</fullquery>

 
</queryset>
