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
	    ad_complain "[_ file-storage.lt_The_specified_parent_]"
	}
    }

    max_size -requires {upload_file} {
	set n_bytes [file size ${upload_file.tmpfile}]
	set max_bytes [ad_parameter "MaximumFileSize"]
	if { $n_bytes > $max_bytes } {
	    ad_complain [_ file-storage.lt_Your_file_is_larger_t_1] [list max_number_of_bytes [util_commify_number $max_bytes]]]
	}
    }
} 

# Check for write permission on this folder
ad_require_permission $folder_id write

# Get the filename part of the upload file
if ![regexp {[^//\\]+$} $upload_file filename] {
    # no match
    set filename $upload_file
}

# Get the user
set user_id [ad_conn user_id]

# Get the ip
set creation_ip [ad_conn peeraddr]

# The content repository is kinda stupid about mime types,
# so we have to check if we know about this one and possibly 
# add it.
set mime_type [fs_maybe_create_new_mime_type $upload_file]

# Get the storage type
set indb_p [ad_parameter "StoreFilesInDatabaseP" -package_id [ad_conn package_id]]

db_transaction {

    # create the new item
    if {$indb_p} {

        ns_log Notice LARS1
	set file_id [db_exec_plsql new_lob_file {}]
        
        ns_log Notice LARS2
	set version_id [db_exec_plsql new_version {}]

        ns_log Notice LARS3
	db_dml lob_content {} -blob_files [list ${upload_file.tmpfile}]

        ns_log Notice LARS4
	# Unfortunately, we can only calculate the file size after the lob is uploaded 
	db_dml lob_size {}
        ns_log Notice LARS5

    } else {

	set file_id [db_exec_plsql new_fs_file {}]


	set version_id [db_exec_plsql new_version {}]

	set tmp_filename [cr_create_content_file $file_id $version_id ${upload_file.tmpfile}]
	set tmp_size [cr_file_size $tmp_filename]

	db_dml fs_content_size {}

    }


} on_error {

    # most likely a duplicate name or a double click

#    if [db_string duplicate_check "
#    select count(*)
#    from   cr_items
#    where  name = :filename
#    and    parent_id = :folder_id"] {
#	ad_return_complaint 1 "Either there is already a file with the name \"$tmp_filename\" or you clicked on the button more than once.  You can use the Back button to return and choose a new name, or <a href=\"?folder_id=$folder_id\">return to the directory listing</a> to see if your file is there."
#    } else {
#	ad_return_complaint 1 "We got an error that we couldn't readily identify.  Please let the system owner know about this.
#
#	<pre>$errmsg</pre>"
#    }
 
       set folder_name "[_ file-storage.folder]"
       set folder_link "<a href=\"index?folder_id?$folder_id\">$folder_name</a>"
       ad_return_complaint 1 "[_ file-storage.lt_You_probably_clicked_ [list folder_link $folder_link]]"

       ad_script_abort
}


ad_returnredirect "?folder_id=$folder_id"
