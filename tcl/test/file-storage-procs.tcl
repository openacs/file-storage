ad_library {
    Automated tests.

    @author Simon Carstensen
    @creation-date 14 November 2003
    @cvs-id $Id$
}

aa_register_case \
    -cats {api smoke} \
    -procs {
        permission::set_not_inherit
        site_node::instantiate_and_mount
        content::folder::register_content_type
        content::symlink::new
        fs::add_file
        fs::new_folder
        fs::get_folder_objects
        fs::webdav_url
        fs::get_file_package_id
        fs::publish_versioned_object_to_file_system
        fs::publish_url_to_file_system
        fs::publish_object_to_file_system
        fs::publish_folder_to_file_system
    } \
    fs_publish_file {

        Test that exporting a file to the filesystem works.

    } {
        set user_id [dict get [acs::test::user::create] user_id]

        aa_run_with_teardown -rollback -test_code {
            aa_log "Create a root folder"
            set package_id [site_node::instantiate_and_mount \
                                -package_key file-storage \
                                -node_name __[clock seconds]_file_storage]
            permission::set_not_inherit -object_id $package_id

            set root_folder_id [fs::get_root_folder -package_id $package_id]

            aa_log "Create a folder"

            set folder_id [fs::new_folder \
                               -name __test_fs_folder_1 \
                               -pretty_name __test_fs_folder_1_pretty \
                               -parent_id $root_folder_id]

            set revisions [list]

            set content "This is a test file 1"
            set wfd [ad_opentmpfile tmp_filename]
            puts $wfd $content
            close $wfd

            lappend revisions [fs::add_file \
                                   -name __test_fs_publish_file_1 \
                                   -parent_id $folder_id \
                                   -package_id $package_id \
                                   -tmp_filename $tmp_filename]

            set content "This is a test file 2"
            set wfd [ad_opentmpfile tmp_filename]
            puts $wfd $content
            close $wfd

            lappend revisions [fs::add_file \
                                   -name __test_fs_publish_file_2 \
                                   -parent_id $folder_id \
                                   -package_id $package_id \
                                   -tmp_filename $tmp_filename]


            set content "This is a test file 3"
            set wfd [ad_opentmpfile tmp_filename]
            puts $wfd $content
            close $wfd

            lappend revisions [fs::add_file \
                                   -name __test_fs_publish_file_3 \
                                   -parent_id $folder_id \
                                   -package_id $package_id \
                                   -tmp_filename $tmp_filename]

            aa_equals "fs::get_folder_objects returns nothing for unprivileged user" \
                [fs::get_folder_objects -folder_id $folder_id -user_id $user_id] \
                ""

            set security_root [acs_magic_object security_context_root]
            set swa_id [db_string get_swa {
                select max(user_id) from users u
                where acs_permission.permission_p(:security_root, u.user_id, 'admin')
            }]
            aa_equals "fs::get_folder_objects returns expected for SWA" \
                [lsort [fs::get_folder_objects -folder_id $folder_id -user_id $swa_id]] \
                [lsort [db_list query "select item_id from cr_items where live_revision in ([join $revisions ,])"]]

            set revision_id [lindex $revisions end]

            set item_id [db_string get_item_id {
                select item_id from cr_revisions
                where revision_id = :revision_id
            }]

            set webdav_url [fs::webdav_url \
                                -item_id $item_id \
                                -package_id $package_id \
                                -root_folder_id $root_folder_id]
            if {[fs::webdav_p] && [oacs_dav::folder_enabled -folder_id $root_folder_id]} {
                set url_stub [content::item::get_virtual_path -root_folder_id $root_folder_id -item_id $item_id]
                set package_url [apm_package_url_from_id $package_id]
                set webdav_prefix [oacs_dav::uri_prefix]
                if { [security::RestrictLoginToSSLP] } {
                    set expected_url [security::get_secure_location]${webdav_prefix}${package_url}${url_stub}
                } else {
                    set expected_url [ad_url]${webdav_prefix}${package_url}${url_stub}
                }
            } else {
                set expected_url ""
            }
            aa_equals "WebDAV URL is expected" \
                $webdav_url $expected_url

            aa_equals "Package id from the API and from the database are consistent" \
                [fs::get_file_package_id -file_id $revision_id] $package_id

            set file_hash [ns_md file $tmp_filename]

            set exported [fs::publish_versioned_object_to_file_system \
                              -object_id $item_id]
            aa_equals "fs::publish_versioned_object_to_file_system: original and exported files are identical" \
                [ns_md file $exported] $file_hash

            set exported [fs::publish_object_to_file_system \
                              -object_id $item_id]
            aa_equals "fs::publish_object_to_file_system: original and exported files are identical" \
                [ns_md file $exported] $file_hash

            aa_log "Add a link to the folder"
            set url https://test.website.url
            set link_id [content::extlink::new \
                             -url $url \
                             -parent_id $folder_id]
            set exported [fs::publish_url_to_file_system -object_id $link_id]
            set rfd [open $exported r]; set exported [read $rfd]; close $rfd
            aa_true "Link was exported" {
                [string first $url $exported] >= 0
            }

            aa_log "Add a symlink to the folder"
            content::folder::register_content_type \
                -folder_id $folder_id \
                -content_type content_symlink
            content::symlink::new \
                -target_id $item_id \
                -parent_id $folder_id

            fs::new_folder \
                -name __test_fs_subfolder \
                -pretty_name __test_fs_subfolder_pretty \
                -parent_id $folder_id

            set exported_folder [fs::publish_folder_to_file_system \
                                     -folder_id $folder_id \
                                     -user_id $swa_id]

            set folders 0
            set file_hashes 0
            set tot_files 0
            foreach c [glob -directory $exported_folder *] {
                set folder_p [file isdirectory $c]
                incr folders $folder_p
                incr file_hashes [expr {!$folder_p && $file_hash eq [ns_md file $c]}]
                incr tot_files
            }

            aa_equals "Tot folder content is 6" \
                $tot_files 6
            aa_equals "We have the same file twice (symlink)" \
                $file_hashes 2
            aa_equals "We have 1 folder" \
                $folders 1

        } -teardown_code {
            acs::test::user::delete -user_id $user_id
        }

    }

