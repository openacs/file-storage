# file-storage/www/folder-chunk.tcl

ad_include_contract {
    @author yon (yon@openforce.net)
    @creation-date Feb 22, 2002
    @cvs-id $Id$
} {
    orderby:token,optional
    {folder_id:integer ""}
    {allow_bulk_actions:boolean true}
    {category_id:integer ""}
    {n_past_days:integer 99999}
    {fs_url:localurl "[ad_conn package_url]"}
    {return_url ""}
    {format "table"}
    {root_folder_id:integer ""}
} -validate {
    folder_id_exists {
        if { $folder_id eq "" } {
            ad_complain
        }
    }
} -errors {
    folder_id_exists [_ file-storage.lt_bad_folder_id_folder_]
} -properties {
    folder_name:onevalue
    contents:multirow
    content_size_total:onevalue
    page_num
}

set viewing_user_id [ad_conn user_id]

permission::require_permission -party_id $viewing_user_id -object_id $folder_id -privilege "read"

set admin_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "admin"]
set write_p $admin_p
set delete_p $admin_p

if {!$write_p} {
    set write_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "write"]
}
if {!$delete_p} {
    set delete_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "delete"]
}

set folder_name [lang::util::localize [fs::get_object_name -object_id  $folder_id]]

set content_size_total 0

#AG: We're an include file, and we may be included from outside file-storage.
#So we need to query for the package_id rather than getting it from ad_conn.
set package_and_root [fs::get_folder_package_and_root $folder_id]
set package_id [lindex $package_and_root 0]
if { $root_folder_id eq "" } {
    set root_folder_id [lindex $package_and_root 1]
}

if { $root_folder_id ne $folder_id } {
    set folder_path [content::item::get_path \
                         -item_id $folder_id \
                         -root_folder_id $root_folder_id]/
} else {
    set folder_path ""
}

set actions [list]

# for now, invite users to upload, and then they will be asked to
# login if they are not.

set cancel_url "[ad_conn url]?[ad_conn query]"
set add_url [export_vars -base "${fs_url}file-add" {folder_id}]

if {$write_p} {
    lappend actions "#file-storage.Add_File#" \
        [export_vars -base "${fs_url}file-upload-confirm" {folder_id cancel_url {return_url $add_url}}] \
        [_ file-storage.lt_Upload_a_file_in_this] \
        "#file-storage.Create_a_URL#" \
        [export_vars -base "${fs_url}simple-add" {folder_id}] \
        [_ file-storage.lt_Add_a_link_to_a_web_p] \
        "#file-storage.New_Folder#" \
        [export_vars -base "${fs_url}folder-create" {{parent_id $folder_id}}] \
        "#file-storage.Create_a_new_folder#" \
        [_ file-storage.lt_Upload_compressed_fol] \
        [export_vars -base "${fs_url}folder-zip-add" {folder_id}] \
        [_ file-storage.lt_Upload_a_compressed_f]
}

set expose_rss_p [parameter::get -parameter ExposeRssP -package_id $package_id -default 0]
set like_filesystem_p [parameter::get -parameter BehaveLikeFilesystemP -package_id $package_id -default 1]

set target_window_name [parameter::get -parameter DownloadTargetWindowName -package_id $package_id -default ""]
if {$target_window_name eq ""} {
    set target_attr ""
} else {
    set target_attr "target=\"$target_window_name\""
}

if {$delete_p && $root_folder_id ne $folder_id} {
    lappend actions \
	"#file-storage.Delete_this_folder#" \
	[export_vars -base "${fs_url}folder-delete" {folder_id}] \
	"#file-storage.Delete_this_folder#"
}
if {$admin_p} {
    if { $root_folder_id ne $folder_id } {
        lappend actions \
            "#file-storage.Edit_Folder#" \
            [export_vars -base "${fs_url}folder-edit" {folder_id}] \
            "#file-storage.Rename_this_folder#"
    }
    lappend actions \
        "#file-storage.lt_Modify_permissions_on_1#" \
	[export_vars -base "${fs_url}permissions" -override {{object_id $folder_id}} {{return_url "[ad_conn url]"}}] \
	"#file-storage.lt_Modify_permissions_on_1#"
    if { $expose_rss_p } {
        lappend actions "Configure RSS" [export_vars -base "${fs_url}admin/rss-subscrs" {folder_id}] "Configure RSS"
    }
}
set categories_p [parameter::get -parameter CategoriesP -package_id $package_id -default 0]
if { $categories_p } {
    if { [permission::permission_p -party_id $viewing_user_id -object_id $package_id -privilege "admin"] } {
        lappend actions \
	    [_ categories.cadmin] \
	    [export_vars -base "/categories/cadmin/object-map" -url {{object_id $package_id}}] \
	    [_ categories.cadmin]
    }
    set category_links [fs::category_links -object_id $folder_id -folder_id $folder_id -selected_category_id $category_id -fs_url $fs_url]
}

