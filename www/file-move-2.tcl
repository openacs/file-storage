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
	    ad_complain "[_ file-storage.lt_The_specified_file_is]"
	}
    }

    valid_folder -requires {parent_id} {
	if ![fs_folder_p $parent_id] {
	    ad_complain "[_ file-storage.lt_The_specified_parent_]"
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

    ad_return_complaint 1 "[_ file-storage.lt_We_received_an_error_]

    <pre>$errmsg</pre>"

    ad_script_abort
}

ad_returnredirect "?folder_id=$parent_id"
