ad_library {
    Automated tests.
    
    @author Simon Carstensen
    @creation-date 14 November 2003
    @cvs-id $Id$
}

aa_register_case \
    -cats {api db smoke} \
    fs_new_root_folder {
	Test the fs::new_root_folder proc.
    } {    

	aa_run_with_teardown \
        -rollback \
        -test_code {
            
            # Create folder
            set folder_id [fs::new_root_folder \
                               -package_id [ad_conn package_id] \
                               -pretty_name "Foobar" \
                               -description "Foobar"]
	    
            set success_p [db_string success_p {
                select 1 from fs_root_folders where folder_id = :folder_id
            } -default "0"]
	    
            aa_equals "folder was created succesfully" $success_p 1
        }
    }

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_create_folder {
    
    Test Load File.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
	tclwebtest::cookies clear
	
	# Login user
	array set user_info [twt::user::create -admin]
	twt::user::login $user_info(email) $user_info(password)
	
	file_storage::twt::go_to_dotlrn_my_files_page_url
	
	# Create a new folder	
	set folder_name [ad_generate_random_string]
	set folder_description [ad_generate_random_string]
	set response [file_storage::twt::create_new_folder $folder_name $folder_description]
	
	aa_display_result -response $response -explanation {for creating a new folder}
	
   	twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_delete_folder {
    
    Test Delete a Folder.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear
	
        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)
	
        file_storage::twt::go_to_dotlrn_my_files_page_url
	
	# Create a new folder
        set folder_name [ad_generate_random_string]
        set folder_description [ad_generate_random_string]
        file_storage::twt::create_new_folder $folder_name $folder_description
	
	# Delete a folder
        set response [file_storage::twt::delete_folder]
        
	aa_display_result -response $response -explanation {for deleting a folder}
	
        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_edit_folder {
    
    Test Edit a Folder.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear
	
        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)
	
	file_storage::twt::go_to_dotlrn_my_files_page_url
	
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

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_add_file_to_folder {

    Test Upload a File in a Folder.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear

        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)
	
        file_storage::twt::go_to_dotlrn_my_files_page_url
	
	# Create a new folder
        set folder_name [ad_generate_random_string]
        set folder_description [ad_generate_random_string]
        file_storage::twt::create_new_folder $folder_name $folder_description
	
	# Add a file to folder
        set uploaded_file_name [file_storage::twt::create_file [ad_generate_random_string]]
        set uploaded_file_description [ad_generate_random_string]
        set response [file_storage::twt::add_file_to_folder $folder_name $uploaded_file_name $uploaded_file_description]
	
        aa_display_result -response $response -explanation {for uploadding a file in a folder}
	
        file_storage:::twt::delete_file $uploaded_file_name
        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_create_url_in_folder {
    
    Test Create a URL in a Folder.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear
	
        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)
	
        file_storage::twt::go_to_dotlrn_my_files_page_url
	
	# Create an URL in a folder
        set url_title [ad_generate_random_string]
        set url "e-lane.org"
        set url_description [ad_generate_random_string]
	set response [file_storage::twt::create_url_in_folder $url_title $url $url_description]
	
	aa_display_result -response $response -explanation {for creating an URL in a folder}

        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_create_url {
    
    Test Create a URL.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear
	
        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)
	
        file_storage::twt::go_to_dotlrn_my_files_page_url
	
	# Create an URL
        set url_title [ad_generate_random_string]
        set url "e-lane.org"
        set url_description [ad_generate_random_string]
	set response [file_storage::twt::create_url $url_title $url $url_description]
        
	aa_display_result -response $response -explanation {for creating a URL}
	
        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_edit_url {
    
    Test Edit an URL.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear
	
        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)
	
        file_storage::twt::go_to_dotlrn_my_files_page_url

	# Create an URL
        set url_title [ad_generate_random_string]
        set url "e-lane.org"
        set url_description [ad_generate_random_string]
        file_storage::twt::create_url $url_title $url $url_description
        
	# Edit an URL
	set new_url_title [ad_generate_random_string]
        set new_url "dotlrn.org"
        set new_url_description [ad_generate_random_string]
	set response [file_storage::twt::edit_url $new_url_title $new_url $new_url_description]

        aa_display_result -response $response -explanation {for editing an URL}
	
        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_delete_url {
    
    Test Delete an URL.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear

        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        file_storage::twt::go_to_dotlrn_my_files_page_url

        # Create an URL
        set url_title [ad_generate_random_string]
        set url "e-lane.org"
        set url_description [ad_generate_random_string]
        file_storage::twt::create_url $url_title $url $url_description
	
	# Delete an URL
        set response [file_storage::twt::delete_url $url_title]
        
	aa_display_result -response $response -explanation {for deleting an URL}
	
        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_upload_file {

    Test Upload a File.

    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear
	
        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)
	
        file_storage::twt::go_to_dotlrn_my_files_page_url
	
	# Upload a File
	set uploaded_file_name [file_storage::twt::create_file [ad_generate_random_string]]
        set uploaded_file_description [ad_generate_random_string]	
        set response [file_storage::twt::upload_file $uploaded_file_name $uploaded_file_description]
        
	aa_display_result -response $response -explanation {for uploadding a file}
	
	file_storage:::twt::delete_file $uploaded_file_name
        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_delete_file {
    
    Test Delete a File.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear
	
        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)
	
        file_storage::twt::go_to_dotlrn_my_files_page_url
	
	# Upload a file
        set uploaded_file_name [file_storage::twt::create_file [ad_generate_random_string]]
        set uploaded_file_description [ad_generate_random_string]
        file_storage::twt::upload_file $uploaded_file_name $uploaded_file_description
	
	# Delete a file
	set response [file_storage::twt::delete_uploaded_file $uploaded_file_name]
        aa_display_result -response $response -explanation {for deleting a file}
    
	file_storage:::twt::delete_file $uploaded_file_name
	twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_rename_file {

    Test Rename a File.

    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        file_storage::twt::go_to_dotlrn_my_files_page_url

        # Upload a file
        set uploaded_file_name [file_storage::twt::create_file [ad_generate_random_string]]
        set uploaded_file_description [ad_generate_random_string]
        file_storage::twt::upload_file $uploaded_file_name $uploaded_file_description

	# Rename a file
	set new_file_name [ad_generate_random_string]
        set response [file_storage::twt::rename_file $new_file_name]
        aa_display_result -response $response -explanation {for renaming a file}

        file_storage:::twt::delete_file $uploaded_file_name
        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_copy_file {

    Test Copy a File in another folder.

    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        file_storage::twt::go_to_dotlrn_my_files_page_url
	
        # Create a new folder
        set folder_name [ad_generate_random_string]
        set folder_description [ad_generate_random_string]
        set response [file_storage::twt::create_new_folder $folder_name $folder_description]
	
	# The file storage dotlrn page
	::twt::do_request  "/dotlrn/control-panel"
	tclwebtest::link follow {My Files}

	# Upload a file
        set uploaded_file_name [file_storage::twt::create_file [ad_generate_random_string]]
        set uploaded_file_description [ad_generate_random_string]
        file_storage::twt::upload_file $uploaded_file_name $uploaded_file_description

        # Copy a file in another folder
	set response [file_storage::twt::copy_file $folder_name $uploaded_file_name] 
        aa_display_result -response $response -explanation {for copying a file in another folder}

        file_storage:::twt::delete_file $uploaded_file_name
        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest tclwebtest_move_file {

    Test Move a File in another folder.

    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        file_storage::twt::go_to_dotlrn_my_files_page_url

	# Create a new folder
        set folder_name [ad_generate_random_string]
        set folder_description [ad_generate_random_string]
        set response [file_storage::twt::create_new_folder $folder_name $folder_description]

	# The file storage dotlrn page
        ::twt::do_request  "/dotlrn/control-panel"
        tclwebtest::link follow {My Files}

        # Upload a file
        set uploaded_file_name [file_storage::twt::create_file [ad_generate_random_string]]
        set uploaded_file_description [ad_generate_random_string]
        file_storage::twt::upload_file $uploaded_file_name $uploaded_file_description

        # Move a file in another folder
        set response [file_storage::twt::move_file $folder_name $uploaded_file_name]
        aa_display_result -response $response -explanation {for moving a file in another folder}

        file_storage:::twt::delete_file $uploaded_file_name
        twt::user::logout
    }
}




