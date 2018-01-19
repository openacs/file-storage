ad_page_contract {
    page to confirm and delete a simple fs object

    @author Ben Adida (ben@openforce.net)
    @creation-date 10 Nov 2000
    @cvs-id $Id$
} {
    object_id:naturalnum,notnull
    folder_id:naturalnum,notnull
}

# check for delete permission on the file
permission::require_permission -object_id $object_id -privilege delete

# Delete

db_transaction {

    fs::do_notifications -folder_id $folder_id -filename [content::extlink::name -item_id $object_id] -item_id $object_id -action "delete_url"
    
    fs::delete_file \
        -item_id $object_id \
        -parent_id $folder_id

}


ad_returnredirect "./?folder_id=$folder_id"
ad_script_abort


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
