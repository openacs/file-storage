ad_library {
    Automated tests.

    @author Simon Carstensen
    @creation-date 14 November 2003
    @cvs-id $Id$
}

aa_register_case fs_new_root_folder {
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