#set n_past_filter_values [list [list "Yesterday" 1] [list [_ file-storage.last_week] 7] [list [_ file-storage.last_month] 30]]
set elements {
    type {
        label #file-storage.Type#
        display_template {<img src="@contents.icon@"  style="border: 0;" alt="@contents.alt_icon@" width="16" height="16">@contents.pretty_type@}
    }
    name {
        label #file-storage.Name#
        display_template {
            <a @target_attr@ href="@contents.file_url@" title="#file-storage.view_contents#">
            <if @contents.title@ nil>
               @contents.name@</a>
            </if>
            <else>
               @contents.title@</a><br>
               <if @contents.name@ ne @contents.title@>
                  @contents.name@
               </if>
            </else>
        }
    }
    content_size_pretty {
        label #file-storage.Size#
        display_template {@contents.content_size_pretty;noquote@}
    }
    last_modified_pretty {
        label #file-storage.Last_Modified#
    }
    properties_link {
        label ""
        link_url_col properties_url
        link_html { title "#file-storage.properties#" }
    }
    new_version_link {
        label ""
        link_url_col new_version_url
        link_html { title "#file-storage.Upload_a_new_version#" }
    }
    download_link {
        label ""
        link_url_col download_url
        link_html { title "#file-storage.Download#" }
    }
}

if { $categories_p } {
    lappend elements \
        categories [list label [_ file-storage.Categories] display_col "categories;noquote"]
}

if {[apm_package_installed_p views]} {
    lappend elements views [list label "Views"]
}

if { $return_url eq "" } {
    set return_url [export_vars -base "index" {folder_id}]
}

set vars_to_export [list return_url]


set bulk_actions {}
if {$allow_bulk_actions} {
    set user_id [ad_conn user_id]
    set bulk_delete_p [db_string some_deletables {
        select exists (select 1 from fs_objects
                       where parent_id = :folder_id
                       and acs_permission__permission_p(object_id, :viewing_user_id, 'delete'))
    }]
    set bulk_copy_p [permission::permission_p -object_id $folder_id -privilege write]


    # add button only when available folders for move exist.  We
    # lazily check for deletion, as a proper check of a suitable
    # destination for moving would be too much effort
    if {$bulk_delete_p} {
        lappend bulk_actions \
            [_ file-storage.Move] ${fs_url}move [_ file-storage.lt_Move_Checked_Items_to]
    }
    # add button only when available folders for copy exist. We settle for
    # a lazy check on write permissions for folder because a rigorous
    # check of available destinations would not be performant.
    if {$bulk_copy_p} {
        lappend bulk_actions \
            [_ file-storage.Copy] ${fs_url}copy [_ file-storage.lt_Copy_Checked_Items_to]
    }

    if {$bulk_delete_p} {
        lappend bulk_actions \
            [_ file-storage.Delete] ${fs_url}delete [_ file-storage.Delete_Checked_Items]
    }

    lappend bulk_actions \
        [_ file-storage.Download_ZIP] ${fs_url}download-zip [_ file-storage.Download_ZIP_Checked_Items]

    callback fs::folder_chunk::add_bulk_actions \
        -bulk_variable "bulk_actions" \
        -folder_id $folder_id \
        -var_export_list "vars_to_export"
}


if {$format eq "list"} {
    set actions {}
}

# template::list creates a lot of variables in the global templating
# namespace and therefore needs to be named uniquely in order to
# include multiple instances of this script in the same page.
template::list::create \
    -name contents_${folder_id} \
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
    -elements $elements \
    -orderby {
        default_value "name,asc"
        type {
            orderby_desc {fs_objects.sort_key desc, fs_objects.pretty_type desc}
            orderby_asc {fs_objects.sort_key asc, fs_objects.pretty_type asc}
        }
        name {
            orderby_desc {fs_objects.sort_key desc, fs_objects.name desc}
            orderby_asc {fs_objects.sort_key asc, fs_objects.name asc}
        }
        content_size_pretty {
            orderby_desc {content_size desc}
            orderby_asc {content_size asc}
        }
        last_modified_pretty {
            orderby_desc {last_modified_ansi desc}
            orderby_asc {last_modified_ansi asc}
        }
    }

set orderby [template::list::orderby_clause -name contents_${folder_id} -orderby]

set categories_limitation [expr {$categories_p && $category_id ne "" ?
                                 [db_map categories_limitation] : ""}]

