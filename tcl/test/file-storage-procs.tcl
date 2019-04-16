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
    } \
    fs_create_folder {

        Create a folder and delete it later.

        @author Mounir Lallali
} {

    try {
        # Create a test user
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
        acs::test::user::delete -user_id [dict get $user_info user_id]
    }
}


aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {
        file_storage::twt::call_fs_page
        file_storage::twt::create_new_folder
        file_storage::twt::edit_folder
    } \
    fs_edit_folder {

    Test Edit a Folder.

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

        # Edit a folder
        set new_folder_name [ad_generate_random_string]
        set response [file_storage::twt::edit_folder $new_folder_name]

        aa_display_result -response $response -explanation {for editing a folder}

        twt::user::logout
    }
}

aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {
        file_storage::twt::call_fs_page
        file_storage::twt::create_new_folder
        file_storage::twt::add_file_to_folder
        file_storage::twt::delete_file
    } \
    fs_add_file_to_folder {

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

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
