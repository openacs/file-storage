ad_library {
    Automated tests for file-storage-callbacks.

    @author Luis de la Fuente (lfuente@it.uc3m.es)
    @creation-date 18 November 2005
}

aa_register_case fs_move {
    Test the cabability of moving file-storage folders.
} {    

    aa_run_with_teardown \
        -rollback \
        -test_code {
            #Create origin and destiny communities
            set origin_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]
            set destiny_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]

            set orig_root_id [dotlrn_fs::get_community_root_folder -community_id $origin_club_key]
            set dest_root_id [dotlrn_fs::get_community_root_folder -community_id $destiny_club_key]

            #create folder
        	set folder_id [fs::new_folder -name "foo" -pretty_name "foobar" -parent_id $orig_root_id ]

            #check if the folder is at the origin
            set orig_success_p [db_string orig_success_p {
                select 1 from cr_items where item_id  = :folder_id and parent_id = :orig_root_id
            } -default "0"]
            aa_equals "folder has been succesfully created" $orig_success_p 1

            #move the folder
            callback -catch datamanager::move_folder -object_id $folder_id -selected_community $destiny_club_key
                
            #check if the folder is at the origin
            set orig_success_p [db_string orig_success_p {
                select 0 from cr_items where item_id  = :folder_id and parent_id = :orig_root_id
            } -default "1"]
            aa_equals "folder is not at origin: OK" $orig_success_p 1

            #check if the folder is at the destiny
            set dest_success_p [db_string dest_success_p {
                select 1 from cr_items where item_id  = :folder_id and parent_id = :dest_root_id
            } -default "0"]
            aa_equals "folder has been moved successfully" $dest_success_p 1


        }
}


aa_register_case fs_copy {
    Test the cabability of copying file-storage folders.
} {    

    aa_run_with_teardown \
        -rollback \
        -test_code {
            #Create origin and destiny communities
            set origin_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]
            set destiny_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]

            set orig_root_id [dotlrn_fs::get_community_root_folder -community_id $origin_club_key]
            set dest_root_id [dotlrn_fs::get_community_root_folder -community_id $destiny_club_key]

            #create folder
        	set folder_id [fs::new_folder -name "foo" -pretty_name "foobar" -parent_id $orig_root_id ]

            #check if the folder is at the origin
            set orig_success_p [db_string orig_success_p {
                select 1 from cr_items where item_id  = :folder_id and parent_id = :orig_root_id
            } -default "0"]
            aa_equals "folder has been succesfully created" $orig_success_p 1
           
            set new_folder_id [callback -catch datamanager::copy_folder -object_id $folder_id -selected_community $destiny_club_key -mode "both"]

            #check if the folder is at the origin
            set orig_success_p [db_string orig_success_p {
                select 1 from cr_items where item_id  = :folder_id and parent_id = :orig_root_id
            } -default "0"]
            aa_equals "folder is at origin: OK" $orig_success_p 1

            #check if the folder is at the destiny
            set dest_success_p [db_string dest_success_p {
                select 1 from cr_items where item_id  = :new_folder_id and parent_id = :dest_root_id
            } -default "0"]
            aa_equals "folder has been moved successfully" $dest_success_p 1
        }
}


            
