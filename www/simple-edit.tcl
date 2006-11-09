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

# Message lookup uses variable pretty_name

ad_form -name simple-edit -form {
    object_id:key
    {name:text {label "#file-storage.Title_#"} {html {size 40} } }
    {url:text {label "#file-storage.URL#"} {html {size 50} } }
    {description:text(textarea),optional {label "#file-storage.Description#" } {html { rows 5 cols 50 } } }
    {folder_id:text(hidden)}
} -edit_request {
    db_1row extlink_data ""
} -edit_data {
    content_extlink::edit -extlink_id $object_id -url $url -label $name -description $description
    ad_returnredirect "?[export_vars folder_id]"
}

set pretty_name "$name"
set context [fs_context_bar_list -final "[_ file-storage.Edit_URL]" $folder_id]
set page_title [_ file-storage.file_edit_page_title_1]

ad_return_template
