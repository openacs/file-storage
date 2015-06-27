# shows a list of links from a file-storage folder. 

# @param base_url URL to prepend to the relative URL from file-storage
#                 used to deliver content from another index.vuh than
#                 file-storage/view/ 
if {(![info exists base_url] || $base_url eq "")} {
    set base_url "/view/"
}
# @param object_list restrict results to object_ids in object_list
if {(![info exists object_list] || $object_list eq "")} {
    set object_list {}
}
# @param show_all_p include subfolders and contents? default 0
if {(![info exists show_all_p] || $show_all_p eq "")} {
    set show_all_p 0
}
# @param admin_p show links to properties page for a file? default 0
if {(![info exists admin_p] || $admin_p eq "")} {
    set admin_p 0
}
# @param return_url URL to add to admin links
if {(![info exists return_url] || $return_url eq "")} {
    set return_url [ad_return_url]
}

if {$show_all_p} {
    set parent_context_where [db_map parent_context_all] 
} else {
    set parent_context_where " fs_objects.parent_id = :folder_id"
}

set object_list_where ""

set viewing_user_id [ad_conn user_id]
set permission_clause " and exists (select 1
                   from acs_object_party_privilege_map m
                   where m.object_id = fs_objects.object_id
                     and m.party_id = :viewing_user_id
                     and m.privilege = 'read')"
if {[info exists permission_check] && $permission_check eq 0 } {
    set permission_p 1
    set permission_clause ""
} else {
    set permission_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "read"]
}


set folder_name [lang::util::localize [fs::get_object_name -object_id  $folder_id]]

lassign [fs::get_folder_package_and_root $folder_id]  package_id root_folder_id 
    set fs_url [site_node::get_url_from_object_id -object_id $package_id]
    if {$root_folder_id ne $folder_id && "/view/" eq $base_url} {
	set folder_path [db_exec_plsql get_folder_path {}]
    } else {
	set folder_path ""
    }

    if {[llength $object_list]} {
	set object_list_where " and fs_objects.object_id in ([join $object_list ", "])"
    }

    db_multirow -extend { edit_url icon last_modified_pretty content_size_pretty properties_link properties_url download_url target_tag } contents select_folder_contents {} {
	set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]
	
	set last_modified_pretty [lc_time_fmt $last_modified_ansi "%x %X"]
	#    if {$description ne ""} {
	#	set description " - $description"
	#    }
	
	if {$type eq "folder"} {
	    set content_size_pretty [lc_numeric $content_size]
	    append content_size_pretty " [_ file-storage.items]"
	    set pretty_type "Folder"
	} else {
	    if {$content_size < 1024} {
		set content_size_pretty "[lc_numeric $content_size] [_ file-storage.bytes]"
	    } else {
		set content_size_pretty "[lc_numeric [expr {$content_size / 1024 }]] [_ file-storage.kb]"
	    }

	}

	set file_upload_name [fs::remove_special_file_system_characters -string $file_upload_name]

	set name [lang::util::localize $name]

	if {![info exists download_base_url] } {
	    set download_base_url ""
	}
	switch -- $type {
	    folder {
		set properties_link ""
		set properties_url ""
		set icon ""
		set file_url ""
		set download_url ""
	    }
	    url {
		set properties_link "properties"
		set properties_url [export_vars -base ${fs_url}simple {object_id return_url}]
		set icon "/resources/acs-subsite/url-button.gif"
		set file_url ${url}
		set download_url $file_url
	    }
	    default {

		set properties_link [_ file-storage.properties]
		set properties_url [export_vars -base ${fs_url}file {{file_id $object_id} return_url}]
		set icon "/resources/file-storage/file.gif"
		set file_url "${base_url}${file_url}"
		set download_url [export_vars -base ${fs_url}download {{file_id $object_id}}]
	    }
	}


	# We need to encode the hashes in any i18n message keys (.LRN plays this trick on some of its folders).
	# If we don't, the hashes will cause the path to be chopped off (by ns_conn url) at the leftmost hash.
	regsub -all {\#} $file_url {%23} file_url
    }

    ad_return_template
