<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="revision_add">      
      <querytext>

    	select content_revision__new (
        	:name,		-- title
        	:description,	-- description
		now(),		-- publish_date (default)
        	:mime_type,	-- mime_type
		null,		-- nls_language (default)
		null,		-- data (default)
        	:file_id,	-- item_id
		null,		-- rvision_id (default)
		now(),		-- creation_date (default)
        	:user_id,	-- creation_user
        	:ip_addr	-- creation_ip
    		);

      </querytext>
</fullquery>

 
<fullquery name="content_add">      
      <querytext>

	update cr_revisions
 	set lob = [set __lob_id [db_string get_lob_id "select empty_lob()"]]
	where  revision_id = :revision_id

      </querytext>
</fullquery>

 
<fullquery name="make_live">      
      <querytext>

    	select content_item__set_live_revision(:revision_id);

      </querytext>
</fullquery>

 
</queryset>
