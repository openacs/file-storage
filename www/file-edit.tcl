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

ad_require_permission $file_id write

db_1row file_info ""

set context [fs_context_bar_list -final "[_ file-storage.Rename]" $file_id]

# Variable title used by message lookup
set page_title [_ file-storage.file_edit_page_title]

set title_help [_ file-storage.lt_Please_enter_the_new_]
set submit_label [_ file-storage.Change_Name]

ad_form -action file-edit-2 -export file_id -form {
    {title:text(text) {help_text $title_help} {label \#file-storage.Name\#}}
    {submit:text(submit) {label $submit_label}}
} -has_submit 1

ad_return_template
