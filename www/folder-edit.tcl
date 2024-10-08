ad_page_contract {
    form to edit a folder

    @author Andrew Grumet (aegrumet@alum.mit.edu)
    @creation-date 24 Jun 2002
    @cvs-id $Id$
} {
    folder_id:naturalnum,notnull
} -validate {
    valid_folder -requires {parent_id:integer} {
	if {![fs_folder_p $folder_id]} {
	    ad_complain "[_ file-storage.lt_The_specified_folder_]"
	}
    }
} -properties {
    folder_id:onevalue
    context_bar:onevalue
}

permission::require_permission -object_id $folder_id -privilege admin

# set templating datasources

set context_bar [fs_context_bar_list -final "[_ file-storage.Edit]" $folder_id]

set submit_label [_ file-storage.Save]

ad_form -export folder_id -form {
    {folder_name:text(text)
        {label "\#file-storage.Folder_Name\#"}
	{maxlength 1000}
    }
    {description:text(textarea),optional
        {label \#file-storage.Description\#}
        {html "rows 5 cols 35"}
    }
}


set package_id [ad_conn package_id]
if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
    category::ad_form::add_widgets \
	 -container_object_id $package_id \
	 -categorized_object_id $folder_id \
	 -form_name folder-edit
}


ad_form -extend -form {
    {submit:text(submit) {label $submit_label}}
} -on_request {
    content::item::get -item_id $folder_id -array folder
    set folder_name $folder(label)
    set description $folder(description)
} -on_submit {

    set name [ad_sanitize_filename -collapse_spaces $folder_name]

    # 'folder_name' itself cannot be null, but the sanitized 'name'
    # might be, if 'folder_name' is made only of invalid
    # characters. We complain in such case, as we need some kind of
    # valid name to be there.
    if {[string length $name] == 0} {
        template::form::set_error folder-edit folder_name \
            [_ acs-tcl.lt_name_contains_invalid [list name [_ file-storage.Title]]]
        break
    }

    db_transaction {
        content::folder::update -folder_id $folder_id \
            -attributes [list \
                             [list name $name] \
                             [list label $folder_name] \
                             [list description $description]]

        if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
            category::map_object -remove_old -object_id $folder_id [category::ad_form::get_categories \
                                                                        -container_object_id $package_id \
                                                                        -element_name category_id]
        }

        callback fs::folder_edit -package_id [ad_conn package_id] -folder_id $folder_id
    }

} -after_submit {
    ad_returnredirect "?folder_id=$folder_id"
    ad_script_abort
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