aa_register_case \
    -cats {api smoke} \
    -procs {
        fs::get_archive_command
    } \
    fs_archive_api {

        Test api concerning archiving

    } {
        set orig_package_key [ad_conn package_key]
        set orig_package_id [ad_conn package_id]

        try {
            set wfd [ad_opentmpfile in_file .in]
            set out_file [file rootname $in_file].out

            puts $wfd abcd
            close $wfd
            set in_file_hash [ns_md file $in_file]

            #
            # We simulate a file-storage connection context
            #
            ad_conn -set package_key "file-storage"
            ad_conn -set package_id [db_string get_fs_is {
                select max(package_id) from apm_packages
                where package_key = 'file-storage'
            }]

            exec -ignorestderr {*}[fs::get_archive_command \
                                       -in_file $in_file \
                                       -out_file $out_file]

            aa_equals "Input file was untouched" \
                [ns_md file $in_file] $in_file_hash

            aa_true "Archive '$out_file' was generated" \
                [file exists $out_file]
        } finally {
            ad_conn -set package_key $orig_package_key
            ad_conn -set package_id $orig_package_id
            file delete -- $in_file $out_file
        }
    }

aa_register_case \
    -cats {api smoke} \
    -procs {
        fs::new_root_folder
        fs::new_folder
        fs::add_file
        fs::add_version
        fs::delete_version
        fs::delete_file
        fs::file_copy
        fs::get_object_info
        fs::object_p
        fs_file_p
        fs_folder_p
        fs_version_p
        fs::set_folder_description
        fs::get_object_name
        fs::get_object_prettyname
        fs::get_file_system_safe_object_name
    } \
    fs_add_delete_copy {

        Test api to add/delete files, plus various other utilities.

    } {
        aa_run_with_teardown -rollback -test_code {
            aa_log "Create a root folder"
            set package_id [site_node::instantiate_and_mount \
                                -package_key file-storage \
                                -node_name __[clock seconds]_file_storage]

            set root_folder_id [fs::get_root_folder -package_id $package_id]

            aa_log "Create a folder"

            set folder_id_1 [fs::new_folder \
                                 -name __test_fs_folder_1 \
                                 -pretty_name __test_fs_folder_1_pretty \
                                 -parent_id $root_folder_id]

            aa_log "Create a new file"

            set content "This is a test file"
            set wfd [ad_opentmpfile tmp_filename]
            puts $wfd $content
            close $wfd

            set revision_id [fs::add_file \
                                 -name __test_fs_file \
                                 -parent_id $folder_id_1 \
                                 -package_id $package_id \
                                 -tmp_filename $tmp_filename]
            set item_id [db_string get_item {
                select item_id from cr_items where live_revision = :revision_id
            }]

            aa_log "Create a new revision from file"

            set content "This is a test file 2"
            set wfd [ad_opentmpfile tmp_filename_2]
            puts $wfd $content
            close $wfd

            set revision_id [fs::add_version \
                                 -item_id $item_id \
                                 -tmp_filename $tmp_filename_2]

            aa_log "Create a new revision from text"

            set revision_id [fs::add_version \
                                 -item_id $item_id \
                                 -content_body "My Content Body"]

            aa_equals "There are now 3 revisions" \
                [db_string count {select count(*) from cr_revisions where item_id = :item_id}] \
                3

            aa_log "Create another folder"

            set folder_id_2 [fs::new_folder \
                                 -name __test_fs_folder_2 \
                                 -pretty_name __test_fs_folder_2 \
                                 -parent_id $root_folder_id]

            aa_log "Copy the file in the new folder"
            set copy_item_id [fs::file_copy -file_id $item_id \
                                  -target_folder_id $folder_id_2]

            aa_true "File was copied" \
                [db_0or1row check {
                    select 1 from fs_objects
                    where name = '__test_fs_file'
                    and parent_id = :folder_id_2
                }]

            aa_equals "Only live revision was copied" \
                [db_string count {select count(*) from cr_revisions where item_id = :copy_item_id}] \
                1

            set file_info [fs::get_object_info -file_id $copy_item_id]
            set rfd [open [dict get $file_info cr_file_path] r]
            set txt [read $rfd]
            close $rfd
            aa_equals "Content is expected" \
                $txt \
                "My Content Body"

            aa_true "File '$item_id' is an fs object" [fs::object_p -object_id $item_id]
            aa_true "File '$item_id' is an fs file" [fs_file_p $item_id]
            aa_true "File '$folder_id_1' is an fs folder" [fs_folder_p $folder_id_1]
            aa_true "Folder '$folder_id_1' is an fs object" [fs::object_p -object_id $folder_id_1]
            aa_false "Folder '$folder_id_1' is not an fs file" [fs_file_p $folder_id_1]
            aa_false "File '$item_id' is not an fs folder" [fs_folder_p $item_id]
            aa_false "File '$item_id' is not an fs version" [fs_version_p $item_id]
            aa_false "Folder '$folder_id_1' is not an fs version" [fs_version_p $folder_id_1]

            aa_log "We now delete the first file revision by revision"
            set n_revisions 3
            db_foreach get_revisions {
                select revision_id
                from cr_revisions
                where item_id = :item_id
            } {
                aa_true "File version '$revision_id' is an fs version" \
                    [fs_version_p $revision_id]
                fs::delete_version \
                    -item_id $item_id \
                    -version_id $revision_id
                incr n_revisions -1
                aa_equals "Revisions are now $n_revisions" \
                    [db_string q {
                        select count(*) from cr_revisions
                        where item_id = :item_id
                    }] \
                    $n_revisions
                aa_false "File version '$revision_id' is not an fs version anymore" \
                    [fs_version_p $revision_id]
            }

            aa_false "File '$item_id' is not an fs object anympore" \
                [fs::object_p -object_id $item_id]
            aa_false "File '$item_id' is not an fs file anymore" \
                [fs_file_p $item_id]

            aa_log "Change description for folder '$folder_id_1'"
            fs::set_folder_description \
                -folder_id $folder_id_1 \
                -description "A test description"
            aa_equals "Description was changed" \
                [db_string q {
                    select description from cr_folders
                    where folder_id = :folder_id_1
                }] \
                "A test description"

            aa_equals "Pretty name is expected for folder '$folder_id_1'" \
                [fs::get_object_prettyname -object_id $folder_id_1] \
                __test_fs_folder_1_pretty

            aa_equals "Safe filesystem name for Folder '$folder_id_1' is expected" \
                [fs::get_file_system_safe_object_name -object_id $folder_id_1] \
                [ad_sanitize_filename \
                     -collapse_spaces \
                     -tolower [fs::get_object_name -object_id $folder_id_1]]

        }
    }

