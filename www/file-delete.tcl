ad_page_contract {
    page to confirm and delete a file

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 10 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
    {confirmed_p "f"}
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
	    ad_complain "[_ file-storage.lt_The_specified_file_is]"
	}
    }
} -properties {
    file_id:onevalue
    file_name:onevalue
    blocked_p:onevalue
    context:onevalue
}

# check for delete permission on the file

ad_require_permission $file_id delete

# check the file doesn't have any revisions that the user
# doesn't have permission to delete

set user_id [ad_conn user_id]

set blocked_p [ad_decode [db_string blockers "
select count(*) 
from   cr_revisions
where  item_id = :file_id
and    acs_permission.permission_p(revision_id,:user_id,'delete') = 'f'"] 0 f t]
    db_1row file_name "
    	select name as title
    	from   cr_items
    	where  item_id = :file_id"

set delete_message "[_ file-storage.lt_delete_file]"
ad_form -export file_id -cancel_url "file?[export_vars file_id]" -form {
    {delete_message:text(inform) {label $delete_message}}
    } -on_submit {	

if {[string equal $blocked_p "f"] } {
    # they confirmed that they want to delete the file
    set parent_id [fs::get_parent -item_id $file_id]
    fs::delete_file -item_id $file_id -parent_id $parent_id

    ad_returnredirect "?folder_id=$parent_id"

    ad_script_abort
}
}
# DAVEB TODO move this into select_query
    set context [fs_context_bar_list -final "[_ file-storage.Delete]" $file_id]
# Variable title used by message lookup
set page_title [_ file-storage.file_delete_page_title]
