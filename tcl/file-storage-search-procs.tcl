ad_library {
    Site-wide search procs for file storage
    Implements OpenFTS Search service contracts

    @author Jowell S. Sabino (jowellsabino@netscape.net)
    @creation-date 2001-12-18
    @cvs-id $Id$
}

ad_proc -private fs__datasource {
    revision_id
} {
    @author Jowell S. Sabino (jowellsabino@netscape.net)
} {

    db_0or1row fs_datasource {
	select r.revision_id as object_id,
	       i.name as title,
	       case i.storage_type
		     when 'lob' then r.lob::text
		     when 'file' then r.content
	             else r.content
	        end as content,
	        r.mime_type as mime,
	        '' as keywords,
	        i.storage_type as storage_type
	from cr_items i, cr_revisions r
	where r.item_id = i.item_id
	and   r.revision_id = :revision_id
    } -column_array datasource

    if {$storage_type eq "file"} {
        set datasource(content) [content::revision::get_cr_file_path -revision_id $object_id]
    }

    return [array get datasource]
}

ad_proc -private fs__url {
    revision_id
} {
    @author Jowell S. Sabino (jowellsabino@netscape.net)
} {

    db_1row fs_get_package_id "
	select f.package_id as package_id
	  from fs_root_folders f,
       	  (select parent.parent_id
	     from cr_items parent, cr_items children, cr_revisions r
	    where children.item_id = r.item_id
	      and r.revision_id = $revision_id
              and children.tree_sortkey
                    between parent.tree_sortkey
                    and     tree_right(parent.tree_sortkey) ) as i
  	  where f.folder_id = i.parent_id
    "

    db_1row fs_get_url_stub "
        select site_node__url(node_id) as url_stub
        from site_nodes
        where object_id=:package_id
    "

    return "${url_stub}download/index?version_id=$revision_id"
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
