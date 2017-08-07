<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>


<fullquery name="fs_datasource">
      <querytext>
	select r.revision_id as object_id,
 	    i.name as title,
	    (case i.storage_type
		     when 'lob' then r.lob::text
		     when 'file' then '[cr_fs_path]' || r.content
	             else r.content
	     end) as content,
	     r.mime_type as mime,
	     '' as keywords,
	     i.storage_type as storage_type
	from  cr_items i, cr_revisions r
	where r.item_id = i.item_id
	and   r.revision_id = :object_id
      </querytext>
</fullquery>

</queryset> 
