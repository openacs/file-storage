ad_page_contract {
    page to confirm and delete folder.  At the moment only works
    for empty folders, but ultimately should allow recursive deletes.

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 10 November 2000
    @cvs-id $Id$
} {
    folder_id:integer,notnull
    {confirmed_p "f"}
} -validate {
    valid_folder -requires {folder_id:integer} {
	if ![fs_folder_p $folder_id] {
	    ad_complain "The specified folder is not valid."
	}
    }
} -validate {
    not_root_folder -requires {folder_id} {
	if { $folder_id == [fs_get_root_folder] } {
	    ad_complain "You may not delete the root folder."
	}
    }

    no_children -requires {not_root_folder} {
	if { [db_string child_count "
	select count(*) from cr_items where parent_id = :folder_id"] > 0 } {
	    ad_complain "We're sorry, but at the moment you cannot delete folders unless they are already empty."
	}
    }
} -properties {
    folder_id:onevalue
    folder_name:onevalue
    blocked_p:onevalue
    context:onevalue
}

# check for delete permission on the folder

ad_require_permission $folder_id delete

# Check if there are child items they don't have permission to delete
# (Irrelevant at this point because they can't delete folders with 
# contents at all.)
set blocked_p [ad_decode [children_have_permission_p $folder_id delete] 0 t f]

if { [string equal $confirmed_p "t"] && [string equal $blocked_p "f"] } {
    # they have confirmed that they want to delete the folder

    db_1row parent_id "
    select parent_id from cr_items where item_id = :folder_id"

    db_exec_plsql folder_delete "
    begin
        file_storage.delete_folder(:folder_id);
    end;"

    ad_returnredirect "index?folder_id=$parent_id"

    ad_script_abort

} else {
    # they still need to confirm

    set folder_name [db_string folder_name "
    select label from cr_folders where folder_id = :folder_id"]

    set context [fs_context_bar_list -final "Delete" $folder_id]

}