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

aa_register_case -cats {web smoke} -libraries tclwebtest fs_create_folder {
    
    Test Load File.
    
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
	set response [file_storage::twt::create_new_folder $folder_name $folder_description]
	
	aa_display_result -response $response -explanation {for creating a new folder}
	
   	twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest fs_delete_folder {
    
    Test Delete a Folder.
    
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
	
	# Delete a folder
        set response [file_storage::twt::delete_folder]
        
	aa_display_result -response $response -explanation {for deleting a folder}
	
        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest fs_edit_folder {
    
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

aa_register_case -cats {web smoke} -libraries tclwebtest fs_add_file_to_folder {

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
	
        file_storage:::twt::delete_file $uploaded_file_name
        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest fs_create_url_in_folder {
    
    Test Create a URL in a Folder.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear
	
        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

	file_storage::twt::call_fs_page	
	
	# Create an URL in a folder
        set url_title [ad_generate_random_string]
        set url "e-lane.org"
        set url_description [ad_generate_random_string]
	set response [file_storage::twt::create_url_in_folder $url_title $url $url_description]
	
	aa_display_result -response $response -explanation {for creating an URL in a folder}

        twt::user::logout
    }
}

aa_register_case -cats {web smoke} -libraries tclwebtest fs_create_url {
    
    Test Create a URL.
    
    @author Mounir Lallali
} {
    aa_run_with_teardown -test_code {
	
        tclwebtest::cookies clear
	
        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

	file_storage::twt::call_fs_page	
	
	# Create an URL
        set url_title [ad_generate_random_string]
        set url "e-lane.org"
        set url_description [ad_generate_random_string]
	set response [file_storage::twt::create_url $url_title $url $url_description]
        
	aa_display_result -response $response -explanation {for creating a URL}
	
        twt::user::logout
    }
}


aa_register_case -cats {web smoke} -libraries tclwebtest fs_upload_file {

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
	
	file_storage:::twt::delete_file $uploaded_file_name
        twt::user::logout
    }
}





# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
