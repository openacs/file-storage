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
	    ad_complain "The specified file is not valid."
	}
    }
}

#check they have write permission on this file

ad_require_permission $file_id write

if [catch {db_exec_plsql rename_file "
begin
    content_item.rename (
        item_id => :file_id,
        name => :title
    );
end;"} errmsg] {

    if [db_string duplicate_check "
    select count(*)
    from   cr_items
    where  name = :name
    and    parent_id = content_item.get_parent_folder(:file_id)"] {
	ad_return_complaint 1 "It appears that there is already a file with that name in this folder (although possibly you clicked more than once on the submit button.)"
    } else {
	ad_return_complaint 1 "We got an error that we couldn't readily identify.  Please let the system owner know about this.

	<pre>$errmsg</pre>"
    }

    ad_script_abort
}

ad_returnredirect "file?file_id=$file_id"
