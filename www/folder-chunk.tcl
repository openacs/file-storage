# file-storage/www/folder-chunk.tcl

ad_page_contract {
    @author yon (yon@openforce.net)
    @creation-date Feb 22, 2002
    @cvs-id $Id$
} -query {
    {orderby:optional}
} -properties {
    folder_name:onevalue
    contents:multirow
    content_size_total:onevalue
}

if {![exists_and_not_null folder_id]} {
    ad_return_complaint 1 [_ file-storage.lt_bad_folder_id_folder_]
    ad_script_abort
}
if {![exists_and_not_null allow_bulk_actions]} {
    set allow_bulk_actions "0"
}

set viewing_user_id [ad_conn user_id]

permission::require_permission -party_id $viewing_user_id -object_id $folder_id -privilege "read"

set admin_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "admin"]

set write_p $admin_p

if {!$write_p} {
    set write_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "write"]
}

set delete_p $admin_p

if {!$delete_p} {
    set delete_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "delete"]
}

if {![exists_and_not_null n_past_days]} {
    set n_past_days 99999
}

if {![exists_and_not_null fs_url]} {
    set fs_url ""
}

set folder_name [lang::util::localize [fs::get_object_name -object_id  $folder_id]]

set content_size_total 0

if {![exists_and_not_null root_folder_id]} {
    set root_folder_id [fs::get_root_folder]
}

if {![string equal $root_folder_id $folder_id]} {
    set folder_path [db_exec_plsql get_folder_path {}]
} else {
    set folder_path ""
}

set actions [list]

# for now, invite users to upload, and then they will be asked to
# login if they are not.

lappend actions "\#file-storage.Add_File\#" ${fs_url}file-add?[export_vars folder_id] "Upload a file in this folder" "\#file-storage.Create_a_URL\#" ${fs_url}simple-add?[export_vars folder_id] "Add a link to a web page" "\#file-storage.New_Folder\#" ${fs_url}folder-create?[export_vars {{parent_id $folder_id}}] "\#file-storage.Create_a_new_folder\#"

set expose_rss_p [parameter::get -parameter ExposeRssP -default 0]

if {$delete_p} {
    lappend actions "\#file-storage.Delete_this_folder\#" ${fs_url}folder-delete?[export_vars folder_id] "\#file-storage.Delete_this_folder\#"
}
if {$admin_p} {
    set return_url [ad_conn url]
    lappend actions "\#file-storage.Edit_Folder\#" "${fs_url}folder-edit?folder_id=$folder_id" "\#file-storage.Rename_this_folder\#"
    lappend actions "\#file-storage.lt_Modify_permissions_on_1\#" "/permissions/one?[export_vars -override {{object_id $folder_id}} {return_url}]" "\#file-storage.lt_Modify_permissions_on_1\#"
    if { $expose_rss_p } {
	lappend actions "Configure RSS" "${fs_url}admin/rss-subscrs?folder_id=$folder_id" "Configure RSS"
    }
}

#set n_past_filter_values [list [list "Yesterday" 1] [list [_ file-storage.last_week] 7] [list [_ file-storage.last_month] 30]]

set elements [list icon \
		  [list label "" \
		       display_template {<a href="@contents.download_url@"><img src="@contents.icon@"  border=0 alt="#file-storage.@contents.pretty_type@#" /></a>}] \
		  name \
		  [list label [_ file-storage.Name] \
                       display_template {<a href="@contents.file_url@"><if @contents.title@ nil>@contents.name@</a></if><else>@contents.title@</a><br/><if @contents.name@ ne @contents.title@><span style="color: \#999;">@contents.name@</span></if></else>} \
		       orderby_desc {fs_objects.name desc} \
		       orderby_asc {fs_objects.name asc}] \
		  content_size_pretty \
		  [list label [_ file-storage.Size] \
		       orderby_desc {content_size desc} \
		       orderby_asc {content_size asc}] \
		  type [list label [_ file-storage.Type] \
			    display_col pretty_type \
			    orderby_desc {(sort_key =  0),pretty_type  desc} \
			    orderby_asc {sort_key, pretty_type asc}] \
		  last_modified_pretty \
		  [list label [_ file-storage.Last_Modified] \
		       orderby_desc {last_modified_ansi desc} \
		       orderby_asc {last_modified_ansi asc}] \
		  properties_link \
		  [list label "" \
		       link_url_col properties_url]
	      ]

if {$allow_bulk_actions} {
    set bulk_actions [list "Move" "move" "Move Checked Items to Another Folder" "Copy" "copy" "Copy Checked Items to Another Folder" "Delete" "delete" "Delete Checked Items"]
} else {
    set bulk_actions ""
}

template::list::create \
    -name contents \
    -multirow contents \
    -key object_id \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -filters {
	folder_id {hide_p 1}
    } \
    -elements $elements

set orderby [template::list::orderby_clause -orderby -name contents]

if {[string equal $orderby ""]} {
    set orderby " order by fs_objects.sort_key, fs_objects.name asc"
}

db_multirow -extend {label icon last_modified_pretty content_size_pretty properties_link properties_url download_url} contents select_folder_contents {} {
    set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]
    
    set last_modified_pretty [lc_time_fmt $last_modified_ansi "%x %X"]
    if {[string equal $type "folder"]} {
        set content_size_pretty [lc_numeric $content_size]
	append content_size_pretty " [_ file-storage.items]"
	set pretty_type "Folder"
    } else {
	if {$content_size < 1024} {
	    set content_size_pretty "[lc_numeric $content_size] [_ file-storage.bytes]"
	} else {
	    set content_size_pretty "[lc_numeric [expr $content_size / 1024 ]] [_ file-storage.kb]"
	}

    }

    set file_upload_name [fs::remove_special_file_system_characters -string $file_upload_name]

    if { ![empty_string_p $content_size] } {
        incr content_size_total $content_size
    }


    set name [lang::util::localize $name]

    switch -- $type {
	folder {
	    set properties_link ""
	    set properties_url ""
	    set icon "/resources/file-storage/folder.gif"
	    set file_url "${fs_url}index?[export_vars {{folder_id $object_id}}]"
            set download_url $file_url
	}
	url {
	    set properties_link [_ file-storage.properties]
	    set properties_url "${fs_url}simple?[export_vars object_id]"
	    set icon "/resources/acs-subsite/url-button.gif"
	    set file_url ${url}
            set download_url $file_url
	}
	default {
	    set properties_link [_ file-storage.properties]
	    set properties_url "${fs_url}file?[export_vars {{file_id $object_id}}]"
	    set icon "/resources/file-storage/file.gif"
	    set file_url "${fs_url}view/${file_url}"
            set download_url "${fs_url}download/?[export_vars {{file_id $object_id}}]"                
	}

    }


    # We need to encode the hashes in any i18n message keys (.LRN plays this trick on some of its folders).
    # If we don't, the hashes will cause the path to be chopped off (by ns_conn url) at the leftmost hash.
    regsub -all {#} $file_url {%23} file_url
}

if { $expose_rss_p } {
    db_multirow feeds select_subscrs {}
}

ad_return_template
