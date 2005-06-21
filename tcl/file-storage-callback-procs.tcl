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
