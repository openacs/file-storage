ad_page_contract {
    display information about a file in the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 7 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
    {show_all_versions_p "t"}
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
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

ad_require_permission $file_id read

#set templating datasources

set user_id [ad_conn user_id]
set context [fs_context_bar_list $file_id]

set show_administer_permissions_link_p [ad_parameter "ShowAdministerPermissionsLinkP"]
set root_folder_id [fs::get_root_folder]
db_1row file_info ""

# We use the new db_map here
if {[string equal $show_all_versions_p "t"]} {
    set show_versions [db_map show_all_versions]
} else {
    set show_versions [db_map show_live_version]
}
set actions [list "Upload Revision" version-add?[export_vars file_id] "Upload a new version of this file" \
		 "Rename File" file-edit?[export_vars file_id] "Rename file" \
		 "Copy File" file-copy?[export_vars file_id] "Copy file" \
		 "Move File" file-move?[export_vars file_id] "Move file" \
		 "Delete File" file-delete?[export_vars file_id] "Delete file"]

if {[string equal $delete_p "t"]} {
    lappend actions [_ file-storage.Set_Permissions] "/permissions/one?[export_vars {{object_id $file_id}}]" [_ file-storage.lt_Modify_permissions_on]
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
	version_delete {label "" link_url_col version_delete_url}
    }

db_multirow -unclobber -extend { author_link last_modified_pretty content_size_pretty version_url version_delete version_delete_url} version version_info {} {
    # FIXME urlencode each part of the path
    # set file_url [ad_urlencode $file_url]
    set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]
    set last_modified_pretty [lc_time_fmt $last_modified_ansi "%x %X"]
    if {$content_size < 1024} {
	set content_size_pretty "[lc_numeric $content_size] [_ file-storage.bytes]"
    } else {
	set content_size_pretty "[lc_numeric [expr $content_size / 1024 ]] [_ file-storage.kb]"
    }
    if {[string equal $title ""]} {
	set title "[_ file-storage.untitled]"
    }
    if {![string equal $version_id $live_revision]} {
	set version_url "view/${file_url}?[export_vars {{revision_id $version_id}}]"
    } else {
	set version_url "view/${file_url}"
    }
    set version_delete [_ file-storage.Delete_Version]
    set version_delete_url "version-delete?[export_vars version_id]"
    set author_link [acs_community_member_link -user_id $author_id -label $author]
}

set return_url "[ad_conn url]?file_id=$file_id"

if { [apm_package_installed_p "general-comments"] && [ad_parameter "GeneralCommentsP" -package_id [ad_conn package_id]] } {
    set gc_link [general_comments_create_link $file_id $return_url]
    set gc_comments [general_comments_get_comments $file_id $return_url]
} else {
    set gc_link ""
    set gc_comments ""
}

# get folder id so we can implement a back link
set folder_id [db_string get_folder ""]

set folder_view_url "index?folder_id=$folder_id"
