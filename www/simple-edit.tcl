ad_page_contract {
    page to edit a new nonversioned object

    @author Ben Adida
    @creation-date 01 April 2002
    @cvs-id $Id$
} {
    object_id:notnull
}

# check for write permission on the item
ad_require_permission $object_id write

# Load up some data
db_1row select_item_info "select name, url, description, folder_id from fs_urls_full where url_id= :object_id"

set pretty_name "$name"
set context [fs_context_bar_list -final "[_ file-storage.Edit_URL]" $folder_id]

ad_return_template

