<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="new_lob_file">      
      <querytext>
      select file_storage__new_file (
        	:filename,           	-- filename
        	:folder_id,          	-- parent_id
        	:user_id,            	-- creation_user
        	:creation_ip,        	-- creation_ip
		true			-- indb_p
		);
      </querytext>
</fullquery>

<fullquery name="new_fs_file">      
      <querytext>
        select file_storage__new_file (
        	:filename,           	-- filename
        	:folder_id,          	-- parent_id
        	:user_id,            	-- creation_user
        	:creation_ip,        	-- creation_ip
		false			-- indb_p
		);
      </querytext>
</fullquery>

 
<fullquery name="new_version">      
      <querytext>

    	select file_storage__new_version (
		:title,		-- title
       		:description,		-- description
       		:mime_type,		-- mime_type
       		:file_id,		-- item_id
       		:user_id,		-- creation_user
       		:creation_ip		-- creation_ip
		);

     </querytext>
</fullquery>


<fullquery name="lob_content">      
      <querytext>

	update cr_revisions
 	set lob = [set __lob_id [db_string get_lob_id "select empty_lob()"]]
	where revision_id = :version_id

     </querytext>
</fullquery>

<fullquery name="lob_size">      
      <querytext>

	update cr_revisions
 	set content_length = lob_length(lob)
	where revision_id = :version_id

     </querytext>
</fullquery>



<fullquery name="fs_content_size">      
      <querytext>

	update cr_revisions
 	set content = '$tmp_filename',
	    content_length = $tmp_size
	where revision_id = :version_id

     </querytext>
</fullquery>

</queryset>


