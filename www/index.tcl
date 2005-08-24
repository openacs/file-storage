ad_page_contract {
    Front page for file-storage.  Lists subfolders and file in the 
    folder specified (top level if none is specified).

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    {folder_id:integer [fs_get_root_folder]}
    {n_past_days:integer "99999"}
    {orderby:optional}
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

set user_id [ad_conn user_id]
#permission::require_permission \
    -party_id $user_id \
    -object_id $folder_id \
    -privilege "read"

set write_p [ad_permission_p $folder_id write]
set admin_p [ad_permission_p $folder_id admin]

# might want a more complicated check here, since a person might have
# delete permission on the folder, but not on some child items and,
# thus, not be able to actually delete it.  We check this later, but
# sometime present a link that they won't be able to use.

set delete_p $admin_p
if {!$delete_p} {
    set delete_p [ad_permission_p $folder_id delete]
}

set package_id [ad_conn package_id]

set show_administer_permissions_link_p [ad_parameter -package_id $package_id "ShowAdministerPermissionsLinkP"]
set n_contents [fs::get_folder_contents_count -folder_id $folder_id -user_id $user_id]

form create n_past_days_form

set options {{0 -1} {1 1} {2 2} {3 3} {7 7} {14 14} {30 30}}
element create n_past_days_form n_past_days \
    -label "" \
    -datatype text \
    -widget select \
    -options $options \
    -html {onChange document.n_past_days_form.submit()} \
    -value $n_past_days

element create n_past_days_form folder_id \
    -label "[_ file-storage.Folder_ID]" \
    -datatype text \
    -widget hidden \
    -value $folder_id


set notification_chunk [notification::display::request_widget \
    -type fs_fs_notif \
    -object_id $folder_id \
    -pretty_name $folder_name \
    -url [ad_conn url]?folder_id=$folder_id \
]

if {[form is_valid n_past_days_form]} {
    form get_values n_past_days_form n_past_days folder_id
}

set context [fs_context_bar_list -root_folder_id $root_folder_id $folder_id]

set up_url {}
if { !${root_folder_p}} {
    if {[llength $context] == 1} {
	set up_url [ad_conn package_url]
	set up_name [ad_conn instance_name]
    } else {
	set up_url [lindex [lindex $context end-1] 0]
	set up_name [lindex [lindex $context end-1] 1]
    }
}

set up_name [lang::util::localize $up_name]

set use_webdav_p  [ad_parameter "UseWebDavP"]

if { $use_webdav_p == 1} { 
    set webdav_url [fs::webdav_url -item_id $folder_id]
    regsub -all {/\$} $webdav_url {/\\$} webdav_url
}

# FIXME make this a parameter!

set allow_bulk_actions 1

ad_return_template
