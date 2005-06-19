ad_library {
    Callbacks for the search package.

    @author Dirk Gomez <openacs@dirkgomez.de>
    @creation-date 2005-06-16
    @cvs-id $Id$
}


ad_proc -public -callback search::datasource -impl file_storage_object {} {

    @author Dirk Gomez (openacs@dirkgomez.de)
    @author Jowell S. Sabino (jowellsabino@netscape.net)
    @creation_date 2005-06-13

    returns a datasource for the search package
    this is the content that will be indexed by the full text
    search engine.

} {
    # We probably don't need the whole big query here. TODO: Review.
    db_0or1row fs_datasource {
	select r.revision_id as object_id,
	       i.name as title,
	       case i.storage_type
		     when 'lob' then r.lob::text
		     when 'file' then '[cr_fs_path]' || r.content
	             else r.content
	        end as content,
	        r.mime_type as mime,
	        '' as keywords,
	        i.storage_type as storage_type
	from cr_items i, cr_revisions r
	where r.item_id = i.item_id
	and   r.revision_id = :object_id
    } -column_array datasource

    # retrieve the file-storage file
    set file_content [cr_write_content -string -revision_id $object_id ]

    # and convert the file to text. Currently using a very poor man's
    # INSO filter (==strings).

    # Also file creation might be implemented too poorly - e.g. there
    # are probably platforms which do not have /tmp.  I think there is
    # no need to muck around with highly temporary filenames
    # though. The revision_id (passed in in the variable object_id) is
    # unique anyway.

    set filename "/tmp/search$object_id"
    set fileId [open $filename "w"]
    puts -nonewline $fileId $file_content
    close $fileId

    # TODO: replace strings with a procedure.
    set text_file_content [exec strings $filename ]

    file delete $filename

    return [list object_id $object_id \
                title datasource(title) \
                content $text_file_content \
                keywords {} \
                storage_type text \
                mime text/plain ]
}
	
ad_proc -public -callback search::url -impl file_storage_object {} {

    @author Dirk Gomez (openacs@dirkgomez.de)
    @author Jowell S. Sabino (jowellsabino@netscape.net)
    @creation_date 2005-06-13

    returns a url for a file-storage item to the search package

} {
    set revision_id $object_id

    db_1row fs_get_package_id { }
hurz

    db_1row fs_get_url_stub { }

    return "${url_stub}download/index?version_id=$revision_id"
}



