ad_page_contract {
    Page to specify a new name for a file

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 5 Dec 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
} -validate {
    valid_file -requires {file_id} {
        if ![fs_file_p $file_id] {
            ad_complain "[_ file-storage.lt_The_specified_file_is]"
        }
    }
} -properties {
    file_id:onevalue
    context:onevalue
    title:onevalue
}


#check they have write permission on this file

permission::require_permission -object_id $file_id -privilege write

set context [fs_context_bar_list -final "[_ file-storage.Rename]" $file_id]

# Variable title used by message lookup
db_1row file_info ""

set page_title [_ file-storage.file_edit_page_title]

set title_help [_ file-storage.lt_Please_enter_the_new_]

ad_form -export file_id -form {
    {title:text(text) 
        {label "[_ file-storage.Title]"}
        {value $title}
        {help_text $title_help} 
    }
}

set package_id [ad_conn package_id]
if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
    category::ad_form::add_widgets \
        -container_object_id $package_id \
        -categorized_object_id $file_id \
        -form_name file-edit
    set submit_label [_ file-storage.Save]
} else {
    set submit_label [_ file-storage.Update]
}

ad_form -extend -form {
    {submit:text(submit) {label $submit_label}}
} -on_submit {
    if [catch {
        db_dml edit_title {}
    } errmsg] {
        if { [db_string duplicate_check {}] } {
            ad_return_complaint 1 "[_ file-storage.lt_It_appears_that_there]"
        } else {
            ad_return_complaint 1 "[_ file-storage.lt_We_got_an_error_that_]

        <pre>$errmsg</pre>"
        }
        ad_script_abort
    }
    if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
        category::map_object \
            -remove_old \
            -object_id $file_id \
            [category::ad_form::get_categories \
                 -container_object_id $package_id \
                 -element_name category_id]
    }
} -after_submit {
    ad_returnredirect "file?file_id=$file_id"
}

ad_return_template
