ad_page_contract {
    form to create a new folder

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 7 Nov 2000
    @cvs-id $Id$
} {
    parent_id:integer,notnull
} -validate {
    valid_folder -requires {parent_id:integer} {
	if ![fs_folder_p $parent_id] {
	    ad_complain "The specified parent folder is not valid."
	}
    }
} -properties {
    parent_id:onevalue
    context_bar:onevalue
}

# check that they have write permission on the parent folder

ad_require_permission $parent_id write

# set templating datasources

set context_bar [fs_context_bar_list -final "Create New Folder" $parent_id]

ad_return_template
