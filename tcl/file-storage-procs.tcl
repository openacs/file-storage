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

    if {[empty_string_p $final] \
            && !($item_id == $root_folder_id)} {
        # don't get title for last element if we are in the
        # root folder
	set start_id [db_string parent_id "
	select parent_id from cr_items where item_id = :item_id"]
	set final [db_exec_plsql title "begin
	    :1 := file_storage.get_title(:item_id);
	end;"]
    } else {
	set start_id $item_id
    }

    set context_bar [db_list_of_lists context_bar {}]
    if {!($item_id == $root_folder_id)} {
        lappend context_bar $final
    }
    return $context_bar
}

namespace eval fs {}

ad_proc -private fs::after_mount {
    -package_id
    -node_id
} {
    Create root folder for package instance
    via tcl callback.
} {
    set folder_id [fs::get_root_folder -package_id $package_id]

    oacs_dav::register_folder -enabled_p "t" $folder_id $node_id
}

ad_proc -private fs::before_unmount {
    -package_id
    -node_id
} {
    Create root folder for package instance
    via tcl callback.
} {
    set folder_id [fs::get_root_folder -package_id $package_id]

    oacs_dav::unregister_folder $folder_id $node_id
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
    {-package_id ""}
    -no_callback:boolean
} {
    Create a new folder.

    @param name Internal name of the folder, must be unique under a given
    parent_id
    @param pretty_name What we show to users of the system
    @param parent_id Where we create this folder
    @param creation_user Who created this folder
    @param creation_ip What is the ip address of the creation_user
    @param description of the folder. Not used in the current FS UI but might be used elsewhere.
    @param package_id Package_id of the package for which to create the new folder. Preferably a file storage package_id
    @param no_callback defines if the callback should be called. Defaults to yes
    @return folder_id of the newly created folder
} {
    if {[empty_string_p $creation_user]} {
	set creation_user [ad_conn user_id]
    }

    if {[empty_string_p $creation_ip]} {
	set creation_ip [ns_conn peeraddr]
    }

    # If the package_id is empty, try the package_id from the parent_object
    if {$package_id eq ""} {
	set package_id [acs_object::package_id -object_id $parent_id]
	
	# If the package_id from the parent_id exists, make sure it is a file-storage package_id
	if {$package_id ne ""} {
	    if {[apm_package_key_from_id $package_id] ne "file-storage"} {
		set package_id ""
	    }
	}
    }

    
    set folder_id [content::folder::new -name $name -label $pretty_name -parent_id $parent_id -creation_user $creation_user -creation_ip $creation_ip -description $description -package_id $package_id]
    permission::grant -party_id $creation_user -object_id $folder_id -privilege "admin"

    if {!$no_callback_p} {
	callback fs::folder_new -package_id $package_id -folder_id $folder_id
    }

    return $folder_id
}

ad_proc -public fs::rename_folder {
    {-folder_id:required}
    {-name:required}
    -no_callback:boolean
} {
    rename the given folder
} {
    db_exec_plsql rename_folder {}
    if {!$no_callback_p} {
	if {![catch {ad_conn package_id} package_id]} {
	    callback fs::folder_edit -package_id $package_id -folder_id $folder_id
	}
    }
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

ad_proc -public fs::get_object_prettyname {
    {-object_id:required}
} {
    Select a pretty name for this object. If title is empty, returns name.
} {
    return [db_string select_object_prettyname {} -default $object_id]
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
    
    switch $type {
	folder {
	    set result [publish_folder_to_file_system -folder_id $object_id -path $path -folder_name $name -user_id $user_id]
	} 
	url {
	    set result [publish_url_to_file_system -object_id $object_id -path $path -file_name $file_name]
	} 
	symlink {
	    set linked_object_id [content::symlink::resolve -item_id $object_id]
	    set result [publish_versioned_object_to_file_system -object_id $linked_object_id -path $path -file_name $file_name]
	} 
	default {
	    set result [publish_versioned_object_to_file_system -object_id $object_id -path $path -file_name $file_name]
	}
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
    
    set dir "[file join ${path} "${folder_name}"]"
    # set dir "[file join ${path} "download"]"
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
	set file_name $name
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

    # After upgrade change title and filename...
    set like_filesystem_p [parameter::get -parameter BehaveLikeFilesystemP -default 1]

    if { $like_filesystem_p } {
	set file_name $title
	if {[empty_string_p $file_name]} {
	    if {![info exists upload_file_name]} {
		set file_name "unnamedfile"
	    } else {
		set file_name $file_upload_name
	    }
	} elseif { [item::get_mime_info [item::get_live_revision $object_id]] } {
	    # We make sure that the file_name contains the file
	    # extension at the end so that the users default
	    # application for that file type can be used
	    if { ![regexp "\.$mime_info(file_extension)$" $file_name match] } {
		set file_name "${file_name}.$mime_info(file_extension)"
	    }
	}
    } else {
	set file_name $file_upload_name
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
    -package_id
    {-item_id ""}
    {-creation_user ""}
    {-creation_ip ""}
    {-title ""}
    {-description ""}
    {-tmp_filename ""}
    {-mime_type ""}
    -no_callback:boolean
    -no_notification:boolean
} {
    Create a new file storage item or add a new revision if
    an item with the same name and parent folder already exists

    @return revision_id
} {

    if {[parameter::get -parameter "StoreFilesInDatabaseP" -package_id $package_id]} {
	set indbp "t"
        set storage_type "lob"
    } else {
	set indbp "f"
        set storage_type "file"
    }
    if {[string equal "" $mime_type]} {
        set mime_type [cr_filename_to_mime_type -create -- $name]
    }
    # we have to do this here because we create the object before
    # calling cr_import_content
    
#    if {[content::type::content_type_p -mime_type $mime_type -content_type "image"]} {
#        set content_type image
#    } else {
        set content_type file_storage_object
#    }

    if {$item_id eq ""} {
	set item_id [db_nextval acs_object_id_seq]
    }

    db_transaction {
	if {![db_string item_exists ""]} {
	    
	    if {$indbp} {
		set storage_type ""
	    } else {
		set storage_type "file"
	    }
	    
	    set item_id [content::item::new \
			     -item_id $item_id \
			     -parent_id $parent_id \
			     -creation_user "$creation_user" \
			     -creation_ip "$creation_ip" \
			     -package_id "$package_id" \
			     -name $name \
			     -storage_type "$storage_type" \
			     -content_type "file_storage_object" \
			     -mime_type "text/plain"
			    ]
			     
	    if {![empty_string_p $creation_user]} {
		permission::grant -party_id $creation_user -object_id $item_id -privilege admin
	    }

	    # Deal with notifications. Usually send out the notification
	    # But surpress it if the parameter is given
	    if {$no_notification_p} {
		set do_notify_here_p "f"
	    } else {
		set do_notify_here_p "t"
	    }
	} else {
	    # th: fixed to set old item_id if item already exists and no new item needed to be created
	    db_1row get_old_item ""
	    set do_notify_here_p "f"
	}
	if {$no_callback_p} {
	    set revision_id [fs::add_version \
				 -name $name \
				 -tmp_filename $tmp_filename \
				 -package_id $package_id \
				 -item_id $item_id \
				 -creation_user $creation_user \
				 -creation_ip $creation_ip \
				 -title $title \
				 -description $description \
				 -suppress_notify_p $do_notify_here_p \
				 -storage_type $storage_type \
				 -mime_type $mime_type \
				 -no_callback
			    ]
	} else {
	    set revision_id [fs::add_version \
				 -name $name \
				 -tmp_filename $tmp_filename \
				 -package_id $package_id \
				 -item_id $item_id \
				 -creation_user $creation_user \
				 -creation_ip $creation_ip \
				 -title $title \
				 -description $description \
				 -suppress_notify_p $do_notify_here_p \
				 -storage_type $storage_type \
				 -mime_type $mime_type
			    ]
	}
	
	if {[string is true $do_notify_here_p]} {
	    fs::do_notifications -folder_id $parent_id -filename $title -item_id $revision_id -action "new_file" -package_id $package_id
	    if {!$no_callback_p} {
		if {![catch {ad_conn package_id} package_id]} {
		    callback fs::file_new -package_id $package_id -file_id $item_id
		}
	    }
	}
    }
    return $revision_id
}

ad_proc -public fs::add_created_file {
    {-name ""}
    -parent_id
    -package_id
    {-item_id ""}
    {-mime_type ""}
    {-creation_user ""}
    {-creation_ip ""}
    {-title ""}
    {-description ""}
    {-content_body ""}
} {
    Create a new file storage item or add a new revision if
    an item with the same name and parent folder already exists

    @return revision_id
} {
    if {[parameter::get -parameter "StoreFilesInDatabaseP" -package_id $package_id]} {
	set indbp "t"
        set storage_type "lob"
    } else {
	set indbp "f"
        set storage_type "file"
    }
    if {![string equal "" $item_id]} {
        set storage_type [db_string get_storage_type "select storage_type from cr_items where item_id=:item_id"]
    }
    if {[empty_string_p $mime_type] } {
	set mime_type "text/html"
    }
    if { [empty_string_p $name] } {
	set name $title
    }

    set content_type "file_storage_object"

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
	
        set revision_id [fs::add_created_version \
            -name $title \
            -item_id $item_id \
            -creation_user $creation_user \
            -creation_ip [ad_conn peeradd] \
            -title $title \
            -description $description \
            -package_id $package_id \
            -content_body $content_body \
            -mime_type $mime_type \
            -storage_type $storage_type]

	
	if {[string is true $do_notify_here_p]} {
	    fs::do_notifications -folder_id $parent_id -filename $title -item_id $revision_id -action "new_file" -package_id $package_id
	}

	if {!$no_callback_p} {
	    if {![catch {ad_conn package_id} package_id]} {
		callback fs::file_new -package_id $package_id -file_id $item_id
	    }
	}
    }
    return $revision_id
}

ad_proc fs::add_created_version {
    -name
    -content_body
    -mime_type
    -item_id
    {-creation_user ""}
    {-creation_ip ""}
    {-title ""}
    {-description ""}
    {-suppress_notify_p "f" }
    {-storage_type ""}
    {-package_id ""}
    {-storage_type ""}
} {
    Create a new version of a file storage item using the content passed in content_body
    @return revision_id
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    if {[empty_string_p $storage_type]} {
	set storage_type [db_string get_storage_type ""]
    }
    if {[empty_string_p $creation_user]} {
	set creation_user [ad_conn user_id]
    }
    if {[empty_string_p $creation_ip]} {
	set creation_ip [ns_conn peeraddr]
    }
    set parent_id [fs::get_parent -item_id $item_id]
    if {[string equal "" $storage_type]} {
        set storage_type [db_string get_storage_type "select storage_type from cr_items where item_id=:item_id"]    
    }
    switch -- $storage_type {
        file {
            set revision_id [db_exec_plsql new_file_revision { }]

            set cr_file [cr_create_content_file_from_string $item_id $revision_id $content_body]

            # get the size
            set file_size [cr_file_size $cr_file]

            # update the file path in the CR and the size on cr_revisions
            db_dml update_revision { }
        }
        lob {
            # if someone stored file storage content in the database
            # we need to use lob. the only want ot get a lob into the
            # database if to pass it as a file
            set revision_id [cr_import_content \
             -item_id $item_id \
			 -storage_type  \
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
                db_dml set_lob_content "" -blobs [list $content_body]
                db_dml set_lob_size ""
        }
        text {
            set revision_id [db_exec_plsql new_text_revision {}]
        }
    }

    db_dml set_live_revision ""
    db_exec_plsql update_last_modified ""

    if {[string is false $suppress_notify_p]} {
	fs::do_notifications -folder_id $parent_id -filename $title -item_id $revision_id -action "new_version" -package_id $package_id
    }

    #It's safe to rebuild RSS repeatedly, assuming it's not too expensive.
    set folder_info [fs::get_folder_package_and_root $parent_id]
    set db_package_id [lindex $folder_info 0]
    if { [parameter::get -package_id $db_package_id -parameter ExposeRssP -default 0] } {
        fs::rss::build_feeds $parent_id
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
    {-storage_type ""}
    {-mime_type ""}
    -no_callback:boolean
} {
    Create a new version of a file storage item 
    @return revision_id
} {
    # always use the storage type of the existing item
    if {[string equal "" $storage_type]} {
        set storage_type [db_string get_storage_type ""]
    }
    if {[string equal "" $mime_type]} {
        set mime_type [cr_filename_to_mime_type -create -- $name]
    }

    set tmp_size [file size $tmp_filename]
    set parent_id [fs::get_parent -item_id $item_id]
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
	
    content::item::set_live_revision -revision_id $revision_id

    db_exec_plsql update_last_modified ""

    if {[string is false $suppress_notify_p]} {
	fs::do_notifications -folder_id $parent_id -filename $title -item_id $revision_id -action "new_version" -package_id $package_id
    }

    #It's safe to rebuild RSS repeatedly, assuming it's not too expensive.
    set folder_info [fs::get_folder_package_and_root $parent_id]
    set db_package_id [lindex $folder_info 0]
    if { [parameter::get -package_id $db_package_id -parameter ExposeRssP -default 0] } {
        fs::rss::build_feeds $parent_id
    }

    if {!$no_callback_p} {
	if {![catch {ad_conn package_id} package_id]} {
	    callback fs::file_revision_new -package_id $package_id -file_id $item_id -parent_id $parent_id
	}
    }

    return $revision_id
}

# modified 2006/08/11 (nfl) delete all symlinks
ad_proc fs::delete_file {
    -item_id
    {-parent_id ""}
    -no_callback:boolean
} {
    Deletes a file and all its revisions
} {

    set version_name [get_object_name -object_id $item_id]

    if {[empty_string_p $parent_id]} {
	set parent_id [fs::get_parent -item_id $item_id]
    }
    
    set folder_info [fs::get_folder_package_and_root $parent_id]
    set package_id [lindex $folder_info 0]

    # check if there were symlinks, if yes, delete them
    set all_symlinks [db_list get_all_symlinks {}]
    foreach symlink_id $all_symlinks {
	fs::delete_file -item_id $symlink_id
    }

    if {!$no_callback_p} {
	if {![catch {ad_conn package_id} package_id]} {
	    callback fs::file_delete -package_id $package_id -file_id $item_id
	}
    }

    db_exec_plsql delete_file ""

    fs::do_notifications -folder_id $parent_id -filename $version_name -item_id $item_id -action "delete_file"
}

ad_proc fs::delete_folder {
    -folder_id
    {-cascade_p "t"}
    {-parent_id ""}
    -no_callback:boolean
} {
    Deletes a folder and all contents
} {
    if {!$no_callback_p} {
	if {![catch {ad_conn package_id} package_id]} {
	    callback fs::folder_delete -package_id $package_id -folder_id $folder_id
	}
    }

    set version_name [get_object_name -object_id $folder_id]
    db_exec_plsql delete_folder ""

    if {[empty_string_p $parent_id]} {
	set parent_id [fs::get_parent -item_id $folder_id]
    }
    
    fs::do_notifications -folder_id $parent_id -filename $version_name -item_id $folder_id -action "delete_folder"
    
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

	if { [security::RestrictLoginToSSLP] } {
	    return "[security::get_secure_location]${webdav_prefix}${package_url}${url_stub}"
	} else {
	    return "[ad_url]${webdav_prefix}${package_url}${url_stub}"
	}

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
                  delete_folder
} {
    set package_and_root [fs::get_folder_package_and_root $folder_id]
    set root_folder [lindex $package_and_root 1]
    if {[string equal "" $package_id]} {
	set package_id [lindex $package_and_root 0]
    }

    if {[string equal $action "new_file"]} {
        set action_type "[_ file-storage.New_File_Uploaded]"
    } elseif {[string equal $action "new_url"]} {
        set action_type "[_ file-storage.New_URL_Uploaded]"
    } elseif {[string equal $action "new_version"]} {
        set action_type "[_ file-storage.lt_New_version_of_file_u]"
    } elseif {[string equal $action "delete_file"]} {
        set action_type "[_ file-storage.File_deleted]"
    } elseif {[string equal $action "delete_url"]} {
        set action_type "[_ file-storage.URL_deleted]"
    } elseif {[string equal $action "delete_folder"]} {
        set action_type "[_ file-storage.Folder_deleted]"
    } else {
        error "Unknown file-storage notification action: $action"
    }

    set url "[ad_url]"
    set new_content ""
    db_0or1row get_owner_name { }

    if {[string equal $action "new_file"] || [string equal $action "new_url"] || [string equal $action "new_version"]} {


        if {[string equal $action "new_version"]} {
            set sql "select description as description from cr_revisions 
                           where cr_revisions.revision_id = :item_id"
        } elseif {[string match "*folder" $action]} {
            set sql "select description from cr_folders where folder_id=:item_id"
        } else {
            set sql "select description as description from cr_revisions 
                           where cr_revisions.item_id = :item_id"
        }

        db_0or1row description $sql

    }
    db_1row path1 { }
    
    # Set email message body - "text only" for now
    set text_version ""
    append text_version "[_ file-storage.lt_Notification_for_File]\n"
    set folder_name [fs_get_folder_name $folder_id]
    append text_version "[_ file-storage.lt_File-Storage_folder_f]\n"

    if {[string equal $action "new_version"]} {
        append text_version "[_ file-storage.lt_New_Version_Uploaded_]\n"
    } else {
        append text_version "[_ file-storage.lt_Name_of_the_action_ty]\n"
    }
    if {[info exists owner]} {
        append text_version "[_ file-storage.Uploaded_by_ownern]\n"
    }
    if {[info exists description]} {
        append text_version "[_ file-storage.lt_Version_Notes_descrip]\n" 
    }

    set url_version "$url$path1?folder_id=$folder_id"
    append text_version "[_ file-storage.lt_View_folder_contents_]\n"
    
    set html_version [ad_html_text_convert -from text/plain -to text/html -- $text_version]
    append html_version "<br><br>"
    # Do the notification for the file-storage
    
    notification::new \
        -type_id [notification::type::get_type_id \
                      -short_name fs_fs_notif] \
        -object_id $folder_id \
        -notif_subject "[_ file-storage.lt_File_Storage_Notifica]" \
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
            -notif_subject "[_ file-storage.lt_File_Storage_Notifica]" \
            -notif_text $new_content \
	    -notif_html $html_version
        set folder_id $parent_id
    }
}

ad_proc -public fs::item_editable_info {
    -item_id:required
} {
    Returns an array containing elements editable_p, mime_type, file_extension
    if an fs item is editable through the browser, editable_p is set to 1
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-07-03
    
    @param item_id

    @return 
    
    @error 
} {
    # ideally, this would get values from parameters
    # hardcoding it for now
    set editable_mime_types [list "text/html" "text/plain"]

    item::get_mime_info [item::get_live_revision $item_id]

    if {[lsearch -exact $editable_mime_types [string tolower $mime_info(mime_type)]] != -1} {
        set mime_info(editable_p) 1
    } else {
        set mime_info(editable_p) 0
    }
    return [array get mime_info]
}

ad_proc -public fs::item_editable_p {
    -item_id:required
} {
    returns 1 if item is editable via browser
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-07-03
    
    @param item_id

    @return 
    
    @error 
} {
    array set item_editable_info [fs::item_editable_info -item_id $item_id]

    return $item_editable_info(editable_p)
}

ad_proc -public fs::get_object_info {
    -file_id:required
    -revision_id
} {
    returns an array containing the fs object info
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-07-03
    
    @param item_id

    @param revision_id

    @return 
    
    @error 
} {

    set user_id [ad_conn user_id]
    set root_folder_id [fs::get_root_folder]
    if {![exists_and_not_null revision_id]} {
        set revision_id [item::get_live_revision $file_id]
    }

    db_1row file_info {
	select r.item_id as file_id, r.revision_id,
	       r.mime_type, r.title, r.description,
	       r.content_length as content_size,
	       i.name, o.last_modified, i.parent_id,
	       i.storage_type, i.storage_area_key
	from cr_revisions r, cr_items i, acs_objects o
	where r.revision_id = :revision_id
	and r.item_id = i.item_id
	and i.item_id = :file_id
	and i.content_type = 'file_storage_object'
	and r.revision_id = o.object_id
    } -column_array file_object_info

    set content [db_exec_plsql get_content {
    }]

    if {[string equal $file_object_info(storage_type) file]} {
        set filename [cr_fs_path $file_object_info(storage_area_key)]
        append filename $content
        set fd [open $filename]
        set content [read $fd]
        close $fd
    }
    
    set file_object_info(content) $content
    return [array get file_object_info]
}

ad_proc -public fs::get_folder_package_and_root folder_id {

    Returns a two-element tcl list containing the package_id
    and root_folder_id for the passed-in folder_id.

    @author Andrew Grumet (aegrumet@alum.mit.edu)
    @creation-date 15 March 2004

} {

    db_1row select_package_and_root {}

    return [list $package_id $root_folder_id]
}

ad_proc -public fs::get_file_package_id {
    -file_id
} {
    Returns the package_id for a passed-in file_id. This is useful when
    using symlinks to files whose real root_folder_id is not the root_folder_id
    of the package the user is in.
    
    @author Stan Kaufman (skaufman@epimetrics.com)
    @creation-date 2005-09-07
    
    @param file_id

    @return package_id
    
} {
    return [db_string select_package_id {}]
}

namespace eval fs::notification {}

ad_proc -public fs::notification::get_url {
    object_id
} {
    returns a full url to the object_id.
    handles folders

    @param object_id
    
    @author Stan Kaufman (skaufman@epimetrics.com)
    @creation-date 2005-02-28
} { 
    set folder_id $object_id
    return "[ad_url][db_string select_fs_package_url {}]index?folder_id=$folder_id"
}

ad_proc -public fs::file_copy {
    {-file_id:required}
    {-target_folder_id:required}
    {-postfix ""}
    -symlink:boolean
} {
    copy file to target folder
    
    @param file_id Item_id of the file to be copied
    @param target_folder_id Folder ID of the folder to which the file is copied to
    @param postfix Postfix will be added with "_" to the new filename (not title). Very useful if you want to avoid unique name constraints on cr_items.
    @param symlink Defines if, instead of a full item, we should just add a symlink.
} {
    db_1row file_data {}

    if {![empty_string_p $postfix]} {
	set name [lang::util::localize "[file rootname $name]_$postfix[file extension $name]"]
    }

    if {$symlink_p} {
	return [content::symlink::new -name $name -label $title -target_id $file_id -parent_id $target_folder_id]
    } else {
	set user_id [ad_conn user_id]
	set creation_ip [ad_conn peeraddr]
	set file_path "[cr_fs_path][cr_create_content_file_path $file_id $file_rev_id]"

	# We need to check if the file already exists with the same name in the target folder
	# If yes, just add a new revision.
	
	set new_file_id [content::item::get_id_by_name -name $name -parent_id $target_folder_id]
	if {$new_file_id eq ""} {
	    set new_file_id [content::item::new \
				 -name $name \
				 -parent_id $target_folder_id \
				 -context_id $target_folder_id \
				 -item_subtype "content_item" \
				 -content_type "file_storage_object" \
				 -storage_type "file"]
	}

	# Now create the revision
	set new_file_rev_id [content::revision::copy \
				 -revision_id $file_rev_id \
				 -target_item_id $new_file_id \
				 -creation_user $user_id \
				 -creation_ip $creation_ip]
	
	set new_path [cr_create_content_file_path $new_file_id $new_file_rev_id]
	cr_create_content_file $new_file_id $new_file_rev_id $file_path
	
	if {![empty_string_p $postfix]} {
	    # set postfixed new title
	    db_dml update_title {}
	}

	content::item::set_live_revision -revision_id $new_file_rev_id
	
	return $new_file_id
    } 
}

ad_proc -public fs::file_copy {
    {-file_id:required}
    {-target_folder_id:required}
    {-postfix ""}
    -symlink:boolean
} {
    copy file to target folder
    
    @param file_id Item_id of the file to be copied
    @param target_folder_id Folder ID of the folder to which the file is copied to
    @param postfix Postfix will be added with "_" to the new filename (not title). Very useful if you want to avoid unique name constraints on cr_items.
    @param symlink Defines if, instead of a full item, we should just add a symlink.
} {
    db_1row file_data {}

    if {![empty_string_p $postfix]} {
	set name [lang::util::localize "[file rootname $name]_$postfix[file extension $name]"]
    }

    if {$symlink_p} {
	return [content::symlink::new -name $name -label $title -target_id $file_id -parent_id $target_folder_id]
    } else {
	set user_id [ad_conn user_id]
	set creation_ip [ad_conn peeraddr]
	set file_path "[cr_fs_path][cr_create_content_file_path $file_id $file_rev_id]"

	# We need to check if the file already exists with the same name in the target folder
	# If yes, just add a new revision.
	
	set new_file_id [content::item::get_id_by_name -name $name -parent_id $target_folder_id]
	if {$new_file_id eq ""} {
	    set new_file_id [content::item::new \
				 -name $name \
				 -parent_id $target_folder_id \
				 -context_id $target_folder_id \
				 -item_subtype "content_item" \
				 -content_type "file_storage_object" \
				 -storage_type "file"]
	}

	# Now create the revision
	set new_file_rev_id [content::revision::copy \
				 -revision_id $file_rev_id \
				 -target_item_id $new_file_id \
				 -creation_user $user_id \
				 -creation_ip $creation_ip]
	
	set new_path [cr_create_content_file_path $new_file_id $new_file_rev_id]
	cr_create_content_file $new_file_id $new_file_rev_id $file_path
	
	if {![empty_string_p $postfix]} {
	    # set postfixed new title
	    db_dml update_title {}
	}

	content::item::set_live_revision -revision_id $new_file_rev_id
	
	return $new_file_id
    } 
}

ad_proc -private fs::category_links {
    {-object_id:required}
    {-folder_id:required}
    {-selected_category_id ""}
    {-fs_url ""}
    {-joinwith ", "}
} {
    @param object_id the file storage object_id whose category list we creating
    @param folder_id the folder the category link should shearch on
    @param selected_category_id the category that has been selected and for which a link to return to the folder without that category limitation should exist
    @param fs_url is the file storage url for which these links will be created - defaults to the current package_url
    @param joinwith allows you to join the link list with something other than the default ", "

    @return a list of category_links to filter the supplied folder for a given category
} {
    if { $fs_url eq "" } {
	set fs_url [ad_conn package_url]
    }
    set selected_found_p 0
    set categories [list]
    foreach category_id [category::get_mapped_categories $object_id] {
	if { $category_id eq $selected_category_id } {
	    set selected_found_p 1
	    lappend categories "[category::get_name $category_id] <a href=\"[export_vars -base $fs_url -url {folder_id}]\">(x)</a>"
	} else {
	    lappend categories "<a href=\"[export_vars -base $fs_url -url {folder_id category_id}]\">[category::get_name $category_id]</a>"
	}
    }
    if { [string is false $selected_found_p] && $selected_category_id ne "" } {
	# we need to show the link to remove this category file at the
	# top of the folder
	lappend categories "[category::get_name $selected_category_id] <a href=\"[export_vars -base $fs_url -url {folder_id}]\">(x)</a>"
    }
    return [join $categories $joinwith]
}
