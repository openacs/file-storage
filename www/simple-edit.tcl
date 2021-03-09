ad_page_contract {
    page to edit a new nonversioned object

    @author Ben Adida
    @creation-date 01 April 2002
    @cvs-id $Id$
} {
    object_id:naturalnum,notnull
}

# check for write permission on the item
permission::require_permission -object_id $object_id -privilege write

# Message lookup uses variable pretty_name

ad_form -name simple-edit -form {
    object_id:key
    {name:text
        {label "#file-storage.Title_#"}
        {html {size 40} }
    }
    {url:text(url)
        {label "#file-storage.URL#"}
        {html {size 50} }
    }
    {description:text(textarea),optional
        {label "#file-storage.Description#" }
        {html { rows 5 cols 50 } }
    }
    {folder_id:text(hidden)}
}

set package_id [ad_conn package_id]
if { [parameter::get \
        -parameter CategoriesP \
        -package_id $package_id -default 0]
} {
    category::ad_form::add_widgets \
        -container_object_id $package_id \
        -categorized_object_id $object_id \
        -form_name simple-edit
}

ad_form -extend -edit_request {
    db_1row extlink_data ""
} -edit_data {
    content::extlink::edit \
        -extlink_id $object_id \
        -url $url \
        -label $name \
        -description $description
    if { [parameter::get \
            -parameter CategoriesP \
            -package_id $package_id \
            -default 0]
} {
    category::map_object \
        -remove_old \
        -object_id $object_id \
        [category::ad_form::get_categories \
            -container_object_id $package_id \
            -element_name category_id]
    }
    ad_returnredirect [export_vars -base . folder_id]
    ad_script_abort
}

set pretty_name "$name"
set context [fs_context_bar_list -final "[_ file-storage.Edit_URL]" $folder_id]
set page_title [_ file-storage.file_edit_page_title_1]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
