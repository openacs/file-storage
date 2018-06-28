ad_page_contract {
    display information about a file in the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 7 Nov 2000
    @cvs-id $Id$
} {
    file_id:naturalnum,notnull
    {show_all_versions_p:boolean,notnull "f"}
} -validate {
    valid_file -requires {file_id} {
	if {![fs_file_p $file_id]} {
	    ad_complain "[_ file-storage.lt_The_specified_file_is]"
	}
    }
} -properties {
    title:onevalue
    name:onevalue
    owner:onevalue
    version:multirow
    show_all_versions_p:onevalue
    context:onevalue
    file_path:onevalue
}

# check they have read permission on this file

permission::require_permission -object_id $file_id -privilege read

#set templating datasources

set user_id [ad_conn user_id]
set context [fs_context_bar_list $file_id]

set show_administer_permissions_link_p [parameter::get -parameter "ShowAdministerPermissionsLinkP"]
set root_folder_id [fs::get_root_folder]
db_1row file_info {
        select (select creation_user from acs_objects
                 where object_id = f.object_id) as creation_user,
               name as title,
               parent_id,
               coalesce(url,file_upload_name) as name,
               live_revision
	from   fs_objects f
	where  f.object_id = :file_id
}

set write_p  [permission::permission_p -party_id $user_id -object_id $file_id -privilege "write"]
set delete_p [permission::permission_p -party_id $user_id -object_id $file_id -privilege "delete"]
set admin_p  [permission::permission_p -party_id $user_id -object_id $file_id -privilege "admin"]

set owner [person::name -person_id $creation_user]

set file_url [content::item::get_path -item_id $file_id \
                  -root_folder_id $root_folder_id]

# get folder id so we can implement a back link
set folder_id [content::item::get_parent_folder -item_id $file_id]
set folder_write_p [permission::permission_p -object_id $folder_id -privilege write]

set folder_view_url [export_vars -base index {folder_id}]

if { $show_all_versions_p } {
    set show_versions ""
} else {
    set show_versions "and r.revision_id = i.live_revision"
}

set not_show_all_versions_p [expr {!$show_all_versions_p}]
set show_versions_url [export_vars -base file {file_id {show_all_versions_p $not_show_all_versions_p}}]

set return_url [export_vars -base [ad_conn url] file_id]

set categories_p [parameter::get -parameter CategoriesP -package_id [ad_conn package_id] -default 0]
set rename_name [expr { $categories_p ? [_ file-storage.Edit_File] : [_ file-storage.Rename_File]}]

set actions {}

if {$write_p} {
    lappend actions \
        [_ file-storage.Upload_Revision] \
        [export_vars -base file-add {file_id return_url}] \
        "Upload a new version of this file" \
        $rename_name \
        [export_vars -base file-edit file_id] \
        "Rename file"
}

# add button only when available folders for copy exist. We settle for
# a lazy check on write permissions for folder because a rigorous
# check of available destinations would not be performant.
if {$folder_write_p} {    
    lappend actions \
        [_ file-storage.Copy_File] \
        [export_vars -base copy {{object_id $file_id} return_url}] \
        "Copy file"
}

if {$delete_p} {
    # add button only when available folders for move exist.  We
    # lazily check for deletion, as a proper check of a suitable
    # destination for moving would be too much effort
    lappend actions \
        [_ file-storage.Move_File] \
        [export_vars -base move {{object_id $file_id} {return_url $folder_view_url}}] \
        "Move file"
    lappend actions \
        [_ file-storage.Delete_File] \
        [export_vars -base delete {{object_id $file_id} {return_url $folder_view_url}}] \
        "Delete file" \
        [_ file-storage.Set_Permissions] \
        [export_vars -base permissions {{object_id $file_id}}] \
        [_ file-storage.lt_Modify_permissions_on]
}


template::list::create \
    -name version \
    -no_data [_ file-storage.lt_There_are_no_versions] \
    -multirow version \
    -actions $actions \
    -elements {
	title {
	    label \#file-storage.Title\#
	    link_url_col version_url
	    link_html {title "\#file-storage.show_version_title\#"}
	}
	author { label \#file-storage.Author\#
            display_template {@version.author_link;noquote@}
        }
	content_size {
	    label \#file-storage.Size\#
	    display_col content_size_pretty
	}
	type { label \#file-storage.Type\#
	       display_col pretty_type }
	last_modified_ansi {
	    label \#file-storage.Last_Modified\#
	    display_col last_modified_pretty
	}
	description { label \#file-storage.Version_Notes\#}
	version_delete {
	    label "" 
	    link_url_col version_delete_url
	    link_html {title "\#file-storage.Delete_Version\#"}
	}
    }

db_multirow -unclobber -extend { author_link last_modified_pretty content_size_pretty version_url version_delete version_delete_url} version version_info {} {
    # FIXME urlencode each part of the path
    # set file_url [ad_urlencode $file_url]
    set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]
    set last_modified_pretty [lc_time_fmt $last_modified_ansi "%x %X"]
    if {$content_size < 1024} {
	set content_size_pretty "[lc_numeric $content_size] [_ file-storage.bytes]"
    } else {
	set content_size_pretty "[lc_numeric [expr {$content_size / 1024 }]] [_ file-storage.kb]"
    }
    if {$title eq ""} {
	set title "[_ file-storage.untitled]"
    }
    if {$version_id ne $live_revision } {
        set version_url [export_vars -base "download/$title" {version_id}]
    } else {
        set version_url [export_vars -base "download/$title" {file_id}]
    }
    if {$delete_p} {
        set version_delete [_ file-storage.Delete_Version]
        set version_delete_url [export_vars -base version-delete version_id]
    }
    set author_link [acs_community_member_link -user_id $author_id -label $author]
}

if { [apm_package_installed_p "general-comments"] && [parameter::get -parameter "GeneralCommentsP" -package_id [ad_conn package_id]] } {
    set gc_link [general_comments_create_link $file_id $return_url]
    set gc_comments [general_comments_get_comments $file_id $return_url]
} else {
    set gc_link ""
    set gc_comments ""
}

if { $categories_p } {
    set category_links [fs::category_links -object_id $file_id -folder_id $folder_id]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
