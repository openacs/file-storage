<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_file_id">      
      <querytext>
      
    	select content_item.get_live_revision(
		content_item.get_id(
			:path,
			file_storage.get_root_folder([ad_conn package_id])
			)
		) as version_id from dual

      </querytext>
</fullquery>

<fullquery name="version_write_blob">      
      <querytext>

	select content
        from   cr_revisions
        where  revision_id = $version_id
 
      </querytext>
</fullquery>

<fullquery name="version_write_file">      
      <querytext>

	    select '[cr_fs_path]' || filename as content
            from cr_revisions
            where revision_id = $version_id

      </querytext>
</fullquery>

<fullquery name="file_type">      
      <querytext>

	select mime_type,(case when filename is null 
                               then 1
		               else 0
		          end) as indb_p 
	from   cr_revisions r
	where  revision_id = :version_id

      </querytext>
</fullquery>

</queryset>
