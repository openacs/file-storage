ad_page_contract {
    add the new version into the system.

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 8 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
    name:notnull
    upload_file:trim,notnull
    upload_file.tmpfile:tmpfile
    description:trim
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
	    ad_complain "The specified file is not valid."
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

#check for write permission on the file

ad_require_permission $file_id write

# get the ip
set ip_addr [ad_conn peeraddr]

db_transaction {

set mime_type [fs_maybe_create_new_mime_type $upload_file]

set revision_id [db_exec_plsql revision_add "
begin
    :1 := content_revision.new (
        title => :name,
        description => :description,
        mime_type => :mime_type,
        item_id => :file_id,
        creation_user => :user_id,
        creation_ip => :ip_addr
    );
end;"]

db_dml content_add "
update cr_revisions
set    content = empty_blob()
where  revision_id = :revision_id
returning content into :1" -blob_files [list ${upload_file.tmpfile}]

# This should probably depend on a toggle on the previous page
db_exec_plsql make_live "
begin
    content_item.set_live_revision(:revision_id);
end;"

# Should we change the modification info on the file?

}

ad_returnredirect "file?file_id=$file_id"