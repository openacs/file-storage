ad_page_contract {
    form to edit a folder

    @author Andrew Grumet (aegrumet@alum.mit.edu)
    @creation-date 24 Jun 2002
    @cvs-id $Id$
} {
    folder_id:integer,notnull
} -validate {
    valid_folder -requires {parent_id:integer} {
	if ![fs_folder_p $folder_id] {
	    ad_complain "[_ file-storage.lt_The_specified_folder_]"
	}
    }
} -properties {
    folder_id:onevalue
    context_bar:onevalue
}

ad_require_permission $folder_id admin

# set templating datasources

set context_bar [fs_context_bar_list -final "[_ file-storage.Edit]" $folder_id]

set folder_name [fs_get_folder_name $folder_id]

ad_return_template
