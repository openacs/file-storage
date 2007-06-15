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
    page_num
}

if {![exists_and_not_null folder_id]} {
    ad_return_complaint 1 [_ file-storage.lt_bad_folder_id_folder_]
    ad_script_abort
}
if {![exists_and_not_null allow_bulk_actions]} {
    set allow_bulk_actions "0"
}
if { ![exists_and_not_null category_id] } {
    set category_id ""
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
    set fs_url [ad_conn package_url]
}

set folder_name [lang::util::localize [fs::get_object_name -object_id  $folder_id]]

set content_size_total 0

if {![exists_and_not_null format]} {
    set format table
}

#AG: We're an include file, and we may be included from outside file-storage.
#So we need to query for the package_id rather than getting it from ad_conn.
set package_and_root [fs::get_folder_package_and_root $folder_id]
set package_id [lindex $package_and_root 0]
if {![exists_and_not_null root_folder_id]} {
    set root_folder_id [lindex $package_and_root 1]
}

if {![string equal $root_folder_id $folder_id]} {
    set folder_path "[db_exec_plsql get_folder_path {}]"
} else {
    set folder_path ""
}

set actions [list]

# for now, invite users to upload, and then they will be asked to
# login if they are not.

set cancel_url "[ad_conn url]?[ad_conn query]"
set add_url [export_vars -base "${fs_url}file-add" {folder_id}]

lappend actions "#file-storage.Add_File#" [export_vars -base "${fs_url}file-upload-confirm" {folder_id cancel_url {return_url $add_url}}] "[_ file-storage.lt_Upload_a_file_in_this]" "#file-storage.Create_a_URL#" ${fs_url}simple-add?[export_vars folder_id] "[_ file-storage.lt_Add_a_link_to_a_web_p]" "#file-storage.New_Folder#" ${fs_url}folder-create?[export_vars {{parent_id $folder_id}}] "#file-storage.Create_a_new_folder#" "[_ file-storage.lt_Upload_compressed_fol]" ${fs_url}folder-zip-add?[export_vars folder_id] "[_ file-storage.lt_Upload_a_compressed_f]"

set expose_rss_p [parameter::get -parameter ExposeRssP -package_id $package_id -default 0]
set like_filesystem_p [parameter::get -parameter BehaveLikeFilesystemP -default 1]

set target_window_name [parameter::get -parameter DownloadTargetWindowName -package_id $package_id -default ""]
if { [string equal $target_window_name ""] } {
    set target_attr ""
} else {
    set target_attr "target=\"$target_window_name\""
}

if {$delete_p} {
    lappend actions "#file-storage.Delete_this_folder#" ${fs_url}folder-delete?[export_vars folder_id] "#file-storage.Delete_this_folder#"
}
if {$admin_p} {
    lappend actions "#file-storage.Edit_Folder#" "${fs_url}folder-edit?folder_id=$folder_id" "#file-storage.Rename_this_folder#"
    lappend actions "#file-storage.lt_Modify_permissions_on_1#" "${fs_url}permissions?[export_vars -override {{object_id $folder_id}} {{return_url "[ad_conn url]"}}]" "#file-storage.lt_Modify_permissions_on_1#"
    if { $expose_rss_p } {
	lappend actions "Configure RSS" "${fs_url}admin/rss-subscrs?folder_id=$folder_id" "Configure RSS"
    }
}
set categories_p [parameter::get -parameter CategoriesP -package_id $package_id -default 0]
if { $categories_p } {
    if { [permission::permission_p -party_id $viewing_user_id -object_id $package_id -privilege "admin"] } {
	lappend actions [_ categories.cadmin] [export_vars -base "/categories/cadmin/object-map" -url {{object_id $package_id}}] [_ categories.cadmin]
    }
    set category_links [fs::category_links -object_id $folder_id -folder_id $folder_id -selected_category_id $category_id -fs_url $fs_url]
}

