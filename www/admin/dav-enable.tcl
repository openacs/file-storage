# packages/file-storage-dav/www/admin/dav-enable.tcl
ad_page_contract {
    
     enable WebDAV support for this package instance
     
     @author Dave Bauer (dave@thedesignexperience.org)
     @creation-date 2003-11-08
     @cvs-id $Id$
     
} {
    
    package_id:integer
    {return_url ""}
} -properties {
} -validate {
} -errors {
}

set user_id [ad_conn user_id]
array set sn [site_node::get_from_object_id -object_id $package_id]
set node_id $sn(node_id)
set folder_id [fs::get_root_folder -package_id $package_id]
permission::require_permission \
    -object_id $package_id \
    -party_id $user_id \
    -privilege "admin"


    if {[empty_string_p [oacs_dav::request_folder_id $package_id]]} {
	oacs_dav::register_folder $folder_id $node_id
    }
    


ad_returnredirect "."
ad_script_abort
