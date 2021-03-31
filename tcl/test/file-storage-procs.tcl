ad_library {
    Automated tests.

    @author Simon Carstensen
    @creation-date 14 November 2003
    @cvs-id $Id$
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
        array set user_info [twt::user::create -admin]
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
        array set user_info [twt::user::create -admin]
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
        array set user_info [twt::user::create -admin]
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
        array set user_info [twt::user::create -admin]
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
    aa_run_with_teardown -test_code {
        #
        # Setup of test user_id and login
        #
        set user_info [::acs::test::user::create -admin]
        aa_log "user_info = $user_info"
        set request_info [::acs::test::login $user_info]

        set d [file_storage::test::call_fs_page -last_request $request_info]
        aa_log "call_fs_page done"

        # Create a new folder
        set folder_name [ad_generate_random_string]
        set folder_description [ad_generate_random_string]
        file_storage::test::create_new_folder -last_request $d $folder_name $folder_description
        aa_log "new folder created"

        # Add a file to folder
        set uploaded_file_name [file_storage::test::create_file [ad_generate_random_string]]
        set uploaded_file_description [ad_generate_random_string]
        set d [file_storage::test::add_file_to_folder \
                   -last_request $d \
                   $folder_name \
                   $uploaded_file_name \
                   $uploaded_file_description]

        #aa_display_result -response $response -explanation {for uploadding a file in a folder}
        aa_log "now delete file again"
        file_storage::test::delete_first_file -last_request $d $uploaded_file_name
        ::acs::test::logout -last_request $d
    }
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