#set n_past_filter_values [list [list "Yesterday" 1] [list [_ file-storage.last_week] 7] [list [_ file-storage.last_month] 30]]
set elements [list type [list label [_ file-storage.Type] \
                             display_template {<img src="@contents.icon@"  border=0 alt="@contents.alt_icon@" />@contents.pretty_type@} \
			    orderby_desc {sort_key_desc,fs_objects.pretty_type desc} \
			    orderby_asc {fs_objects.sort_key, fs_objects.pretty_type asc}] \
                  name \
		  [list label [_ file-storage.Name] \
                       display_template {<a @target_attr@ href="@contents.file_url@" title="\#file-storage.view_contents\#"><if @contents.title@ nil>@contents.name@</a></if><else>@contents.title@</a><br/><if @contents.name@ ne @contents.title@><span style="color: \#999;">@contents.name@</span></if></else>} \
		       orderby_desc {fs_objects.name desc} \
		       orderby_asc {fs_objects.name asc}] \
 		  short_name \
 		  [list label [_ file-storage.Name] \
                        hide_p 1 \
 		       display_template {<a href="@contents.download_url@" title="\#file-storage.Download\#">@contents.title@</a>} \
 		       orderby_desc {fs_objects.name desc} \
 		       orderby_asc {fs_objects.name asc}] \
		  content_size_pretty \
		  [list label [_ file-storage.Size] \
 		       display_template {@contents.content_size_pretty;noquote@} \
		       orderby_desc {content_size desc} \
		       orderby_asc {content_size asc}] \
		  last_modified_pretty \
		  [list label [_ file-storage.Last_Modified] \
		       orderby_desc {last_modified_ansi desc} \
		       orderby_asc {last_modified_ansi asc}] \
		  properties_link \
		  [list label "" \
		       link_url_col properties_url \
		       link_html { title "[_ file-storage.properties]" }] \
                  new_version_link \
		  [list label "" \
		       link_url_col new_version_url \
		       link_html { title "[_ file-storage.Upload_a_new_version]" }] \
                  download_link \
		  [list label "" \
		       link_url_col download_url \
		       link_html { title "[_ file-storage.Download]" }] \
		  ]


if { $categories_p } {
    lappend elements categories [list label [_ file-storage.Categories] display_col "categories;noquote"]
}
lappend elements views [list label "Views" ]



if {[apm_package_installed_p views]} {
    concat $elements [list views [list label "Views"]]
}

if {![exists_and_not_null return_url]} {
    set return_url [export_vars -base "index" {folder_id}]
}
set vars_to_export [list return_url]

if {$allow_bulk_actions} {
    set bulk_actions [list "[_ file-storage.Move]" "${fs_url}move" "[_ file-storage.lt_Move_Checked_Items_to]" "[_ file-storage.Copy]" "${fs_url}copy" "[_ file-storage.lt_Copy_Checked_Items_to]" "[_ file-storage.Delete]" "${fs_url}delete" "[_ file-storage.Delete_Checked_Items]" "[_ file-storage.Download_ZIP]" "${fs_url}download-zip" "[_ file-storage.Download_ZIP_Checked_Items]"]
    callback fs::folder_chunk::add_bulk_actions \
	-bulk_variable "bulk_actions" \
	-folder_id $folder_id \
	-var_export_list "vars_to_export"
} else {
    set bulk_actions ""
}

if {$format eq "list"} { 
    set actions {}
} 

template::list::create \
    -name contents \
    -multirow contents \
    -key object_id \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars $vars_to_export \
    -selected_format $format \
    -formats {
        table {
            label Table
            layout table
        }
        list {
            label List
            layout list
            template {
              <listelement name="short_name"> - <listelement name="last_modified_pretty">  
            }
        }
    } \
    -pass_properties [list target_attr] \
    -filters {
	folder_id {hide_p 1}
	page_num
    } \
    -elements $elements

set orderby [template::list::orderby_clause -orderby -name contents]

if {[string equal $orderby ""]} {
    set orderby " order by fs_objects.sort_key, fs_objects.name asc"
}

if { $categories_p && [exists_and_not_null category_id] } {
    set categories_limitation [db_map categories_limitation]
    set categories_limitation " and fs_objects.object_id in ( select object_id from category_object_map where category_id = $category_id )"
} else {
    set categories_limitation {}
}

