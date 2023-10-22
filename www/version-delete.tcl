ad_page_contract {
    confirmation page for version deletion

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 10 November 2000
    @cvs-id $Id$
} {
    version_id:naturalnum,notnull
    {confirmed_p:boolean,notnull "f"}
} -validate {
    valid_version -requires {version_id} {
        if {![fs_version_p $version_id]} {
            ad_complain [_ file-storage.lt_version_not_valid]
        }
    }
} -properties {
    version_id:onevalue
    version_name:onevalue
    title:onevalue
    context:onevalue
}

# check for delete permission on the version

permission::require_permission -object_id $version_id -privilege delete

db_1row version_info {
    select i.item_id,
           i.parent_id,
           i.name as title,    
           r.title as version_name
    from cr_items i,cr_revisions r
    where i.item_id = r.item_id
    and revision_id = :version_id
}

set context [fs_context_bar_list -final [_ file-storage.Delete_Version] $item_id]

set delete_message [_ file-storage.lt_Are_you_sure_that_you]
set file_url [export_vars -base file {{file_id $item_id}}]

ad_form -export version_id -cancel_url $file_url -form {
    {delete_message:text(inform) {label ""} {value $delete_message}}
} -on_submit {

    set parent_id [fs::delete_version \
                       -item_id $item_id \
                       -version_id $version_id]
    # parent_id > 0 means this was last revision left, therefore, file
    # was deleted as well. Return to the parent instead than to the
    # non-existing file.
    set return_url [expr {$parent_id == 0 ?
                          $file_url :
                          [export_vars -base index {{folder_id $parent_id}}]}]
    
    ad_returnredirect $return_url
    ad_script_abort
}

# Message lookup uses variable version_name
set page_title [_ file-storage.version_delete_page_title]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
