ad_page_contract {
    Front page for file-storage.  Lists subfolders and file in the 
    folder specified (top level if none is specified).

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    {folder_id:integer [fs_get_root_folder]}
} -validate {
    valid_folder -requires {folder_id:integer} {
	if ![fs_folder_p $folder_id] {
	    ad_complain "The specified folder is not valid."
	}
    }
} -properties {
    folder_name:onevalue
    folder_id:onevalue
    nonroot_folder_p:onevalue
    file:multirow
    write_p:onevalue
    admin_p:onevalue
    delete_p:onevalue
    context_bar:onevalue
}

# Don't allow delete if root folder
set nonroot_folder_p [expr $folder_id - [fs_get_root_folder]]

# check the user has permission to read this folder
ad_require_permission $folder_id read

# set templating datasources
set folder_name [fs_get_folder_name $folder_id]
set context_bar [fs_context_bar_list $folder_id]

set user_id [ad_conn user_id]
set write_p [ad_permission_p $folder_id write]
set admin_p [ad_permission_p $folder_id admin]

# might want a more complicated check here, since a person might have
# delete permission on the folder, but not on some child items and,
# thus, not be able to actually delete it.  We check this later, but
# sometime present a link that they won't be able to use.

set delete_p [ad_permission_p $folder_id delete]

set package_id [ad_conn package_id]

set n_contents [fs::get_folder_contents_count -folder_id $folder_id -user_id $user_id]

ad_return_template
