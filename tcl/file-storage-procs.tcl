ad_library {
    Tcl library for the file-storage system (v.4)
    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 November 2000
    @cvs-id $Id$
}

ad_proc fs_get_root_folder {
    {-package_id ""}
} {
    Returns the root folder for the file storage system.
} {
    if {$package_id eq ""} {
        set package_id [ad_conn package_id]
    }

    return [fs::get_root_folder -package_id $package_id]
}

ad_proc fs_get_folder_name {
    folder_id
} {
    Returns the name of a folder.
} {
    return [db_string folder_name {}]
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
    return [db_0or1row is_folder {
        select 1 from acs_objects
        where object_id = :folder_id
        and object_type = 'content_folder'}]
}

ad_proc fs_file_p {
    file_id
} {
    Returns 1 if the file_id corresponds to a file in the file-storage
    system.  Returns 0 otherwise.
} {
    return [db_0or1row is_file {
        select 1 from acs_objects
        where object_id = :file_id
        and object_type = 'content_item'}]
}

ad_proc fs_version_p {
    version_id
} {
    Returns 1 if the version_id corresponds to a version in the file-storage
    system.  Returns 0 otherwise.
} {
    return [db_0or1row is_version {
        select 1 from acs_objects
        where object_id = :version_id
        and object_type = 'file_storage_object'}]
}

#
# Permission procs
#

ad_proc -private fs_children_have_permission_p {
    {-user_id ""}
    item_id
    privilege
} {
    This procedure, given a content item and a privilege, checks to see if
    there are any children of the item on which the user does not have that
    privilege.

    @return 0 if there is any child item on which the user does not
    have the privilege.  It returns 1 if the user has the privilege on
    every child item.
} {
    if {$user_id eq ""} {
        set user_id [ad_conn user_id]
    }

    # Check that no item or revision over the whole cr_item
    # descendants hierarchy does not have the required permissison.
    set all_children_have_privilege_p [db_string all_children_have_privilege {
        with recursive children(item_id) as (
            select cast(:item_id as integer) as item_id
            union all
            select i.item_id
            from cr_items i,
                 children c
            where i.parent_id = c.item_id
        )
        select not exists (select 1 from children
                            where acs_permission.permission_p(item_id, :user_id, :privilege) = 'f')
           and not exists (select 1 from cr_revisions
                            where item_id in (select item_id from children)
                              and acs_permission.permission_p(revision_id, :user_id, :privilege) = 'f')
          from dual
    }]
    return [expr {$all_children_have_privilege_p ? 1 : 0}]
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
    if {$root_folder_id eq ""} {
        set root_folder_id [fs_get_root_folder]
    }

    if {$final eq ""
        && !($item_id == $root_folder_id)
    } {
        # don't get title for last element if we are in the
        # root folder
        set start_id [db_string parent_id {
            select parent_id from cr_items where item_id = :item_id
        }]
        set final [db_exec_plsql title {}]
    } else {
        set start_id $item_id
    }

    set extra_vars [concat &$extra_vars]

    set context_bar [db_list_of_lists context_bar {}]
    if {$item_id != $root_folder_id} {
        lappend context_bar $final
    }
    return $context_bar
}

namespace eval fs {}

ad_proc -private fs::after_mount {
    -package_id:required
    -node_id:required
} {
    Create root folder for package instance
    via Tcl callback.
} {
    set folder_id [fs::get_root_folder -package_id $package_id]

    if {[apm_package_installed_p oacs-dav]} {
        oacs_dav::register_folder -enabled_p "t" $folder_id $node_id
    }
}

