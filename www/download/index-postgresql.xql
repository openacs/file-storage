<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_file_id">      
      <querytext>

    	select content_item__get_live_revision(
		content_item__get_id(
			:path,
			file_storage__get_root_folder([ad_conn package_id]),
			'f'
			)
		) as version_id from dual

      </querytext>
</fullquery>

<fullquery name="version_write_blob">      
      <querytext>

	select r.lob as content, i.storage_type
        from   cr_revisions r, cr_items i
	where r.item_id = i.item_id
	and   r.revision_id = :version_id
 
      </querytext>
</fullquery> 

<fullquery name="version_write_file">      
      <querytext>

	select '[cr_fs_path]' || r.content, i.storage_type
        from   cr_revisions r, cr_items i
	where r.item_id = i.item_id
	and   r.revision_id = :version_id
 
      </querytext>
</fullquery> 

<fullquery name="file_type">      
      <querytext>

	select mime_type,(case when lob is null then 0
		               else 1
		          end) as indb_p 
	from   cr_revisions 
	where  revision_id = :version_id

      </querytext>
</fullquery>

</queryset>
