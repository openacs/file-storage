<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="new_version">      
      <querytext>
      
	begin
    	:1 := file_storage.new_version(
        	filename => :filename,
        	description => :description,
        	mime_type => :mime_type,
        	item_id => :file_id,
        	creation_user => :user_id,
        	creation_ip => :creation_ip
   		);
	end;

      </querytext>
</fullquery>

 
<fullquery name="lob_content">      
      <querytext>
      
	update cr_revisions
	set    content = empty_blob()
	where  revision_id = :version_id
	returning content into :1

      </querytext>
</fullquery>

<fullquery name="lob_size">      
      <querytext>

	update cr_revisions
 	set content_length = dbms_lob.getlength(content) 
	where revision_id = :version_id

     </querytext>
</fullquery>



<fullquery name="fs_content_size">      
      <querytext>

	update cr_revisions
 	set filename = '$tmp_filename',
	    content_length = $tmp_size
	where revision_id = :version_id

     </querytext>
</fullquery>
 
</queryset>
