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
set blocked_p [expr {![children_have_permission_p $folder_id delete]}]

set folder_name [db_string folder_name {}]
set child_count [db_string child_count {}]

# TODO add child_count to message key

# Message lookup uses variable folder_name
set page_title [_ file-storage.folder_delete_page_title]
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
        # they have confirmed that they want to delete the folder
        set parent_id [db_string parent_id {}]
        fs::delete_folder \
            -parent_id $parent_id \
            -folder_id $folder_id

        ad_returnredirect "index?folder_id=$parent_id"
        ad_script_abort
    } -export {folder_id}
   

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
