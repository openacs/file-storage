ad_page_contract {
    script to recieve the new file and insert it into the database

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    folder_id:integer,notnull
    upload_file:notnull,trim
    upload_file.tmpfile:tmpfile
    title:notnull,trim
    description
} -validate {
    valid_folder -requires {folder_id:integer} {
	if ![fs_folder_p $folder_id] {
	    ad_complain "The specified parent folder is not valid."
	}
    }

    max_size -requires {upload_file} {
	set n_bytes [file size ${upload_file.tmpfile}]
	set max_bytes [ad_parameter "MaximumFileSize"]
	if { $n_bytes > $max_bytes } {
	    ad_complain "Your file is larger than the maximum file size allowed on this system ([util_commify_number $max_bytes] bytes)"
	}
    }
} 

set user_id [ad_conn user_id]

# check for write permission on this folder

ad_require_permission $folder_id write

# get the filename part of the upload file
if ![regexp {[^//\\]+$} $upload_file filename] {
    # no match
    set filename $upload_file
}

# get the ip
set creation_ip [ad_conn peeraddr]

db_transaction {

# create the new item

set item_id [db_exec_plsql item_add "
begin
    :1 := content_item.new (
        name => :filename,
        parent_id => :folder_id,
        context_id => :folder_id,
        creation_user => :user_id,
        creation_ip => :creation_ip,
        item_subtupe => 'file_storage_item' -- needed by site-wide search
   );
end;"]

# create a revision

# The content repository is kinda stupid about mime types,
# so we have to check if we know about this one and possibly 
# add it.

set mime_type [fs_maybe_create_new_mime_type $upload_file]

set revision_id [db_exec_plsql revision_add "
begin
    :1 := content_revision.new (
        title => :title,
        description => :description,
        mime_type => :mime_type,
        item_id => :item_id,
        creation_user => :user_id,
        creation_ip => :creation_ip
    );
end;"]

db_dml content_add "
update cr_revisions
set    content = empty_blob()
where  revision_id = :revision_id
returning content into :1" -blob_files [list ${upload_file.tmpfile}]

db_exec_plsql make_live "
begin
    content_item.set_live_revision(:revision_id);
end;"

} on_error {
    # most likely a duplicate name or a double click

    if [db_string duplicate_check "
    select count(*)
    from   cr_items
    where  name = :filename
    and    parent_id = :folder_id"] {
	ad_return_complaint 1 "Either there is already a file with the name \"$filename\" or you clicked on the button more than once.  You can use the Back button to return and choose a new name, or <a href=\"?folder_id=$folder_id\">return to the directory listing</a> to see if your file is there."
    } else {
	ad_return_complaint 1 "We got an error that we couldn't readily identify.  Please let the system owner know about this.

	<pre>$errmsg</pre>"
    }
    
    return
}


ad_returnredirect "?folder_id=$folder_id"