aa_register_case \
    -cats {web smoke} \
    -procs {
        file_storage::test::create_new_folder
        file_storage::test::delete_current_folder
        acs::test::follow_link

        fs_get_root_folder
        fs_context_bar_list
        ad_form_new_p
        ad_user_logout
        ad_unset_cookie
    } \
    fs_create_folder {

        Create a folder and delete it later.

        @author Mounir Lallali
} {

    try {
        aa_section "Create a test user"
        set user_info [acs::test::user::create -admin]

        aa_run_with_teardown -test_code {
            #
            # Go to the first instance of the file storage
            #
            set fs_page [aa_get_first_url -package_key file-storage]
            set d [acs::test::http -user_info $user_info $fs_page]

            #
            # Create a new folder with a random name in this instance
            #
            aa_section "Create a fresh folder"
            set folder_name [ad_generate_random_string]
            set folder_description [ad_generate_random_string]
            set d [file_storage::test::create_new_folder \
                       -last_request $d \
                       $folder_name $folder_description]

            acs::test::reply_has_status_code $d 200
            aa_log "Folder $folder_name was created successfully"

            #
            # Finally, delete the folder
            #
            aa_section "Delete the empty folder"
            file_storage::test::delete_current_folder -last_request $d

            aa_section "Log out"
            acs::test::logout -last_request $d
        }
    } finally {
        #
        # Get rid of the user
        #
        aa_section "Delete test user"
        acs::test::user::delete -user_id [dict get $user_info user_id]
    }
}

