ad_page_contract {
    script to move a file into a new folder

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 13 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
    parent_id:integer,notnull
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
	    ad_complain "The specified file is not valid."
	}
    }

    valid_folder -requires {parent_id} {
	if ![fs_folder_p $parent_id] {
	    ad_complain "The specified parent folder is not valid."
	}
    }
}

# check for write permission on both the file and the target folder

ad_require_permission $file_id write
ad_require_permission $parent_id write

set user_id [ad_conn user_id]
set address [ad_conn peeraddr]

db_transaction {

db_exec_plsql file_move "
begin
    file_storage.move_file (
    	file_id => :file_id,
    	target_folder_id => :parent_id,
        creation_user => :user_id,
        creation_ip => :address:
    );
end;"

db_dml context_update "
update acs_objects
set    context_id = :parent_id
where  object_id = :file_id"

} on_error {
    # most likely a duplicate name or a double click

    # JS: I commented out the more elaborate error reporting, since Postgres does not seem
    # JS: to like quering a table that has just aborted a transaction on it. Instead, I copied
    # JS: the error reporting of file-copy-2.tcl does

    ad_return_complaint 1 "We received an error from the database.  Probably
    the folder you selected already contains a file with the same name.

    <pre>$errmsg</pre>"

    #set filename [db_string filename "
    #select name from cr_items where item_id = :file_id"]

    #if [db_string duplicate_check "
    #select count(*)
    #from   cr_items
    #where  name = :filename
    #and    parent_id = :parent_id"] {
    #	ad_return_complaint 1 "Either there is already a file in the specified folder with the name \"$filename\" or you clicked on the button more than once.  You can <a href=\"index?folder_id=$parent_id\">return to the directory listing</a> to see if your file is there."
    #} else {
    #ad_return_complaint 1 "We got an error that we couldn't readily identify.  Please let the system owner know about this.

    #	<pre>$errmsg</pre>"
    #}
    
    ad_script_abort
}

ad_returnredirect "?folder_id=$parent_id"

