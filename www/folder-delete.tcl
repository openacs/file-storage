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
#
# Check for delete permission on the folder.
#

permission::require_permission -object_id $folder_id -privilege delete

# Check if there are child items they don't have permission to delete
# (Irrelevant at this point because they can't delete folders with
# contents at all.)
set blocked_p [expr {![children_have_permission_p $folder_id delete]}]

# Message lookup uses variables folder_name and child_count
set folder_name [lang::util::localize [fs_get_folder_name $folder_id]]
set child_count [fs::get_folder_contents_count -folder_id $folder_id]

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
        #
        # The user has confirmed to delete the folder.
        #
        set parent_id [fs::get_parent -item_id $folder_id]
        fs::delete_folder -folder_id $folder_id

        ad_returnredirect "index?folder_id=$parent_id"
        ad_script_abort
    } -export {folder_id}
   

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
