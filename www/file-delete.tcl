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
	    ad_complain "The specified file is not valid."
	}
    }
} -properties {
    file_id:onevalue
    file_name:onevalue
    blocked_p:onevalue
    context_bar:onevalue
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

if {[string equal $confirmed_p "t"] && [string equal $blocked_p "f"] } {
    # they confirmed that they want to delete the file

    db_1row parent_id "select parent_id from cr_items where item_id = :file_id"

    db_exec_plsql file-delete "
    begin
        content_item.delete(:file_id);
    end;"

    ad_returnredirect "?folder_id=$parent_id"

} else {
    # they need to confirm that they really want to delete the file

    db_1row file_name "
    select title as file_name 
    from   cr_revisions 
    where  revision_id = content_item.get_live_revision(:file_id)"

    set context_bar [fs_context_bar_list -final "Delete" $file_id]

    ad_return_template
}