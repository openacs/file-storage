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

	set file_id [db_exec_plsql new_lob_file "
	begin
    		:1 := file_storage.new_file (
        		title => :title,
        		folder_id => :folder_id,
        		creation_user => :user_id,
        		creation_ip => :creation_ip,
		        indb_p => 't'
   			);

        end;"]

	set version_id [db_exec_plsql new_version "
	begin
    		:1 := file_storage.new_version (
        		filename => :filename,
        		description => :description,
        		mime_type => :mime_type,
        		item_id => :file_id,
        		creation_user => :user_id,
        		creation_ip => :creation_ip
    			);
        end;"]

	db_dml lob_content "
	update cr_revisions
	set    content = empty_lob()
	where  revision_id = :version_id
	returning content into :1" -blob_files [list ${upload_file.tmpfile}]


	# Unfortunately, we can only calculate the file size after the lob is uploaded 
	db_dml lob_size "
	update cr_revisions
 	set content_length = dbms_lob.getlength(content) 
	where revision_id = :version_id"

    } else {

	set file_id [db_exec_plsql new_fs_file "
	begin
    		:1 := file_storage.new_file (
        		title => :title,
        		folder_id => :folder_id,
        		creation_user => :user_id,
        		creation_ip => :creation_ip,
		        indb_p => 'f'
   			);
	end;"]


	set version_id [db_exec_plsql new_version "
	begin

    		:1 := file_storage.new_version (
        		filename => :filename,
        		description => :description,
        		mime_type => :mime_type,
        		item_id => :file_id,
        		creation_user => :user_id,
        		creation_ip => :creation_ip
    			);

        end;"]

	set tmp_filename [cr_create_content_file $file_id $version_id ${upload_file.tmpfile}]
	set tmp_size [cr_file_size $tmp_filename]

	db_dml fs_content_size "
	update cr_revisions
	set content = '$tmp_filename',
            content_length = $tmp_size
	where  revision_id = :version_id"

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
 
       ad_return_complaint 1 "You probably clicked on the Add button more than once. Check if the file is properly loaded on the <a href=\"index?folder_id?$folder_id\">folder</a> you wan, or you can use the Back button to return and re-enter the version file."      

    return
}


ad_returnredirect "?folder_id=$folder_id"