ad_proc -private fs::before_unmount {
    -package_id:required
    -node_id:required
} {
    Unregister the root WebDAV folder mapping before
    unmounting a file storage package instance.
} {
    set folder_id [fs::get_root_folder -package_id $package_id]

    if {[apm_package_installed_p oacs-dav]} {
        oacs_dav::unregister_folder $folder_id $node_id
    }
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

    if {$package_id eq ""} {
        set package_id [ad_conn package_id]
    }

    if {$pretty_name eq ""} {
        set pretty_name [apm_instance_name_from_id $package_id]
    }

    if {$name eq ""} {
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
    if {$package_id eq ""} {
        set package_id [ad_conn package_id]
    }

    return [db_exec_plsql get_root_folder {}]
}

ad_proc -public fs::get_parent {
    -item_id:required
} {
    Get the parent of a given item.
} {
    return [db_string get_parent_id {}]
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
    @param creation_ip What is the IP address of the creation_user
    @param description of the folder. Not used in the current FS UI but might be used elsewhere.
    @param package_id Package_id of the package for which to create the new folder.
           Preferably a file storage package_id
    @param no_callback defines if the callback should be called. Defaults to yes
    @return folder_id of the newly created folder
} {
    if {$creation_user eq ""} {
        set creation_user [ad_conn user_id]
    }

    if {$creation_ip eq ""} {
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

    set folder_id [content::folder::new \
                       -name $name \
                       -label $pretty_name \
                       -parent_id $parent_id \
                       -creation_user $creation_user \
                       -creation_ip $creation_ip \
                       -description $description \
                       -package_id $package_id]
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
        callback fs::folder_edit \
            -package_id [ad_conn package_id] \
            -folder_id $folder_id
    }
}

ad_proc -public fs::set_folder_description {
    {-folder_id:required}
    {-description ""}
} {
    sets the description for the given folder in cr_folders. Perhaps this should be a CR proc?
} {
    db_dml set_folder_description {}
}

ad_proc -public fs::object_p {
    {-object_id:required}
} {
    is this a file storage object
} {
    if {![string is integer -strict $object_id]} {
        return 0
    }
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
    the filesystem
} {
    return [ad_sanitize_filename \
                -collapse_spaces \
                -tolower \
                [get_object_name -object_id $object_id]]
}

ad_proc -deprecated -public fs::remove_special_file_system_characters {
    {-string:required}
} {
    Remove unsafe filesystem characters. Useful if you want to use $string
    as the name of an object to write to disk.

    @see ad_sanitize_filename
} {
    regsub -all -- {[<>:\"|/@\#%&+\\]} $string {_} string
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
    Retrieve the folder_id of a folder given its name and parent folder.

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
    return [db_list select_folder_contents {
        select cr_items.item_id as object_id, cr_items.name
        from   cr_items
        where  cr_items.parent_id = :folder_id
        and    acs_permission.permission_p(cr_items.item_id, :user_id, 'read') = 't'
    }]
}

ad_proc -public fs::get_folder_contents {
    {-folder_id ""}
    {-user_id ""}
    {-n_past_days "99999"}
} {
    WARNING: This proc is not scalable because it does too many permission checks.

    DRB: Not so true now that permissions are fast.  However, it is now only used
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
    if {$folder_id eq ""} {
        set folder_id [get_root_folder -package_id [ad_conn package_id]]
    }

    if {$user_id eq ""} {
        set user_id [acs_magic_object the_public]
    }

    set list_of_ns_sets [db_list_of_ns_sets select_folder_contents [subst {
           select fs_objects.object_id,
           fs_objects.name,
           fs_objects.title,
           fs_objects.live_revision,
           fs_objects.type,
           to_char(fs_objects.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,
           fs_objects.content_size,
           fs_objects.url,
           fs_objects.key,
           fs_objects.sort_key,
           fs_objects.file_upload_name,
           fs_objects.title,
           fs_objects.last_modified >= (current_timestamp - cast('$n_past_days days' as interval)) as new_p,
           acs_permission.permission_p(fs_objects.object_id, :user_id, 'admin') as admin_p,
           acs_permission.permission_p(fs_objects.object_id, :user_id, 'delete') as delete_p,
           acs_permission.permission_p(fs_objects.object_id, :user_id, 'write') as write_p
           from fs_objects
           where fs_objects.parent_id = :folder_id
           and acs_permission.permission_p(fs_objects.object_id, :user_id, 'read') = 't'
           order by fs_objects.sort_key, fs_objects.name
    }]]

    foreach set $list_of_ns_sets {
        # in plain Tcl:
        # set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]
        ns_set put $set last_modified_ansi [lc_time_system_to_conn [ns_set get $set last_modified_ansi]]

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

    @param user_id DEPRECATED since commit 2002-02-22 by Yonatan
                   Feldman (yon@milliped.com) this parameter doesn't
                   have any effect. It was used to count only items
                   where user had read permission, but was considered
                   unscalable.
} {
    if {$folder_id eq ""} {
        set folder_id [get_root_folder -package_id [ad_conn package_id]]
    }

    if {$user_id ne ""} {
        ns_log warning "fs::get_folder_contents_count:" \
            "specified -user_id doesn't have any effect on proc result"
    }

    return [db_string select_folder_contents_count {}]
}

ad_proc -public fs::publish_object_to_file_system {
    {-object_id:required}
    {-path ""}
    {-file_name ""}
    {-user_id ""}
} {
    publish a file storage object to the filesystem
} {
    if {$path eq ""} {
        set path [ad_tmpnam]
    }

    db_1row select_object_info {}

    switch -- $type {
        folder {
            set result [publish_folder_to_file_system \
                            -folder_id $object_id \
                            -path $path \
                            -folder_name $name \
                            -user_id $user_id]
        }
        url {
            set result [publish_url_to_file_system \
                            -object_id $object_id \
                            -path $path \
                            -file_name $file_name]
        }
        symlink {
            set linked_object_id [content::symlink::resolve -item_id $object_id]
            set result [publish_versioned_object_to_file_system \
                            -object_id $linked_object_id \
                            -path $path \
                            -file_name $file_name]
        }
        default {
            set result [publish_versioned_object_to_file_system \
                            -object_id $object_id \
                            -path $path \
                            -file_name $file_name]
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
    publish the contents of a file storage folder to the filesystem
} {
    if {$path eq ""} {
        set path [ad_tmpnam]
    }

    if {$folder_name eq ""} {
        set folder_name [get_object_name -object_id $folder_id]
    }
    set folder_name [ad_sanitize_filename \
                         -collapse_spaces \
                         -tolower \
                         $folder_name]

    set dir [ad_file join $path $folder_name]
    # set dir [ad_file join $path "download"]
    file mkdir $dir

    foreach object [get_folder_contents -folder_id $folder_id -user_id $user_id] {
        set file_name [ad_sanitize_filename \
                           -collapse_spaces \
                           -tolower \
                           [ns_set get $object name]]
        publish_object_to_file_system \
            -object_id [ns_set get $object object_id] \
            -path $dir \
            -file_name $file_name \
            -user_id $user_id
    }

    return $dir
}

ad_proc -public fs::publish_url_to_file_system {
    {-object_id:required}
    {-path ""}
    {-file_name ""}
} {
    publish a URL object to the filesystem as a Windows shortcut
    (which at least KDE also knows how to handle)
} {
    if {$path eq ""} {
        set path [ad_mktmpdir]
    }

    db_1row select_object_metadata {}

    if {$file_name eq ""} {
        set file_name $name
    }
    set file_name "${file_name}.url"
    set file_name [ad_sanitize_filename \
                       -collapse_spaces \
                       -tolower \
                       $file_name]

    set fp [open [ad_file join $path $file_name] w]
    puts $fp {[InternetShortcut]}
    puts $fp URL=$url
    close $fp

    return [ad_file join $path $file_name]
}

ad_proc -public fs::publish_versioned_object_to_file_system {
    {-object_id:required}
    {-path ""}
    {-file_name ""}
} {
    publish an object to the filesystem
} {
    if {$path eq ""} {
        set path [ad_mktmpdir]
    }

    db_1row select_object_metadata {}

    # After upgrade change title and filename...
    set like_filesystem_p [parameter::get -parameter BehaveLikeFilesystemP -default 1]

    if { $like_filesystem_p } {
        set file_name $title
        if {$file_name eq ""} {
            if {![info exists upload_file_name]} {
                set file_name "unnamedfile"
            } else {
                set file_name $file_upload_name
            }
        } elseif {[content::item::get -item_id $object_id -array_name item_info]} {
            # We make sure that the file_name contains the file
            # extension at the end so that the users default
            # application for that file type can be used

            set mime_type $item_info(mime_type)
            set file_extension [db_string get_extension {
                select file_extension from cr_mime_types where mime_type = :mime_type
            }]

            if { ![regexp "\.$file_extension$" $file_name match] } {
                set file_name "$file_name.$file_extension"
            }
        }
    } else {
        set file_name $file_upload_name
    }

    set file_name [ad_sanitize_filename \
                       -collapse_spaces \
                       -tolower \
                       $file_name]

    set full_filename [ad_file join $path $file_name]
    ::content::revision::export_to_filesystem \
        -storage_type $storage_type \
        -revision_id $live_revision \
        -filename $full_filename

    return $full_filename
}

ad_proc -public fs::get_archive_command {
    {-in_file ""}
    {-out_file ""}
} {
    return the archive command after replacing {in_file} and {out_file} with
    their respective values.
} {
    set cmd [parameter::get -parameter ArchiveCommand -default "tar cf - {in_file} | gzip > {out_file}"]

    regsub -all -- {(\W)} $in_file {\\\1} in_file
    regsub -all -- {\\/} $in_file {/} in_file
    regsub -all -- {\\\.} $in_file {.} in_file

    regsub -all -- {(\W)} $out_file {\\\1} out_file
    regsub -all -- {\\/} $out_file {/} out_file
    regsub -all -- {\\\.} $out_file {.} out_file

    regsub -all -- {{in_file}} $cmd $in_file cmd
    regsub -all -- {{out_file}} $cmd $out_file cmd

    return $cmd
}

ad_proc -public fs::get_archive_extension {} {
    return the archive extension that should be added to the output file of
    an archive command
} {
    return [parameter::get -parameter ArchiveExtension -default "txt"]
}

ad_proc -public fs::get_item_id {
    -name:required
    {-folder_id ""}
} {
    Get the item_id of a file
} {
    if {$folder_id eq ""} {
        set folder_id [fs_get_root_folder -package_id [ad_conn package_id]]
    }
    return [content::item::get_id \
                -item_path      $name \
                -root_folder_id $folder_id \
                -resolve_index "f"]
}

ad_proc -public fs::add_file {
    -name:required
    -parent_id:required
    -package_id:required
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

    # This check also happens in content repository, but as something
    # similar was already here and mimetype coming from this was used
    # afterwards, we kept this behavior.
    set mime_type [cr_check_mime_type \
                       -filename  $name \
                       -mime_type $mime_type \
                       -file      $tmp_filename]

    # we have to do this here because we create the object before
    # calling cr_import_content

    if {[content::type::content_type_p -mime_type $mime_type -content_type "image"]} {
        set content_type image
    } else {
        set content_type file_storage_object
    }

    if {$item_id eq ""} {
        set item_id [db_nextval acs_object_id_seq]
    }

    db_transaction {
        if {![db_string item_exists {}]} {

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

            if {$creation_user ne ""} {
                permission::grant -party_id $creation_user -object_id $item_id -privilege admin
            }

            # Deal with notifications. Usually, send out the notification
            # But suppress it if the parameter is given
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
            fs::do_notifications \
                -folder_id $parent_id \
                -filename $title \
                -item_id $revision_id \
                -action "new_file" \
                -package_id $package_id

            if {!$no_callback_p} {
                callback fs::file_new \
                    -package_id [ad_conn package_id] \
                    -file_id $item_id
            }
        }
    }
    return $revision_id
}

ad_proc -deprecated fs::add_created_file {
    {-name ""}
    -parent_id:required
    -package_id:required
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

    DEPRECATED: this proc was superseded by fs::add_file

    @see fs::add_file

    @return revision_id
} {
    if {[parameter::get -parameter "StoreFilesInDatabaseP" -package_id $package_id]} {
        set indbp "t"
        set storage_type "lob"
    } else {
        set indbp "f"
        set storage_type "file"
    }
    if {$item_id ne ""} {
        set storage_type [db_string get_storage_type {
            select storage_type from cr_items where item_id=:item_id
        }]
    }
    if {$mime_type eq "" } {
        set mime_type "text/html"
    }
    if { $name eq "" } {
        set name $title
    }

    set content_type "file_storage_object"

    db_transaction {
        if {$item_id eq "" || ![db_string item_exists {}]} {
            set item_id [db_exec_plsql create_item ""]
            if {$creation_user ne ""} {
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
            fs::do_notifications \
                -folder_id $parent_id \
                -filename $title \
                -item_id $revision_id \
                -action "new_file" \
                -package_id $package_id
        }

        if {!$no_callback_p} {
            callback fs::file_new \
                -package_id [ad_conn package_id] \
                -file_id $item_id
        }
    }
    return $revision_id
}

ad_proc -deprecated fs::add_created_version {
    -name:required
    -content_body:required
    -mime_type:required
    -item_id:required
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

    DEPRECATED: this proc has been superseded by fs::add_version

    @see fs::add_version

    @return revision_id
} {
    if {$package_id eq ""} {
        set package_id [ad_conn package_id]
    }
    if {$storage_type eq ""} {
        set storage_type [db_string get_storage_type {
            select storage_type from cr_items where item_id = :item_id
        }]
    }
    if {$creation_user eq ""} {
        set creation_user [ad_conn user_id]
    }
    if {$creation_ip eq ""} {
        set creation_ip [ns_conn peeraddr]
    }

    set revision_id [content::revision::new \
                         -item_id $item_id \
                         -title $title \
                         -description $description \
                         -content $content_body \
                         -mime_type $mime_type \
                         -creation_user $creation_user \
                         -creation_ip $creation_ip \
                         -package_id $package_id \
                         -is_live "t" \
                         -storage_type $storage_type]

    set parent_id [fs::get_parent -item_id $item_id]

    if {[string is false $suppress_notify_p]} {
        fs::do_notifications \
            -folder_id $parent_id \
            -filename $title \
            -item_id $revision_id \
            -action "new_version" \
            -package_id $package_id
    }

    #
    # It is safe to rebuild RSS repeatedly, assuming it's not too
    # expensive.
    #
    set folder_info [fs::get_folder_package_and_root $parent_id]
    set db_package_id [lindex $folder_info 0]
    if { [parameter::get -package_id $db_package_id -parameter ExposeRssP -default 0] } {
        fs::rss::build_feeds $parent_id
    }

    return $revision_id
}


ad_proc fs::add_version {
    -item_id:required
    {-name ""}
    {-package_id ""}
    {-mime_type ""}
    -tmp_filename
    -content_body
    {-creation_user ""}
    {-creation_ip ""}
    {-title ""}
    {-description ""}
    {-suppress_notify_p "f"}
    {-storage_type ""}
    -no_callback:boolean
} {
    Create a new version of a file storage item.

    @param tmp_filename absolute path to a file on the
                        filesystem. when specified, the new revision
                        data will come from this file.
    @param content_body Text content for the new revision. When
                        'tmp_filename' is missing, the new revision
                        data will come from here.

    @return revision_id
} {
    if {![info exists content_body] && ![info exists tmp_filename]} {
        error "No data supplied for the new version."
    }

    #
    # Obtain optional information for the new version from the
    # existing item.
    #
    db_1row get_item_info {
        select coalesce(:storage_type, i.storage_type) as storage_type,
               coalesce(:name, i.name) as name,
               coalesce(:package_id, o.package_id) as package_id,
               coalesce(:title, r.title) as title,
               coalesce(:description, r.description) as description,
               coalesce(:mime_type, r.mime_type) as mime_type,
               i.parent_id
        from cr_items i
             -- we may not have a live revision here yet
             left join cr_revisions r
               on r.revision_id = i.live_revision,
             acs_objects o
        where i.item_id = :item_id
          and o.object_id = i.item_id
    }

    #
    # Obtain other possibly missing information from the connection
    # context.
    #
    if {$package_id eq ""} {
        set package_id [ad_conn package_id]
    }
    if {$creation_user eq ""} {
        set creation_user [ad_conn user_id]
    }
    if {$creation_ip eq ""} {
        set creation_ip [ns_conn peeraddr]
    }

    if {[info exists tmp_filename]} {
        #
        # The new revision will come from a file.
        #

        # This check also happens in content repository, but as something
        # similar was already here and mimetype coming from this was used
        # afterwards, we kept this behavior.
        set mime_type [cr_check_mime_type \
                           -filename  $name \
                           -mime_type $mime_type \
                           -file      $tmp_filename]

        set tmp_size [ad_file size $tmp_filename]
        set revision_id [cr_import_content \
                             -item_id $item_id \
                             -storage_type $storage_type \
                             -creation_user $creation_user \
                             -creation_ip $creation_ip \
                             -other_type "file_storage_object" \
                             -image_type "file_storage_object" \
                             -title $title \
                             -description $description \
                             -package_id $package_id \
                             $parent_id \
                             $tmp_filename \
                             $tmp_size \
                             $mime_type \
                             $name]

        content::item::set_live_revision -revision_id $revision_id
    } else {
        #
        # The new revision will come from text content.
        #

        set revision_id [content::revision::new \
                             -item_id $item_id \
                             -title $title \
                             -description $description \
                             -content $content_body \
                             -mime_type $mime_type \
                             -creation_user $creation_user \
                             -creation_ip $creation_ip \
                             -package_id $package_id \
                             -is_live "t" \
                             -storage_type $storage_type]
    }

    # apisano - This is what we had before (postgres code):
    # begin
    # perform acs_object__update_last_modified
    # (:parent_id,:creation_user,:creation_ip);
    # perform
    # acs_object__update_last_modified(:item_id,:creation_user,:creation_ip);
    # return null;
    # end;
    # Could be refactored with the recursive query below, which will
    # not go over the context hierarchy, but over the "filesystem"
    # hierarchy, which makes more sense, and update modification
    # metadata for the whole tree.
    # However, I wonder if there is really need for all of this... If
    # there is, one should probably have this logic at the content
    # repository level, rather than here.
    db_dml update_last_modified {
        with recursive fs_hierarchy as (
            select object_id, parent_id
              from fs_objects
             where object_id = :item_id

            union

            select p.object_id, p.parent_id
              from fs_objects p,
                   fs_hierarchy c
             where p.object_id = c.parent_id
        )
        update acs_objects set
          modifying_user = :creation_user,
          modifying_ip   = :creation_ip,
          last_modified  = current_timestamp
        where object_id in (select object_id from fs_hierarchy)
    }

    if {[string is false $suppress_notify_p]} {
        fs::do_notifications \
            -folder_id $parent_id \
            -filename $title \
            -item_id $revision_id \
            -action "new_version" \
            -package_id $package_id
    }

    #It's safe to rebuild RSS repeatedly, assuming it's not too expensive.
    set folder_info [fs::get_folder_package_and_root $parent_id]
    set db_package_id [lindex $folder_info 0]
    if { [parameter::get -package_id $db_package_id -parameter ExposeRssP -default 0] } {
        fs::rss::build_feeds $parent_id
    }

    if {!$no_callback_p} {
        callback fs::file_revision_new \
            -package_id [ad_conn package_id] \
            -file_id $item_id \
            -parent_id $parent_id
    }

    return $revision_id
}

# modified 2006/08/11 (nfl) delete all symlinks
ad_proc fs::delete_file {
    -item_id:required
    {-parent_id ""}
    -no_callback:boolean
} {
    Deletes a file and all its revisions
} {

    set version_name [get_object_name -object_id $item_id]

    if {$parent_id eq ""} {
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
        callback fs::file_delete \
            -package_id [ad_conn package_id] \
            -file_id $item_id
    }

    fs::do_notifications \
        -folder_id $parent_id \
        -filename $version_name \
        -item_id $item_id \
        -action "delete_file"

    db_exec_plsql delete_file {}
}

ad_proc fs::delete_folder {
    -folder_id:required
    {-cascade_p "t"}
    {-parent_id ""}
    -no_callback:boolean
    -no_notifications:boolean
} {
    Deletes a folder and all contents
} {
    if {!$no_callback_p} {
        callback fs::folder_delete \
            -package_id [ad_conn package_id] \
            -folder_id $folder_id
    }

    if {$parent_id eq ""} {
        set parent_id [fs::get_parent -item_id $folder_id]
    }

    set version_name [get_object_name -object_id $folder_id]

    if { !$no_notifications_p } {
        fs::do_notifications \
            -folder_id $parent_id \
            -filename $version_name \
            -item_id $folder_id \
            -action "delete_folder"
    }

    db_exec_plsql delete_folder {}
}

ad_proc fs::delete_version {
    -item_id:required
    -version_id:required
} {
    Deletes a revision. If it was the last revision, it deletes
    the file as well.
} {
    set parent_id [db_exec_plsql delete_version {}]

    if {$parent_id > 0} {
        delete_file -item_id $item_id -parent_id $parent_id
    }
    return $parent_id
}

ad_proc -private fs::webdav_p {} {
    Returns if webDAV is enabled.

    @return boolean
} {
    return [expr {
                  [parameter::get -parameter "UseWebDavP" -default 0] &&
                  [apm_package_installed_p oacs-dav]
              }]
}

ad_proc fs::webdav_url {
    -item_id:required
    {-root_folder_id ""}
    {-package_id ""}
} {
    Provide URL for webdav access to file or folder

    @param item_id folder_id or item_id of file-storage folder or file
    @param root_folder_id root folder to resolve URL from

    @return fully qualified URL for WebDAV access or empty string if
            item is not WebDAV enabled
} {

    if {![fs::webdav_p]} {
        return ""
    }
    if {$package_id eq ""} {
        set package_id [ad_conn package_id]
    }

    if {$root_folder_id eq ""} {
        set root_folder_id [fs::get_root_folder -package_id $package_id]
    }

    if {"t" eq [oacs_dav::folder_enabled -folder_id $root_folder_id]} {
        if {$root_folder_id eq $item_id} {
            set url_stub ""
        } else {
            set url_stub [content::item::get_virtual_path -root_folder_id $root_folder_id -item_id $item_id]
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
    {-action:required}
} {
    Send notifications for file-storage operations.

    Note that not all possible operations are implemented, e.g. move, copy etc. See documentation.

    @param action The kind of operation. One of: new_file, new_version,
                  new_url, delete_file, delete_url, delete_folder
} {
    set package_and_root [fs::get_folder_package_and_root $folder_id]
    set root_folder [lindex $package_and_root 1]
    if {$package_id eq ""} {
        set package_id [lindex $package_and_root 0]
    }

    switch $action {
        "new_file" {
            set action_type "[_ file-storage.New_File_Uploaded]"
        }
        "new_url" {
            set action_type "[_ file-storage.New_URL_Uploaded]"
        }
        "new_version" {
            set action_type "[_ file-storage.lt_New_version_of_file_u]"
        }
        "delete_file" {
            set action_type "[_ file-storage.File_deleted]"
        }
        "delete_url" {
            set action_type "[_ file-storage.URL_deleted]"
        }
        "delete_folder" {
            set action_type "[_ file-storage.Folder_deleted]"
        }
        default {
            error "Unknown file-storage notification action: $action"
        }
    }

    set url "[ad_url]"
    set new_content ""
    set creation_user [acs_object::get_element \
                           -object_id $item_id \
                           -element creation_user]
    set owner [person::name -person_id $creation_user]

    if {$action in {"new_file" "new_url" "new_version"}} {

        if {$action eq "new_version"} {
            set sql "select description as description from cr_revisions
                           where cr_revisions.revision_id = :item_id"
        } else {
            set sql "select description as description from cr_revisions
                           where cr_revisions.item_id = :item_id"
        }

        db_0or1row description $sql

    }
    set root_folder_package_id [db_string get_package_id {
        select package_id from fs_root_folders
        where folder_id = :root_folder
    }]
    set path1 [site_node::get_url_from_object_id \
                   -object_id $root_folder_package_id]

    # Set email message body - "text only" for now
    set text_version ""
    append text_version "[_ file-storage.lt_Notification_for_File]\n"
    set folder_name [fs_get_folder_name $folder_id]
    append text_version "[_ file-storage.lt_File-Storage_folder_f]\n"

    if {$action eq "new_version"} {
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
        set parent_id [db_string parent_id {
            select parent_id from cr_items where item_id = :folder_id
        }]
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

ad_proc -deprecated fs::item_editable_info {
    -item_id:required
} {
    Returns an array containing elements editable_p, mime_type, file_extension
    if an fs item is editable through the browser, editable_p is set to 1

    DEPRECATED: it is unclear what editable is supposed to mean. As of
    2023-03-16 file-storage does not offer inline editing and no
    package, including file-storage itself, appears to be using this
    api.

    @see nothing

    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-07-03

    @param item_id

    @return

    @error
} {
    # ideally, this would get values from parameters
    # hardcoding it for now
    set editable_mime_types [list "text/html" "text/plain"]

    content::item::get -item_id $item_id -array_name item_info
    set mime_info(mime_type) [set mime_type $item_info(mime_type)]
    set mime_info(file_extension) [db_string get_extension {
        select file_extension from cr_mime_types where mime_type = :mime_type
    }]

    if {[string tolower $mime_info(mime_type)] in $editable_mime_types} {
        set mime_info(editable_p) 1
    } else {
        set mime_info(editable_p) 0
    }
    return [array get mime_info]
}

ad_proc -deprecated fs::item_editable_p {
    -item_id:required
} {
    returns 1 if item is editable via browser

    DEPRECATED: it is unclear what editable is supposed to mean. As of
    2023-03-16 file-storage does not offer inline editing and no
    package, including file-storage itself, appears to be using this
    api.

    @see nothing

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
    Returns an array containing the fs object info.

    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-07-03

    @param file_id Id of the file
    @param revision_id Id of the revision

    @return

    @error
} {
    if {![info exists revision_id] || $revision_id eq ""} {
        set revision_id [content::item::get_live_revision -item_id $file_id]
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

    # GN: this query was probably never defined in CVS
    #set content [db_exec_plsql get_content {}]

    if {$file_object_info(storage_type) eq "file"} {
        set file_object_info(cr_file_path) [content::revision::get_cr_file_path \
                                                -revision_id $revision_id]
    }

    return [array get file_object_info]
}

ad_proc -public fs::get_folder_package_and_root folder_id {

    Returns a two-element Tcl list containing the package_id
    and root_folder_id for the passed-in folder_id.

    @author Andrew Grumet (aegrumet@alum.mit.edu)
    @creation-date 15 March 2004

} {

    db_1row select_package_and_root {}

    return [list $package_id $root_folder_id]
}

ad_proc -public fs::get_file_package_id {
    -file_id:required
} {
    Returns the package_id for a passed-in file_id. This is useful when
    using symlinks to files whose real root_folder_id is not the root_folder_id
    of the package the user is in.

    @author Stan Kaufman (skaufman@epimetrics.com)
    @creation-date 2005-09-07

    @param file_id

    @return package_id

} {
    return [db_string select_package_id {
        with recursive hierarchy as
        (
         select package_id, context_id
         from acs_objects
         where object_id = :file_id

         union

         select o.package_id, o.context_id
         from acs_objects o, hierarchy h
         where object_id = h.context_id
           and h.package_id is null
         )
        select package_id from hierarchy
        where package_id is not null
    } -default ""]
}

namespace eval fs::notification {}

ad_proc -private fs::notification::get_url {
    object_id:required
} {
    This proc implements the GetURL operation of the NotificationType
    Service Contract and should not be invoked directly.

    @return a full URL to the object_id. Handles folders.

    @param object_id

    @author Stan Kaufman (skaufman@epimetrics.com)
    @creation-date 2005-02-28
} {
    set folder_id $object_id
    set package_id [lindex [fs::get_folder_package_and_root $folder_id] 0]
    set fs_package_url [lindex [site_node::get_url_from_object_id -object_id $package_id] 0]
    return "[ad_url]${fs_package_url}index?folder_id=$folder_id"
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
    @param postfix Postfix will be added with "_" to the new filename (not title).
           Very useful if you want to avoid unique name constraints on cr_items.
    @param symlink Defines if, instead of a full item, we should just add a symlink.
} {
    db_1row file_data {}

    if {$postfix ne ""} {
        set name [lang::util::localize "[ad_file rootname $name]_$postfix[ad_file extension $name]"]
    }

    if {$symlink_p} {
        return [content::symlink::new \
                    -name $name \
                    -label $title \
                    -target_id $file_id \
                    -parent_id $target_folder_id]
    } else {
        set user_id [ad_conn user_id]
        set creation_ip [ad_conn peeraddr]
        #set file_path "[cr_fs_path][cr_create_content_file_path $file_id $file_rev_id]"
        set file_path [content::revision::get_cr_file_path -revision_id $file_rev_id]

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

        #set new_path [cr_create_content_file_path $new_file_id $new_file_rev_id]
        cr_create_content_file $new_file_id $new_file_rev_id $file_path

        if {$postfix ne ""} {
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
    @param postfix Postfix will be added with "_" to the new filename (not title).
           Very useful if you want to avoid unique name constraints on cr_items.
    @param symlink Defines if, instead of a full item, we should just add a symlink.
} {
    db_1row file_data {}

    if {$postfix ne ""} {
        set name [lang::util::localize "[ad_file rootname $name]_$postfix[ad_file extension $name]"]
    }

    if {$symlink_p} {
        return [content::symlink::new \
                    -name $name \
                    -label $title \
                    -target_id $file_id \
                    -parent_id $target_folder_id]
    } else {
        set user_id [ad_conn user_id]
        set creation_ip [ad_conn peeraddr]
        #set file_path "[cr_fs_path][cr_create_content_file_path $file_id $file_rev_id]"
        set file_path [content::revision::get_cr_file_path -revision_id $file_rev_id]

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

        #set new_path [cr_create_content_file_path $new_file_id $new_file_rev_id]
        cr_create_content_file $new_file_id $new_file_rev_id $file_path

        if {$postfix ne ""} {
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
    @param selected_category_id the category that has been selected and for
           which a link to return to the folder without that category limitation should exist
    @param fs_url is the file storage url for which these links will be created -
           defaults to the current package_url
    @param joinwith allows you to join the link list with something other than the default ", "

    @return a list of category_links to filter the supplied folder for a given category
} {
    if { $fs_url eq "" } {
        set fs_url [ad_conn package_url]
    }
    set selected_found_p 0
    set categories [list]
    foreach category_id [category::get_mapped_categories $object_id] {
        set name [category::get_name $category_id]
        if { $category_id eq $selected_category_id } {
            set selected_found_p 1
            set href [export_vars -base $fs_url -url {folder_id}]
            lappend categories "[ns_quotehtml $name] <a href=\"[ns_quotehtml $href]\">(x)</a>"
        } else {
            set href [export_vars -base $fs_url -url {folder_id category_id}]
            lappend categories "<a href=\"[ns_quotehtml $href]\">[ns_quotehtml $name]</a>"
        }
    }
    if { [string is false $selected_found_p] && $selected_category_id ne "" } {
        # we need to show the link to remove this category file at the
        # top of the folder
        set href [export_vars -base $fs_url -url {folder_id}]
        set name [category::get_name $selected_category_id]
        lappend categories "[ns_quotehtml $name] <a href=\"[ns_quotehtml $href]\">(x)</a>"
    }
    return [join $categories $joinwith]
}

ad_proc -private fs::unit_conv {value} {

    Convert units to value. This should done more generic, ... we have
    in NaviServer c-level support for this which should be used if
    available in the future.

} {
    if {[regexp {^([0-9.]+)\s*(MB|KB)} $value . number unit]} {
        set value [expr {int($number * ($unit eq "KB" ? 1024 : 1024*1024))}]
    }
    return $value
}

ad_proc -public fs::max_upload_size {
    {-package_id ""}
} {
    @param package_id id of the file-storage package instance. Will
           default to the connection package_id if not specified.

    Returns the maximum upload size for this file-storage instance. If
    the value from the parameter is empty, invalid, or bigger than
    the server-wide upload limit, the latter will take over.

    @return numeric value in bytes
} {
    set max_bytes_param [fs::unit_conv [parameter::get \
                                            -package_id $package_id \
                                            -parameter "MaximumFileSize"]]
    if {![string is double -strict $max_bytes_param]} {
        set max_bytes_param Inf
    }

    set driver [expr {[ns_conn isconnected] ?
                      [ns_conn driver] :
                      [lindex [ns_driver names] 0]}]
    set section [ns_driversection -driver $driver]
    set max_bytes_conf [fs::unit_conv  [ns_config $section maxinput]]
    return [expr {min($max_bytes_param,$max_bytes_conf)}]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
