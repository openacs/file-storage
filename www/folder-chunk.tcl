# file-storage/www/folder-chunk.tcl

ad_page_contract {
    @author yon (yon@openforce.net)
    @creation-date Feb 22, 2002
    @cvs-id $Id$
} -query {
} -properties {
    folder_name:onevalue
    contents:multirow
}

if {![exists_and_not_null folder_id]} {
    ad_return_complaint 1 [_ file-storage.lt_bad_folder_id_folder_]
    ad_script_abort
}

if {![exists_and_not_null viewing_user_id]} {
    set viewing_user_id [acs_magic_object "the_public"]
}

permission::require_permission -party_id $viewing_user_id -object_id $folder_id -privilege "read"

if {![exists_and_not_null n_past_days]} {
    set n_past_days 99999
}

if {![exists_and_not_null fs_url]} {
    set fs_url ""
}

set folder_name [fs::get_object_name -object_id  $folder_id]

db_multirow -extend { write_p delete_p admin_p read_p} contents select_folder_contents {} {
    set file_upload_name [fs::remove_special_file_system_characters -string $file_upload_name]
    if { $type == "url" } {
	#url is the only type that uses this in the UI and permission checking is expensive.
	set admin_p [permission::permission_p -party_id $viewing_user_id -object_id $object_id -privilege "admin"]
	if { $admin_p } {
	    set write_p 1
	    set delete_p 1
	    set read_p 1
	} else {
	    set write_p [permission::permission_p -party_id $viewing_user_id -object_id $object_id -privilege "write"]
	    set delete_p [permission::permission_p -party_id $viewing_user_id -object_id $object_id -privilege "delete"]
	    if {!$write_p && !$delete_p} {
		set read_p [permission::permission_p -party_id $viewing_user_id -object_id $object_id -privilege "read"]
	    } else {
		set read_p 1
	    }
	}
    } else {
	set admin_p 0
	set write_p 0
	set delete_p 0
	set read_p 0
    }
}

set rows [fs::get_folder_contents \
    -folder_id $folder_id \
    -user_id $viewing_user_id \
    -n_past_days $n_past_days \
]
template::util::list_of_ns_sets_to_multirow -rows $rows -var_name "contents"

ad_return_template
