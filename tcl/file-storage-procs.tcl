ad_library {
    TCL library for the file-storage system (v.4)

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 November 2000
    @cvs-id $Id$
}
 
ad_proc fs_get_root_folder {
    {-package_id ""}
} {
    Returns the root folder for the file storage system.
} {
    if [empty_string_p $package_id] {
	set package_id [ad_conn package_id]
    }

    return [fs::get_root_folder -package_id $package_id]
}

ad_proc fs_get_folder_name {
    folder_id
} {
    Returns the name of a folder. 
} {
    return [db_exec_plsql folder_name "
    begin
        :1 := file_storage.get_folder_name(:folder_id);
    end;"]
}

#
# Type-checking procs
#
# These might be cleaner if we were subtyping the CR object types
# We aren't checking if the objects are actually below the file-storage
# root, although we probably should.
#
# Note that we aren't using things like the content_folder.is_folder
# method because that will return 't' for things elsewhere in the
# content repository that have subclassed the default types.
#

ad_proc fs_folder_p {
    folder_id
} {
    Returns 1 if the folder_id corresponds to a folder in the file-storage
    system.  Returns 0 otherwise.
} {
    if {[string equal [db_string object_type "
    select object_type 
    from   acs_objects
    where  object_id = :folder_id" -default ""] "content_folder"]} {
	return 1
    } else {
	return 0
    }
}

ad_proc fs_file_p {
    file_id
} {
    Returns 1 if the file_id corresponds to a file in the file-storage
    system.  Returns 0 otherwise.
} {
    if {[string equal [db_string object_type "
    select object_type 
    from   acs_objects
    where  object_id = :file_id" -default ""] "content_item"]} {
	return 1
    } else {
	return 0
    }
}

ad_proc fs_version_p {
    version_id
} {
    Returns 1 if the version_id corresponds to a version in the file-storage
    system.  Returns 0 otherwise.
} {
    if {[string equal [db_string object_type "
    select object_type 
    from   acs_objects
    where  object_id = :version_id" -default ""] "file_storage_object"]} {
	return 1
    } else {
	return 0
    }
}

#
# Permission procs
#

ad_proc children_have_permission_p {
    {-user_id ""}
    item_id
    privilege
} {
    This procedure, given a content item and a privilege, checks to see if 
    there are any children of the item on which the user does not have that
    privilege.  It returns 0 if there is any child item on which the user
    does not have the privilege.  It returns 1 if the user has the
    privilege on every child item.
} {
    if [empty_string_p $user_id] {
	set user_id [ad_conn user_id]
    }

    # This only gets child folders and items

    set num_wo_perm [db_string child_perms "
    select count(*)
    from   cr_items
    where  item_id in (select item_id
                       from   cr_items
                       connect by prior item_id = parent_id
                       start with item_id = :item_id)
    and    acs_permission.permission_p(item_id,:user_id,:privilege) = 'f'"]

    # now check revisions

    db_foreach child_items {
	select item_id as child_item_id
	from   cr_items
	connect by prior item_id = parent_id
	start with item_id = :item_id
    } {
	incr num_wo_perm [db_string revision_perms "
	select count(*)
	from   cr_revisions
	where  item_id = :child_item_id
	and    acs_permission.permission_p(revision_id,:user_id,:privilege) = 'f'"]
    }

    if { $num_wo_perm > 0 } {
	return 0
    } else {
	return 1
    }

}


# 
# Display procs
#

ad_proc fs_context_bar_list {
    {-root_folder_id ""}
    {-final ""}
    {-folder_url "index"}
    {-file_url "file"}
    {-extra_vars ""}
    item_id
} {
    Constructs the list to be fed to ad_context_bar appropriate for
    item_id.  If -final is specified, that string will be the last 
    item in the context bar.  Otherwise, the name corresponding to 
    item_id will be used.
} {
    if {[empty_string_p $root_folder_id]} {
        set root_folder_id [fs_get_root_folder]
    }

    if [empty_string_p $final] {
	set start_id [db_string parent_id "
	select parent_id from cr_items where item_id = :item_id"]
	set final [db_exec_plsql title "begin
	    :1 := file_storage.get_title(:item_id);
	end;"]
    } else {
	set start_id $item_id
    }

    set context_bar [db_list_of_lists context_bar {}]

    lappend context_bar $final

    return $context_bar
}

namespace eval fs {}

ad_proc -public fs::after_mount {
    -package_id
    -node_id
} {
    Create root folder for package instance
    via tcl callback.
} {
    array set sn [site_node::get -node_id $node_id]
    regsub -all {/} $sn(name)  {} name
    # using site_node name for root folder name
    # doesn't work in the case that multiple instances of
    # a node called "file-storage" for example, are mounted
    # all file storage root folders have parent_id=0 and
    # parent_id, name must be unique.

    # this isn't a problem in resolving URLs because we know which
    # root folder is associated with a site_node/package_id
    
    set label $sn(instance_name)

    set folder_id [fs::new_root_folder \
		       -package_id $package_id \
		       -pretty_name $label
		       ]

    oacs_dav::register_folder -enabled_p "t" $folder_id $sn(node_id)
    
}

ad_proc -public fs::new_root_folder {
    {-package_id ""}
    {-pretty_name ""}
    {-description ""}
    {-name ""}
} {
    Create a root folder for a package instance.

    @param package_id Package instance associated with this root folder

    @return folder_id of the new root folder
} {

    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }

    if {[empty_string_p $pretty_name]} {
	set pretty_name [apm_instance_name_from_id $package_id]
    }

    if {[empty_string_p $name]} {
	set name "file-storage_${package_id}"
    }

    return [db_exec_plsql new_root_folder {}]

}


ad_proc -public fs::get_root_folder {
    {-package_id ""}
} {
    Get the root folder of a package instance.

    @param package_id Package instance of the root folder to retrieve

    @return folder_id of the root folder retrieved
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }

    return [db_exec_plsql get_root_folder {}]
}

ad_proc -public fs::get_parent {
    -item_id
} {
    Get the parent of a given item.
} {
    return [db_string get_parent_id ""]
}


ad_proc -public fs::new_folder {
    {-name:required}
    {-pretty_name:required}
    {-parent_id:required}
    {-creation_user ""}
    {-creation_ip ""}
    {-description ""}
} {
    Create a new folder.

    @param name Internal name of the folder, must be unique under a given
    parent_id
    @param pretty_name What we show to users of the system
    @param parent_id Where we create this folder
    @param creation_user Who created this folder
    @param creation_ip What is the ip address of the creation_user
    @param description of the folder. Not used in the current FS UI but might be used elsewhere.
    @return folder_id of the newly created folder
} {
    if {[empty_string_p $creation_user]} {
	set creation_user [ad_conn user_id]
    }

    if {[empty_string_p $creation_ip]} {
	set creation_ip [ns_conn peeraddr]
    }
    set folder_id [db_exec_plsql new_folder {}]
    fs::set_folder_description -folder_id $folder_id -description $description
    return $folder_id
}

ad_proc -public fs::rename_folder {
    {-folder_id:required}
    {-name:required}
} {
    rename the given folder
} {
    db_exec_plsql rename_folder {}
}

ad_proc -public fs::set_folder_description {
    {-folder_id:required}
    {-description ""}
} {
    sets the description for the given folder in cr_folders. Perhaps this shoudl be a CR proc?
} {
    db_dml set_folder_description { *SQL* }
}

ad_proc -public fs::object_p {
    {-object_id:required}
} {
    is this a file storage object
} {
    return [db_string select_object_p {}]
}

ad_proc -public fs::get_object_name {
    {-object_id:required}
} {
    Select the name of this object.
} {
    return [db_string select_object_name {} -default $object_id]
}

ad_proc -public fs::get_file_system_safe_object_name {
    {-object_id:required}
} {
    get the name of a file storage object and make it safe for writing to
    the file system
} {
    return [remove_special_file_system_characters -string [get_object_name -object_id $object_id]]
}

ad_proc -public fs::remove_special_file_system_characters {
    {-string:required}
} {
    remove unsafe file system characters. useful if you want to use $string
    as the name of an object to write to disk.
} {
    regsub -all {[<>:\"|/@\#%&+\\]} $string {_} string
    return [string trim $string]
}

ad_proc -public fs::folder_p {
    {-object_id:required}
} {
    Is this object a folder?

    @return true if object_id is a folder
} {
    return [db_string select_folder_p {} -default 0]
}

ad_proc -public fs::get_folder {
    {-name:required}
    {-parent_id:required}
} {
    Retrieve the folder_id of a folder given it's name and parent folder.

    @param name Internal name of the folder, must be unique under a given
    parent_id
    @param parent_id The parent folder to look under

    @return folder_id of the folder, or null if no folder was found by that
    name
} {
    return [db_string select_folder {} -default ""]
}

ad_proc -public fs::get_folder_objects {
    -folder_id:required
    -user_id:required
} {
    Return a list the object_ids contained by a file storage folder.

    @param folder_id The folder for which to retrieve contents
    @param user_id The viewer of the contents (to make sure they have
					       permission)

} {
    return [db_list select_folder_contents {}]
}

ad_proc -public fs::get_folder_contents {
    {-folder_id ""}
    {-user_id ""}
    {-n_past_days "99999"}
} {
    WARNING: This proc is not scalable because it does too many permission checks. 

    DRB: Not so true now that permissions are fast.  However it is now only used
    to clone files in dotLRN and for the somewhat brain-damaged syllabus package. 
    At minimum the permission checks returned by the code can be removed.  Most of
    the other fields as well.   Oh well ...

    REMOVE WHEN SYLLABUS IS REWRITTEN TO FIND ITS FILE INTELLIGENTLY

    Retrieve the contents of the specified folder in the form of a list
    of ns_sets, one for each row returned. The keys for each row are as
    follows:

    object_id, name, live_revision, type,
    last_modified, new_p, content_size, file_upload_name
    write_p, delete_p, admin_p, 

    @param folder_id The folder for which to retrieve contents
    @param user_id The viewer of the contents (to make sure they have
					       permission)
    @param n_past_days Mark files that are newer than the past N days as new
} {
    if {[empty_string_p $folder_id]} {
	set folder_id [get_root_folder -package_id [ad_conn package_id]]
    }

    if {[empty_string_p $user_id]} {
	set user_id [acs_magic_object the_public]
    }

    set list_of_ns_sets [db_list_of_ns_sets select_folder_contents {}]

    foreach set $list_of_ns_sets {
	# in plain Tcl:
	# set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]
	ns_set put $set last_modified_ansi [lc_time_system_to_conn [ns_set get $set last_modifed_ansi]] 

	# in plain Tcl:
	# set last_modified [lc_time_fmt $last_modified_ansi "%x %X"]
	ns_set put $set last_modified [lc_time_fmt [ns_set get $set last_modified_ansi] "%x %X"]

	# set content_size_pretty [lc_numeric $content_size]
	ns_set put $set content_size_pretty [lc_numeric [ns_set get $set content_size]]
    }

    return $list_of_ns_sets
}

ad_proc -public fs::get_folder_contents_count {
    {-folder_id ""}
    {-user_id ""}
} {
    Retrieve the count of contents of the specified folder.

    @param folder_id The folder for which to retrieve contents
    @param user_id The viewer of the contents (to make sure they have
					       permission)
} {
    if {[empty_string_p $folder_id]} {
	set folder_id [get_root_folder -package_id [ad_conn package_id]]
    }

    if {[empty_string_p $user_id]} {
	set user_id [acs_magic_object the_public]
    }

    return [db_string select_folder_contents_count {}]
}

ad_proc -public fs::publish_object_to_file_system {
    {-object_id:required}
    {-path ""}
    {-file_name ""}
    {-user_id ""}
} {
    publish a file storage object to the file system
} {
    if {[empty_string_p $path]} {
	set path [ns_tmpnam]
    }

    db_1row select_object_info {}

    if {[string equal folder $type]} {
	set result [publish_folder_to_file_system -folder_id $object_id -path $path -folder_name $name -user_id $user_id]
    } elseif {[string equal url $type]} {
	set result [publish_url_to_file_system -object_id $object_id -path $path -file_name $file_name]
    } else {
	set result [publish_versioned_object_to_file_system -object_id $object_id -path $path]
    }

    return $result
}

ad_proc -public fs::publish_folder_to_file_system {
    {-folder_id:required}
    {-path ""}
    {-folder_name ""}
    {-user_id ""}
} {
    publish the contents of a file storage folder to the file system
} {
    if {[empty_string_p $path]} {
	set path [ns_tmpnam]
    }

    if {[empty_string_p $folder_name]} {
	set folder_name [get_object_name -object_id $folder_id]
    }
    set folder_name [remove_special_file_system_characters -string $folder_name]

    set dir [file join ${path} ${folder_name}]
    file mkdir $dir

    foreach object [get_folder_contents -folder_id $folder_id -user_id $user_id] {
	publish_object_to_file_system \
	    -object_id [ns_set get $object object_id] \
	    -path $dir \
	    -file_name [remove_special_file_system_characters -string [ns_set get $object name]] \
	    -user_id $user_id
    }

    return $dir
}

ad_proc -public fs::publish_url_to_file_system {
    {-object_id:required}
    {-path ""}
    {-file_name ""}
} {
    publish a url object to the file system as a Windows shortcut
    (which at least KDE also knows how to handle)
} {
    if {[empty_string_p $path]} {
	set path [ns_tmpnam]
	file mkdir $path
    }

    db_1row select_object_metadata {}

    if {[empty_string_p $file_name]} {
	set file_name $label
    }
    set file_name "${file_name}.url"
    set file_name [remove_special_file_system_characters -string $file_name]

    set fp [open [file join ${path} ${file_name}] w]
    puts $fp {[InternetShortcut]}
    puts $fp URL=$url
    close $fp

    return [file join ${path} ${file_name}]
}

ad_proc -public fs::publish_versioned_object_to_file_system {
    {-object_id:required}
    {-path ""}
    {-file_name ""}
} {
    publish an object to the file system
} {
    if {[empty_string_p $path]} {
	set path [ns_tmpnam]
	file mkdir $path
    }

    db_1row select_object_metadata {}

    if {[empty_string_p $file_name]} {
	set file_name $title
    }
    set file_name [remove_special_file_system_characters -string $file_name]

    switch $storage_type {
	lob {

	    # FIXME: db_blob_get_file is failing when i use bind variables

	    # DRB: you're out of luck - the driver doesn't support them and while it should
	    # be fixed it will be a long time before we'll want to require an updated
	    # driver.  I'm substituting the Tcl variable value directly in the query due to
	    # this.  It's safe because we've pulled the value ourselves from the database,
	    # don't need to worry about SQL smuggling etc.

	    db_blob_get_file select_object_content {} -file [file join ${path} ${file_name}]
	}
	text {
	    set content [db_string select_object_content {}]

	    set fp [open [file join ${path} ${file_name}] w]
	    puts $fp $content
	    close $fp
	}
	file {
	    set cr_path [cr_fs_path $storage_area_key]
	    set cr_file_name [db_string select_file_name {}]

	    file copy -- "${cr_path}${cr_file_name}" [file join ${path} ${file_name}]
	}
    }

    return [file join ${path} ${file_name}]
}

ad_proc -public fs::get_archive_command {
    {-in_file ""}
    {-out_file ""}
} {
    return the archive command after replacing {in_file} and {out_file} with
    their respective values.
} {
    set cmd [parameter::get -parameter ArchiveCommand -default "tar cf - {in_file} | gzip > {out_file}"]

    regsub -all {(\W)} $in_file {\\\1} in_file
    regsub -all {\\/} $in_file {/} in_file
    regsub -all {\\\.} $in_file {.} in_file

    regsub -all {(\W)} $out_file {\\\1} out_file
    regsub -all {\\/} $out_file {/} out_file
    regsub -all {\\\.} $out_file {.} out_file

    regsub -all {{in_file}} $cmd $in_file cmd
    regsub -all {{out_file}} $cmd $out_file cmd

    return $cmd
}

ad_proc -public fs::get_archive_extension {} {
    return the archive extension that should be added to the output file of
    an archive command
} {
    return [parameter::get -parameter ArchiveExtension -default "txt"]
}

ad_proc -public fs::get_item_id {
    -name
    {-folder_id ""}
} {
    Get the item_id of a file
} {
    if {[empty_string_p $folder_id]} {
	set package_id [ad_conn package_id]
	set folder_id [fs_get_root_folder -package_id $package_id]
    }
    return [db_exec_plsql get_item_id ""]
}

ad_proc -public fs::add_file {
    -name
    -parent_id
    -tmp_filename
    -package_id
    {-item_id ""}
    {-creation_user ""}
    {-creation_ip ""}
    {-title ""}
    {-description ""}
} {
    Create a new file storage item or add a new revision if
    an item with the same name and parent folder already exists

    @return revision_id
} {

    if {[parameter::get -parameter "StoreFilesInDatabaseP" -package_id $package_id]} {
	set indbp "t"
    } else {
	set indbp "f"
    }

    set mime_type [cr_filename_to_mime_type -create $name]
    switch  [cr_registered_type_for_mime_type $mime_type] {
        image {
	    set content_type "image"
	}
	default {
	    set content_type "file_storage_object"
	}
    }

    db_transaction {
	if {[empty_string_p $item_id] || ![db_string item_exists ""]} {
	    set item_id [db_exec_plsql create_item ""]
	    if {![empty_string_p $creation_user]} {
		permission::grant -party_id $creation_user -object_id $item_id -privilege admin
	    }
	    set do_notify_here_p "t"
	} else {
	    set do_notify_here_p "f"
	}
	
	set revision_id [fs::add_version \
			     -name $name \
			     -tmp_filename $tmp_filename \
			     -package_id $package_id \
			     -item_id $item_id \
			     -creation_user $creation_user \
			     -creation_ip $creation_ip \
			     -title $title \
			     -description $description \
			     -suppress_notify_p $do_notify_here_p
			]
	
	if {[string is true $do_notify_here_p]} {
	    fs::do_notifications -folder_id $parent_id -filename $title -item_id $revision_id -action "new_file" -package_id $package_id
	}
    }
    return $revision_id
}

ad_proc fs::add_version {
    -name
    -tmp_filename
    -package_id
    {-item_id ""}
    {-creation_user ""}
    {-creation_ip ""}
    {-title ""}
    {-description ""}
    {-suppress_notify_p "f"}
    
} {
    Create a new version of a file storage item 
    @return revision_id
} {

    if {[parameter::get -parameter "StoreFilesInDatabaseP" -package_id $package_id]} {
	set storage_type "lob"
    } else {
	set storage_type "file"
    }

    set mime_type [cr_filename_to_mime_type -create $name]
    set tmp_size [file size $tmp_filename]
    set parent_id [get_parent -item_id $item_id]
    set revision_id [cr_import_content \
			 -item_id $item_id \
			 -storage_type $storage_type \
			 -creation_user $creation_user \
			 -creation_ip $creation_ip \
			 -other_type "file_storage_object" \
			 -image_type "file_storage_object" \
			 -title $title \
			 -description $description \
			 $parent_id \
			 $tmp_filename \
			 $tmp_size \
			 $mime_type \
			 $name]
	
	db_dml set_live_revision ""
	db_exec_plsql update_last_modified ""

    if {[string is false $suppress_notify_p]} {
	fs::do_notifications -folder_id $parent_id -filename $title -item_id $revision_id -action "new_version" -package_id $package_id
    }

    return $revision_id
}

ad_proc fs::delete_file {
    -item_id
    {-parent_id ""}
} {
    Deletes a file and all its revisions
} {
    set version_name [get_object_name -object_id $item_id]
    db_exec_plsql delete_file ""

    if {[empty_string_p $parent_id]} {
	set parent_id [get_parent -item_id $item_id]
    }
    
    fs::do_notifications -folder_id $parent_id -filename $version_name -item_id $item_id -action "delete_file"
}

ad_proc fs::delete_version {
    -item_id
    -version_id
} {
    Deletes a revision. If it was the last revision, it deletes
    the file as well.
} {
    set parent_id [db_exec_plsql delete_version ""]
    
    if {$parent_id > 0} {
	delete_file -item_id $item_id -parent_id $parent_id
    }
    return $parent_id
}

ad_proc fs::webdav_url {
    -item_id
    {-root_folder_id ""}
    {-package_id ""}
} {
    Provide URL for webdav access to file or folder

    @param item_id folder_id or item_id of file-storage folder or file
    @param root_folder_id root folder to resolve URL from
    
    @return fully qualified URL for WebDAV access or empty string if
            item is not WebDAV enabled
} {

    if {  [ad_parameter "UseWebDavP"] == 0 } {
	return "ho"
    }  
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    
    if {[empty_string_p $root_folder_id]} {
	set root_folder_id [fs::get_root_folder -package_id $package_id]
    }

    if {[string equal "t" [oacs_dav::folder_enabled -folder_id $root_folder_id]]} {
	if {[string equal $root_folder_id $item_id]} {
	    set url_stub ""
	} else {
	    set url_stub [item::get_url -root_folder_id $root_folder_id $item_id]
	}
	set package_url [apm_package_url_from_id $package_id]

	set webdav_prefix [oacs_dav::uri_prefix]

	return "[ad_url]${webdav_prefix}${package_url}${url_stub}"

    } else {

	return ""
	
    }
}

ad_proc -public fs::do_notifications {
    {-folder_id:required}
    {-filename:required}
    {-item_id:required}
    {-package_id ""}
    -action
} {
    Send notifications for file-storage operations.

    Note that not all possible operations are implemented, e.g. move, copy etc. See documentation.

    @param action The kind of operation. One of: new_file, new_version, new_url, delete_file, delete_url
} {
    if {[string equal "" $package_id]} {
        set package_id [ad_conn package_id]
    }
    set root_folder [fs_get_root_folder -package_id $package_id]

    if {[string equal $action "new_file"]} {
        set action_type {New File Uploaded}
    } elseif {[string equal $action "new_url"]} {
        set action_type {New URL Uploaded}
    } elseif {[string equal $action "new_version"]} {
        set action_type {New version of file uploaded}
    } elseif {[string equal $action "delete_file"]} {
        set action_type {File deleted}
    } elseif {[string equal $action "delete_url"]} {
        set action_type {URL deleted}
    } else {
        error "Unknown file-storage notification action: $action"
    }

    set url "[ad_url]"
    set new_content ""
    if {[string equal $action "new_file"] || [string equal $action "new_url"] || [string equal $action "new_version"]} {
        db_1row get_owner_name { }

        if {[string equal $action "new_version"]} {
            set sql "select description as description from cr_revisions 
                           where cr_revisions.revision_id = :item_id"
        } else {
            set sql "select description as description from cr_revisions 
                           where cr_revisions.item_id = :item_id"
        }

        db_0or1row description $sql

    }
    db_1row path1 { }
    
    # Set email message body - "text only" for now
    set text_version ""
    append text_version "Notification for: File-Storage: $action_type\n"
    append text_version "File-Storage folder: [fs_get_folder_name $folder_id]\n"

    if {[string equal $action "new_version"]} {
        append text_version "New Version Uploaded for file: $filename\n"
    } else {
        append text_version "Name of the $action_type: $filename\n"
    }
    if {[info exists owner]} {
        append text_version "Uploaded by: $owner\n"
    }
    if {[info exists description]} {
        append text_version "Version Notes: $description\n" 
    }

    append text_version "View folder contents: $url$path1?folder_id=$folder_id \n\n"

    set html_version [ad_html_text_convert -from text/plain -to text/html -- $text_version]
    append html_version "<br /><br />"
    # Do the notification for the file-storage
    
    notification::new \
        -type_id [notification::type::get_type_id \
                      -short_name fs_fs_notif] \
        -object_id $folder_id \
        -notif_subject {File Storage Notification} \
        -notif_text $text_version \
        -notif_html $html_version

    # walk through all folders up to the root folder
    while {$folder_id != $root_folder} {
        set parent_id [db_string parent_id "
	            select parent_id from cr_items where item_id = :folder_id"]
        notification::new \
            -type_id [notification::type::get_type_id \
                          -short_name fs_fs_notif] \
            -object_id $parent_id \
            -notif_subject {File Storage Notification} \
            -notif_text $new_content
        set folder_id $parent_id
    }
}
