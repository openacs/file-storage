ad_page_contract {
    Page to change the name of a file

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 5 Dec 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
    title:notnull
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
	    ad_complain "[_ file-storage.lt_The_specified_file_is]"
	}
    }
}

#check they have write permission on this file

ad_require_permission $file_id write

if [catch {
    db_dml edit_title ""
} errmsg] {

    if { [db_string duplicate_check {}] } {
	ad_return_complaint 1 "[_ file-storage.lt_It_appears_that_there]"
    } else {
	ad_return_complaint 1 "[_ file-storage.lt_We_got_an_error_that_]

	<pre>$errmsg</pre>"
    }

    ad_script_abort
}

ad_returnredirect "file?file_id=$file_id"
