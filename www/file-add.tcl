ad_page_contract {
    page to add a new file to the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    folder_id:integer,notnull
} -validate {
    valid_folder -requires {folder_id:integer} {
	if ![fs_folder_p $folder_id] {
	    ad_complain "The specified parent folder is not valid."
	}
    }
} -properties {
    folder_id:onevalue
    context_bar:onevalue
}

# check for write permission on the folder

ad_require_permission $folder_id write

# set templating datasources

set context_bar [fs_context_bar_list -final "Add File" $folder_id]

# Should probably generate the item_id and version_id now for
# double-click protection

ad_return_template