aa_register_case \
    -cats {web smoke} \
    -procs {
        file_storage::test::create_new_folder
        file_storage::test::edit_folder
        file_storage::test::delete_current_folder
        acs::test::follow_link

        fs_get_root_folder
        fs_context_bar_list
        ad_form_new_p
    } \
    fs_edit_folder {

    Test Edit a Folder.

    @author Mounir Lallali
} {

    try {
        aa_section "Create a test user"
        set user_info [acs::test::user::create -admin]

        aa_run_with_teardown -test_code {
            #
            # Go to the first instance of the file storage
            #
            set fs_page [aa_get_first_url -package_key file-storage]
            set d [acs::test::http -user_info $user_info $fs_page]

            #
            # Create a new folder with a random name in this instance
            #
            aa_section "Create a fresh folder"
            set folder_name [ad_generate_random_string]
            set folder_description [ad_generate_random_string]
            set d [file_storage::test::create_new_folder \
                       -last_request $d \
                       $folder_name $folder_description]

            acs::test::reply_has_status_code $d 200
            aa_log "Folder $folder_name was created successfully"

            aa_section "Edit folder"

            set folder_name [ad_generate_random_string]
            set d [file_storage::test::edit_folder \
                       -last_request $d \
                       $folder_name]

            acs::test::reply_has_status_code $d 200
            aa_log "Folder $folder_name was edited successfully"

            #
            # Finally, delete the folder
            #
            aa_section "Delete the empty folder"
            file_storage::test::delete_current_folder -last_request $d
        }
    } finally {
        #
        # Get rid of the user
        #
        aa_section "Delete test user"
        acs::test::user::delete -user_id [dict get $user_info user_id]
    }
}


aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {
        aa_display_result
        file_storage::twt::call_fs_page
        file_storage::twt::create_new_folder
        file_storage::twt::add_file_to_folder
        file_storage::twt::delete_file
    } \
    fs_add_file_to_folder_twt {

    Test Upload a File in a Folder.

    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [acs::test::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        file_storage::twt::call_fs_page

        # Create a new folder
        set folder_name [ad_generate_random_string]
        set folder_description [ad_generate_random_string]
        file_storage::twt::create_new_folder $folder_name $folder_description

        # Add a file to folder
        set uploaded_file_name [file_storage::twt::create_file [ad_generate_random_string]]
        set uploaded_file_description [ad_generate_random_string]
        set response [file_storage::twt::add_file_to_folder $folder_name $uploaded_file_name $uploaded_file_description]

        aa_display_result -response $response -explanation {for uploadding a file in a folder}

        file_storage::twt::delete_file $uploaded_file_name
        twt::user::logout
    }
}

aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {
        file_storage::twt::call_fs_page
        file_storage::twt::create_url_in_folder
    } fs_create_url_in_folder {

    Test Create a URL in a Folder.

    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [acs::test::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        file_storage::twt::call_fs_page

        # Create a URL in a folder
        set url_title [ad_generate_random_string]
        set url "e-lane.org"
        set url_description [ad_generate_random_string]
        set response [file_storage::twt::create_url_in_folder $url_title $url $url_description]

        aa_display_result -response $response -explanation {for creating a URL in a folder}

        twt::user::logout
    }
}

aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {
        file_storage::twt::call_fs_page
        file_storage::twt::create_url
    } \
    fs_create_url {

    Test Create a URL.

    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [acs::test::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        file_storage::twt::call_fs_page

        # Create a URL
        set url_title [ad_generate_random_string]
        set url "e-lane.org"
        set url_description [ad_generate_random_string]
        set response [file_storage::twt::create_url $url_title $url $url_description]

        aa_display_result -response $response -explanation {for creating a URL}

        twt::user::logout
    }
}

aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {
        file_storage::twt::call_fs_page
        file_storage::twt::create_file
        file_storage::twt::upload_file
        file_storage::twt::delete_file
    } \
    fs_upload_file {

    Test Upload a File.

    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [acs::test::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        file_storage::twt::call_fs_page

        # Upload a File
        set uploaded_file_name [file_storage::twt::create_file [ad_generate_random_string]]
        set uploaded_file_description [ad_generate_random_string]
        set response [file_storage::twt::upload_file $uploaded_file_name $uploaded_file_description]

        aa_display_result -response $response -explanation {for uploadding a file}

        file_storage::twt::delete_file $uploaded_file_name
        twt::user::logout
    }
}

aa_register_case -cats {
    api
    smoke
} -procs {
    fs::get_root_folder
    fs::new_folder
    fs::get_folder
    fs::folder_p
    fs::delete_folder
    fs::rename_folder
    fs_get_folder_name
} fs_create_folder_using_api {

    Create and delete a folder using the API.

    @author Héctor Romojaro <hector.romojaro@gmail.com>
    @creation-date 11 March 2021

} {
    aa_run_with_teardown -rollback -test_code {
        #
        # Create a new admin user and login
        #
        set user_id [db_nextval acs_object_id_seq]
        set user_info [acs::test::user::create -user_id $user_id -admin]
        acs::test::confirm_email -user_id $user_id
        #
        # Instantiate file storage
        #
        set package_id [site_node::instantiate_and_mount \
                            -node_name "file-storage-foo-test" \
                            -package_key file-storage]
        #
        # Get root folder
        #
        set root_folder_id [fs::get_root_folder -package_id $package_id]
        aa_true "Root folder exists" [fs::folder_p -object_id $root_folder_id]
        #
        # Create folder
        #
        set folder_name foo
        set folder_id [fs::new_folder \
                        -name $folder_name \
                        -pretty_name $folder_name \
                        -parent_id $root_folder_id]
        aa_true "Created root folder" [fs::folder_p -object_id $folder_id]
        #
        # Get folder
        #
        aa_equals "Get folder" [fs::get_folder -name $folder_name \
                                               -parent_id $root_folder_id] \
                               $folder_id
        #
        # Rename the folder
        #
        aa_equals "Folder name" [fs_get_folder_name $folder_id] $folder_name
        set folder_name bar
        fs::rename_folder -folder_id $folder_id -name $folder_name
        aa_equals "Folder name after renaming" [fs_get_folder_name $folder_id] \
            $folder_name
        #
        # Delete root folder
        #
        fs::delete_folder -folder_id $folder_id
        aa_false "Deleted folder" [fs::folder_p -object_id $folder_id]
    }
}

aa_register_case \
    -cats {web smoke} \
    -procs {
        aa_display_result
        file_storage::test::call_fs_page
        file_storage::test::create_new_folder
        file_storage::test::add_file_to_folder
        file_storage::test::delete_file

        aa_get_first_url
        acs::test::find_link
        acs::test::follow_link
        acs::test::form_reply
        acs::test::get_url_from_location
        ad_sanitize_filename
        content::item::get_id_by_name
        fs::add_file
        fs::add_version
        fs::delete_file
        fs::do_notifications
        fs::get_folder_contents_count
        fs::get_folder_package_and_root
        fs::get_item_id
        fs::get_object_name
        fs::get_parent
        fs::get_root_folder
        fs::max_upload_size
        fs::new_folder
        fs_context_bar_list
        fs_get_root_folder
    } \
    fs_add_file_to_folder {

    Test Upload a File in a Folder.

    @author Mounir Lallali
} {
    try {
        #
        # Setup of test user_id and login
        #
        set user_info [::acs::test::user::create -admin]
        aa_log "user_info = $user_info"
        set request_info [::acs::test::login $user_info]

        aa_run_with_teardown -test_code {

            set d [file_storage::test::call_fs_page -last_request $request_info]
            aa_log "call_fs_page done"

            # Create a new folder
            set folder_name [ad_generate_random_string]
            set folder_description [ad_generate_random_string]
            set folder_reply [file_storage::test::create_new_folder -last_request $d \
                                  $folder_name $folder_description]
            aa_log "new folder created"

            # Add a file to folder
            set uploaded_file_name [file_storage::test::create_file [ad_generate_random_string]]
            set uploaded_file_description [ad_generate_random_string]
            set d [file_storage::test::add_file_to_folder \
                       -last_request $d \
                       $folder_name \
                       $uploaded_file_name \
                       $uploaded_file_description]

            #aa_display_result -response $response -explanation {for uploading a file in a folder}
            aa_log "now delete file again"
            file_storage::test::delete_first_file -last_request $d $uploaded_file_name

            #
            # Finally, delete the folder
            #
            aa_section "Delete the folder"
            file_storage::test::delete_current_folder -last_request $folder_reply

            ::acs::test::logout -last_request $d
        }
    } finally {
        #
        # Get rid of the user
        #
        set user_id [dict get $user_info user_id]
        aa_section "Delete test user (user_id $user_id)"
        acs::test::user::delete -user_id $user_id -delete_created_acs_objects
    }

}

