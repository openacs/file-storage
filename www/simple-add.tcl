ad_page_contract {
    page to add a new nonversioned object to the system

    @author Ben Adida (ben@openforce.net)    
    @author arjun (arjun@openforce.net)
    @creation-date 01 April 2002
    @cvs-id $Id$
} {
    folder_id:integer,notnull
    {title ""}
    {lock_title_p 0}
} -validate {
    valid_folder -requires {folder_id:integer} {
	if ![fs_folder_p $folder_id] {
	    ad_complain "[_ file-storage.lt_The_specified_parent_]"
	}
    }
} -properties {
    folder_id:onevalue
    context:onevalue
}

# check for write permission on the folder

ad_require_permission $folder_id write

# set templating datasources

set pretty_name [fs::simple_get_type_pretty_name -type $type]
if {[empty_string_p $pretty_name]} {
    return -code error "[_ file-storage.No_such_type]"
}

set context [fs_context_bar_list -final [_ file-storage.Add_pretty_name [list pretty_name $pretty_name]] $folder_id]

# Should probably generate the item_id and version_id now for
# double-click protection

# if title isn't passed in ignore lock_title_p
if {[empty_string_p $title]} {
    set lock_title_p 0
}
