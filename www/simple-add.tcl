ad_page_contract {
    page to add a new nonversioned object to the system

    @author Ben Adida (ben@openforce)    
    @author arjun (arjun@openforce)
    @creation-date 01 April 2002
    @cvs-id $Id$
} {
    folder_id:integer,notnull
    {type "fs_url"}
    {title ""}
    {lock_title_p 0}
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

set pretty_name [fs::simple_get_type_pretty_name -type $type]
if {[empty_string_p $pretty_name]} {
    return -code error "No such type"
}

set context_bar [fs_context_bar_list -final "Add $pretty_name" $folder_id]

# Should probably generate the item_id and version_id now for
# double-click protection


# if title isn't passed in ignore lock_title_p
if {[empty_string_p $title]} {
    set lock_title_p 0
}