aa_register_case \
    -cats {web api smoke} \
    -procs {
        template::util::file_transform
        template::data::validate::file
        content::revision::get_cr_file_path
    } \
    fs_upload_a_notmpfile {

        Try to add a file to a folder where the content does not come
        from the user, but from a pre-existing file on the server.

        When a file is uploaded, the tmpfile holding the actual
        content should be created by the webserver and its path
        should not be in control of the user.

        Here we create a file on the server, then try to copy this
        file into the file-storage via a user requrest. This wold be
        nasty because:
        1. It means we could access any file the server can read
           e.g. source code, /etc/passwd...
        2. As the file-storage normally cleans up the file when the
           upload is over, we could potentially delete every file
           the server can write.

} {
    try {
        #
        # Setup of test user_id and login
        #
        set user_info [::acs::test::user::create -admin]
        aa_log "user_info = $user_info"
        set request_info [::acs::test::login $user_info]

        set d [file_storage::test::call_fs_page -last_request $request_info]
        aa_log "call_fs_page done"

        set d [acs::test::follow_link -last_request $d -label {Add File}]
        #acs::test::reply_has_status_code $d 200
        #
        # "Add File" links to a redirect page file-upload-confirm...
        #
        acs::test::reply_has_status_code $d 302
        set location [::acs::test::get_url_from_location $d]
        set d [acs::test::http -last_request $d $location]

        set response [dict get $d body]
        set form [acs::test::get_form $response {//form[@id='file-add']}]

        aa_true "add form was returned" {[llength $form] > 2}

        set file_name "I am not a tmpfile"
        set wfd [ad_opentmpfile notmpfile]
        puts $wfd "I am not a real tmpfile!"
        close $wfd
        set notmpfile_checksum [ns_md file $notmpfile]

        #
        # Try to create the file via the UI
        #
        set d [::acs::test::form_reply \
                   -last_request $d \
                   -form $form \
                   -update [list \
                                upload_file [list $file_name $notmpfile "text/plain"] \
                                title $file_name \
                                description $file_name \
                               ]]

        #
        # When upload succeeds, a redirect is returned. Here we want
        # to make sure our upload was rejected, but without a server
        # error.
        #
        set status [dict get $d status]
        if {$status != 304 && $status < 500} {
            set expected_status $status
        } else {
            set expected_status 200
        }
        acs::test::reply_has_status_code $d $expected_status

        aa_true "Our notmpfile '$notmpfile' still exists" \
            [file exists $notmpfile]

        #
        # Now make sure that the file did not end up in the content
        # repository. We exploit the fact that the user is fresh and
        # does not own many objects.
        #
        set notmpfile_was_found_p false
        set user_id [dict get $user_info user_id]
        foreach revision_id [db_list get_revisions {
            select revision_id from cr_revisions r, acs_objects o
            where o.object_id = r.revision_id
              and o.creation_user = :user_id
        }] {
            set path [content::revision::get_cr_file_path -revision_id $revision_id]
            set path_checksum [ns_md file $path]
            aa_log "Checking revision '$revision_id', checksum '$path_checksum'"
            if {$path_checksum eq $notmpfile_checksum} {
                set notmpfile_was_found_p true
            }
        }

        aa_false "Our notmpfile file was not found in the content repository of the user" \
            $notmpfile_was_found_p

    } finally {
        #
        # Get rid of the user
        #
        set user_id [dict get $user_info user_id]
        aa_section "Delete test user (user_id $user_id)"
        acs::test::user::delete -user_id $user_id -delete_created_acs_objects
    }

}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
