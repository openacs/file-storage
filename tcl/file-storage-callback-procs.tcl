# packages/file-storage/tcl/file-storage-callback-procs.tcl

ad_library {
    
    Callback procs for file storage
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-15
    @arch-tag: 921a2c2a-5593-495b-9a60-9d815d80a39d
    @cvs-id $Id$
}

namespace eval fs::folder_chunk {}

ad_proc -public -callback fs::folder_chunk::add_bulk_actions {
    {-bulk_variable:required}
    {-folder_id:required}
    {-var_export_list:required}
} {
}

ad_proc -public -callback fs::file_new {
    {-package_id:required}
    {-file_id:required}
} {
}

ad_proc -public -callback fs::file_revision_new {
    {-package_id:required}
    {-file_id:required}
    {-parent_id:required}
} {
}

ad_proc -public -callback datamanager::move_folder -impl datamanager {
     -object_id:required
     -selected_community:required
} {
    Move a folder to another class or community
} {

#get the working package
db_1row get_working_package {}
set root_folder_id [fs::get_root_folder -package_id $package_id]
    
#update forums_forums table    
db_dml update_cr_items {}
db_dml update_acs_objects {}
}

ad_proc -public -callback datamanager::delete_folder -impl datamanager {
     -object_id:required
} {
    Move a folder to the trash
} {

#get the trash_id
set trash_id [datamanager::get_trash_id]

    
#update forums_forums table    
db_dml del_update_cr_items {}
db_dml del_update_acs_objects {}
}



ad_proc -public -callback datamanager::copy_folder -impl datamanager {
     -object_id:required
     -selected_community:required
} {
    Copy a folder to another class or community
} {
#get the destiny's root folder
    set parent_id [dotlrn_fs::get_community_root_folder -community_id $selected_community]

    fs_folder_copy -old_folder_id $object_id -new_parent_id $parent_id
    
}
