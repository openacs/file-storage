ad_page_contract {
    page to display a simple

    @author Jeff Davis davis@xarg.net
    @creation-date 2004-04-27
    @cvs-id $Id$
} {
    object_id:notnull
}

# check for write permission on the item
ad_require_permission $object_id read
set edit_p [permission::permission_p -object_id $object_id -privilege write]

# Load up data 
db_1row select_item_info "select name, url, description, folder_id from fs_urls_full where url_id=:object_id"

set title $name
set pretty_name $name
set context [fs_context_bar_list -final [_ file-storage.link] $folder_id]


