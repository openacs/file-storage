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
	from cr_items i, cr_revisions r
	where r.item_id = i.item_id
	and   r.revision_id = :revision_id
      </querytext>
</fullquery>

<fullquery name="fs_get_package_id">
      <querytext>
	select f.package_id as package_id
	  from fs_root_folders f,
       	  (select i2.parent_id
	     from cr_items i1, cr_items i2, cr_revisions r
	    where i1.item_id = r.item_id
	      and r.revision_id = :revision_id
              and i2.tree_sortkey <= i1.tree_sortkey
	      and i1.tree_sortkey i2.tree_sortkey and tree_right(i2.tree_sortkey)) as i
  	  where f.folder_id = i.parent_id
       </querytext>
</fullquery>

<fullquery name="fs_get_url_stub">
      <querytext>
        select site_node__url(node_id) as url_stub
        from site_nodes
        where object_id=:package_id
      </querytext>
</fullquery>

</queryset> 
