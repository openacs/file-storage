ad_page_contract {
    page to confirm and delete a simple fs object

    @author Ben Adida (ben@openforce.net)
    @creation-date 10 Nov 2000
    @cvs-id $Id$
} {
    object_id:integer,notnull
    folder_id:notnull
}

# check for delete permission on the file
ad_require_permission $object_id delete

# Delete

db_transaction {

    fs::do_notifications -folder_id $folder_id -filename [content_extlink::extlink_name -item_id $object_id] -url_id $object_id -action "delete_url"

    content_extlink::delete -extlink_id $object_id

}


ad_returnredirect "./?folder_id=$folder_id"