db_multirow -extend {
    label
    alt_icon
    icon
    last_modified_pretty
    content_size_pretty
    properties_link
    properties_url
    download_link
    download_url
    new_version_link
    new_version_url
    views
    categories
} contents select_folder_contents {} {
    set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]
    set last_modified_pretty [lc_time_fmt $last_modified_ansi "%x %X"]

    if {$type eq "folder"} {
        set content_size_pretty "[lc_numeric $content_size]&nbsp;[_ file-storage.items]"
        set pretty_type "#file-storage.Folder#"
    } else {
        if { $content_size eq "" } {
            set content_size 0
        }
        if {$content_size < 1024} {
            set content_size_pretty "[lc_numeric $content_size]&nbsp;[_ file-storage.bytes]"
        } else {
            set content_size_pretty "[lc_numeric [expr {$content_size / 1024 }]]&nbsp;[_ file-storage.kb]"
        }
    }

    if { $content_size ne "" } {
        incr content_size_total $content_size
    }

    set views ""
    if {[apm_package_installed_p views]} {
        array set views_arr [views::get -object_id $object_id]
        if {$views_arr(views_count) ne ""} {
            set views " $views_arr(views_count) / $views_arr(unique_views)"
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
            set file_url [export_vars -base "${fs_url}index" {{folder_id $object_id}}]
            set download_link [_ file-storage.Download]
            set download_url "[export_vars -base "${fs_url}download-zip" -url {object_id}]"
        }
        url {
            set properties_link [_ file-storage.properties]
            set properties_url [export_vars -base "${fs_url}simple" {object_id}]
            set new_version_link [_ acs-kernel.common_New]
            set new_version_url [export_vars -base "${fs_url}file-add" {{file_id $object_id}}]
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
            set properties_link [_ file-storage.properties]
            set target_object_id [content::symlink::resolve -item_id $object_id]
            db_1row file_info {
                select live_revision,
                       type,
                       content_size,
                       name,
                       file_upload_name,
                       title,
                       mime_type,
                       last_modified,
                       url,
                       parent_id,
                       key,
                       sort_key,
                       pretty_type
                 from fs_objects
                where object_id = :target_object_id
            }
            if {$type eq "folder"} {
                set content_size_pretty [lc_numeric $content_size]
                append content_size_pretty "&nbsp;[_ file-storage.items]"
                set pretty_type "#file-storage.Folder#"
            } else {
                if {$content_size < 1024} {
                    set content_size_pretty "[lc_numeric $content_size]&nbsp;[_ file-storage.bytes]"
                } else {
                    set content_size_pretty "[lc_numeric [expr {$content_size / 1024 }]]&nbsp;[_ file-storage.kb]"
                }
            }
            set properties_url [export_vars -base ${fs_url}file {{file_id $object_id}}]
            set new_version_link [_ acs-kernel.common_New]
            set new_version_url [export_vars -base ${fs_url}file-add {{file_id $object_id}}]
            set icon "/resources/file-storage/file.gif"
            set alt_icon #file-storage.file#
            set download_link [_ file-storage.Download]
            if {$like_filesystem_p} {
                set download_url [export_vars -base ${fs_url}download/[ad_urlencode_path $title] {{file_id $target_object_id}}]
                set file_url $download_url
            } else {
                set download_url [export_vars -base ${fs_url}download/[ad_urlencode_path $name] {{file_id $target_object_id}}]
		set file_url ${fs_url}view/${file_url}
            }
        }
        default {
            set properties_link [_ file-storage.properties]
            set properties_url [export_vars -base ${fs_url}file {{file_id $object_id}}]
            if { [permission::permission_p \
                      -object_id $object_id -privilege "write"] } {
                set new_version_link [_ acs-kernel.common_New]
                set new_version_url [export_vars -base ${fs_url}file-add {{file_id $object_id}}]
            }
            set icon "/resources/file-storage/file.gif"
            set alt_icon "#file-storage.file#"
            set download_link [_ file-storage.Download]
            if {$like_filesystem_p} {
                set download_url /file/$object_id/[ad_urlencode_path $title][file extension $name]
                set file_url [export_vars -base ${fs_url}download/[ad_urlencode_path $title] {{file_id $object_id}}]
            } else {
                set download_url /file/$object_id/[ad_urlencode_path $name]
		set file_url ${fs_url}view/[ad_urlencode_folder_path $folder_path][ad_urlencode_path $name]
            }
        }
    }
    if { $categories_p } {
        if { $type eq "folder" } {
            set cat_folder_id $object_id
        } else {
            set cat_folder_id $folder_id
        }
        set categories [fs::category_links \
			    -object_id $object_id \
			    -folder_id $cat_folder_id \
			    -selected_category_id $category_id \
			    -fs_url $fs_url \
			    -joinwith "<br>"]
    }

}

if {$format eq "list"} {
    set content_size_total 0
}

if { $expose_rss_p } {
    db_multirow feeds select_subscrs {}
}

if {$content_size_total > 0} {
    set compressed_url [export_vars -base ${fs_url}download-zip -url {{object_id $folder_id}}]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
