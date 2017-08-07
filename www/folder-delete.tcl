ad_page_contract {
    page to confirm and delete folder.  At the moment only works
    for empty folders, but ultimately should allow recursive deletes.

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 10 November 2000
    @cvs-id $Id$
} {
    folder_id:naturalnum,notnull
    {confirmed_p:boolean "f"}
} -validate {
    valid_folder -requires {folder_id:integer} {
	if {![fs_folder_p $folder_id]} {
	    ad_complain "[_ file-storage.lt_The_specified_folder__1]"
	}
    }
} -validate {
    not_root_folder -requires {folder_id} {
	if { $folder_id == [fs_get_root_folder] } {
	    ad_complain "[_ file-storage.lt_You_may_not_delete_th]"
	}
    }

} -properties {
    folder_id:onevalue
    folder_name:onevalue
    blocked_p:onevalue
    context:onevalue
}

# check for delete permission on the folder

permission::require_permission -object_id $folder_id -privilege delete

# Check if there are child items they don't have permission to delete
# (Irrelevant at this point because they can't delete folders with
# contents at all.)
set blocked_p [ad_decode [children_have_permission_p $folder_id delete] 0 t f]

set folder_name [db_string folder_name {}]
set child_count [db_string child_count {}]

# TODO add child_count to message key

set context [fs_context_bar_list -final "[_ file-storage.Delete]" $folder_id]
    
set delete_message "[_ file-storage.delete_folder_and_children]"
set delete_label "[_ acs-kernel.common_OK]"

set edit_buttons [list [list $delete_label ok]]

ad_form -name "folder-delete" \
    -edit_buttons $edit_buttons \
    -cancel_url [export_vars -base "index" {folder_id}] \
    -form {
	{delete_message:text(inform) {label ""} {value $delete_message}}
    } -on_request {

    } -on_submit {
	if {$blocked_p == "f"} {
	    # they have confirmed that they want to delete the folder
	    
	    callback fs::folder_delete -package_id [ad_conn package_id] -folder_id $folder_id
	    db_1row parent_id "select parent_id from cr_items where item_id = :folder_id"
    	    
	    db_exec_plsql folder_delete ""
	}
	
	ad_returnredirect "index?folder_id=$parent_id"
	ad_script_abort
    } \
    -export {folder_id}
   

if { $confirmed_p == "t" && $blocked_p == "f" } {
    # they have confirmed that they want to delete the folder

    db_1row parent_id "
    select parent_id from cr_items where item_id = :folder_id"

    db_exec_plsql folder_delete ""

    ad_returnredirect "index?folder_id=$parent_id"
    ad_script_abort

} else {
    # they still need to confirm

    set folder_name [db_string folder_name {
        select label from cr_folders where folder_id = :folder_id
    }]
    set child_count [db_string child_count {
        select count(ci.item_id) from
        (select item_id from cr_items connect by prior item_id=parent_id start with item_id=:folder_id) ci
    }]
    set context [fs_context_bar_list -final "[_ file-storage.Delete]" $folder_id]
}

# Message lookup uses variable folder_name
set page_title [_ file-storage.folder_delete_page_title]
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