db_multirow -extend {label alt_icon icon last_modified_pretty content_size_pretty properties_link properties_url download_link download_url new_version_link new_version_url views categories} contents select_folder_contents {} {
    set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]
    
    set last_modified_pretty [lc_time_fmt $last_modified_ansi "%x %X"]
    if {[string equal $type "folder"]} {
        set content_size_pretty [lc_numeric $content_size]
	append content_size_pretty "&nbsp;[_ file-storage.items]"
	set pretty_type "#file-storage.Folder#"
    } else {
	if {$content_size < 1024} {
	    set content_size_pretty "[lc_numeric $content_size]&nbsp;[_ file-storage.bytes]"
	} else {
	    set content_size_pretty "[lc_numeric [expr $content_size / 1024 ]]&nbsp;[_ file-storage.kb]"
	}

    }

    set file_upload_name [fs::remove_special_file_system_characters -string $file_upload_name]

    if { ![empty_string_p $content_size] } {
        incr content_size_total $content_size
    }

    set views ""
    if {[apm_package_installed_p views]} {
	array set views_arr [views::get -object_id $object_id] 
	if {$views_arr(views) ne ""} {
	    set views " $views_arr(views) / $views_arr(unique_views)"
	}
    }

    set name [lang::util::localize $name]
    switch -- $type {
	folder {
	    set properties_link ""
	    set properties_url ""
	    set new_version_link {}
	    set new_version_url {}
	    set icon "/resources/file-storage/folder.gif"
	    set alt_icon #file-storage.folder#
	    set file_url "${fs_url}index?[export_vars {{folder_id $object_id}}]"
	    set download_link [_ file-storage.Download]
            set download_url "[export_vars -base "${fs_url}download-zip" -url {object_id}]"
	}
	url {
	    set properties_link [_ file-storage.properties]
	    set properties_url "${fs_url}simple?[export_vars object_id]"
	    set new_version_link [_ acs-kernel.common_New]
	    set new_version_url "${fs_url}file-add?[export_vars {{file_id $object_id}}]"
	    set icon "/resources/acs-subsite/url-button.gif"
	    # DRB: This alt text somewhat sucks, but the message key already exists in
	    # the language catalog files we care most about and we want to avoid a new
	    # round of translation work for this minor release if possible ...
	    set alt_icon #file-storage.link#
	    set file_url ${url}
            set download_url {}
	    set download_link {}
	    
	}
	symlink {
	    # save the original object_id to set it later back (see below)
	    set original_object_id $object_id
	    set properties_link [_ file-storage.properties]
	    set target_object_id [content::symlink::resolve -item_id $object_id]
	    db_1row file_info {select * from fs_objects where object_id = :target_object_id}
	    # because of the side effect that SQL sets TCL variables, set object_id back to the original value
            set object_id $original_object_id
	    if {[string equal $type "folder"]} {
		set content_size_pretty [lc_numeric $content_size]
		append content_size_pretty "&nbsp;[_ file-storage.items]"
		set pretty_type "#file-storage.Folder#"
	    } else {
		if {$content_size < 1024} {
		    set content_size_pretty "[lc_numeric $content_size]&nbsp;[_ file-storage.bytes]"
		} else {
		    set content_size_pretty "[lc_numeric [expr $content_size / 1024 ]]&nbsp;[_ file-storage.kb]"
		}
		
	    }
	    set properties_url "${fs_url}file?[export_vars {{file_id $object_id}}]"
	    set new_version_link [_ acs-kernel.common_New]
	    set new_version_url "${fs_url}file-add?[export_vars {{file_id $object_id}}]"
	    set icon "/resources/file-storage/file.gif"
	    set alt_icon #file-storage.file#
	    set file_url "${fs_url}view/${file_url}"
	    set download_link [_ file-storage.Download]
	    if {$like_filesystem_p} {
		set download_url "${fs_url}download/$title?[export_vars {{file_id $target_object_id}}]"                
		set file_url $download_url
	    } else {
		set download_url "${fs_url}download/$name?[export_vars {{file_id $target_object_id}}]"                
	    }
	}
	default {
	    set properties_link [_ file-storage.properties]
	    set properties_url "${fs_url}file?[export_vars {{file_id $object_id}}]"
	    set new_version_link [_ acs-kernel.common_New]
	    set new_version_url "${fs_url}file-add?[export_vars {{file_id $object_id}}]"
	    set icon "/resources/file-storage/file.gif"
	    set alt_icon "#file-storage.file#"
	    set file_url "${fs_url}view/${file_url}"
	    set download_link [_ file-storage.Download]
	    if {$like_filesystem_p} {
		set file_url "${fs_url}download/$title?[export_vars {{file_id $object_id}}]"                
		set download_url "/file/$object_id/${title}[file extension $name]"
	    } else {
		set download_url "/file/$object_id/$name"
	    }
	}

    }
    if { $categories_p } {
	if { $type eq "folder" } {
	    set cat_folder_id $object_id
	} else {
	    set cat_folder_id $folder_id
	}
	set categories [fs::category_links -object_id $object_id -folder_id $cat_folder_id -selected_category_id $category_id -fs_url $fs_url -joinwith "<br />"]
    }

    # We need to encode the hashes in any i18n message keys (.LRN plays this trick on some of its folders).
    # If we don't, the hashes will cause the path to be chopped off (by ns_conn url) at the leftmost hash.
    regsub -all \# $file_url {%23} file_url
}

if { $expose_rss_p } {
    db_multirow feeds select_subscrs {}
}

if {$format eq "list"} {
    set content_size_total 0
}

if { $expose_rss_p } {
    db_multirow feeds select_subscrs {}
}

if {$content_size_total > 0} {
    set compressed_url [export_vars -base "${fs_url}download-zip" -url {{object_id $folder_id}}]
}
ad_return_template
