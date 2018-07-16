ad_page_contract {
    Front page for file-storage.  Lists subfolders and file in the 
    folder specified (top level if none is specified).

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    {folder_id:naturalnum,notnull [fs_get_root_folder]}
    {n_past_days:integer "99999"}
    {orderby:token,notnull,optional}
    {category_id:naturalnum,notnull ""}
    {return_url:localurl ""}
} -validate {
    valid_folder -requires {folder_id:integer} {
	if {![fs_folder_p $folder_id]} {
	    ad_complain "[_ file-storage.lt_The_specified_folder__1]"
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
    context:onevalue
}

# Don't allow delete if root folder
set root_folder_p 0
set root_folder_id [fs_get_root_folder]
if {$folder_id == $root_folder_id} {
    set root_folder_p 1
}

# set templating datasources
set folder_name [fs_get_folder_name $folder_id]

# set user_id [ad_conn user_id]
# permission::require_permission -party_id $user_id -object_id $folder_id -privilege "read"

set write_p [permission::permission_p -object_id $folder_id -privilege write]
set admin_p [permission::permission_p -object_id $folder_id -privilege admin]

# might want a more complicated check here, since a person might have
# delete permission on the folder, but not on some child items and,
# thus, not be able to actually delete it.  We check this later, but
# sometime present a link that they won't be able to use.

set delete_p $admin_p
if {!$delete_p} {
    set delete_p [permission::permission_p -object_id $folder_id -privilege delete]
}

set package_id [ad_conn package_id]
set show_administer_permissions_link_p [parameter::get -package_id $package_id -parameter "ShowAdministerPermissionsLinkP" -default 1]

set n_contents [fs::get_folder_contents_count -folder_id $folder_id]

set folder_url [export_vars -base [ad_conn url] {folder_id}]
set context [fs_context_bar_list -root_folder_id $root_folder_id $folder_id]

# Try to find a linked project so you can display a back link.
# This should become a callback in the long run. 
# For now I leave it in as it is.

set project_item_id [application_data_link::get_linked -from_object_id $folder_id -to_object_type "content_item"]
if {$project_item_id ne ""} {
    set project_url [pm::project::url -project_item_id $project_item_id]
    set project_name [pm::project::name -project_item_id $project_item_id]
} else {

    # The folder itself was not linked. Let's try the parent folder.
    set parent_folder [content::item::get_parent_folder -item_id $folder_id]
    set project_item_id [application_data_link::get_linked -from_object_id $parent_folder -to_object_type "content_item"]
    if {$project_item_id ne ""} {
	set project_url [pm::project::url -project_item_id $project_item_id]
	set project_name [pm::project::name -project_item_id $project_item_id]
    } else {
	
	# Neither this folder nor the parent folder was linked. Don't care...
	set project_url {}
    }
}

# Check if the user has permissions. If not, don't care
if {$project_item_id ne "" && ![permission::permission_p -object_id $project_item_id -privilege "read"]} {
    set project_url {}
}

set up_url {}
if { !$root_folder_p} {
    if {[llength $context] == 1} {
	set up_url [ad_conn package_url]
	set up_name [ad_conn instance_name]
    } else {
	set up_url [lindex $context end-1 0]
	set up_name [lindex $context end-1 1]
    }
    set up_name [lang::util::localize $up_name]
}

set use_webdav_p  [parameter::get -parameter "UseWebDavP"]

if { $use_webdav_p == 1} { 
    set webdav_url [fs::webdav_url -item_id $folder_id]
    regsub -all {/\$} $webdav_url {/\\$} webdav_url
}

# FIXME make this a parameter!

set allow_bulk_actions 1


ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
