# 
ad_page_contract {
    
     enable WebDAV support for this package instance
     
     @author Dave Bauer (dave@thedesignexperience.org)
     @creation-date 2003-11-08
     @cvs-id $Id$
     
} {
    
    
    
} -properties {
} -validate {
} -errors {
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
array set sn [site_node::get -url [ad_conn url]]
set node_id $sn(node_id)
set folder_id [fs::get_root_folder]
permission::require_permission \
    -object_id $package_id \
    -party_id $user_id \
    -privilege "admin"

if {[apm_package_installed_p "oacs-dav"]} {

    if {[empty_string_p [oacs_dav::request_folder_id $node_id]]} {
	oacs_dav::register_folder $folder_id $node_id
    }
    
}

ad_returnredirect "."
ad_script_abort
