# 
ad_page_contract {
    
    Administrative functions for file-storage
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2003-11-08
    @cvs-id $Id$
    
} {
    
    
    
} -properties {
    title
    context
    dav_installed_p
    dav_enabled_p
} -validate {
} -errors {
}

set user_id [ad_conn user_id]
set package_name []
set title "Admin $package_name"
set context $package_name
array set sn [site_node::get -url [ad_conn url]]
set node_id $sn(node_id)
set dav_installed_p [apm_package_installed_p "oacs-dav"]
if {$dav_installed_p} {
    set dav_enabled_p [db_string check_dav_enabled ""]
} else {
    set dav_enabled_p 0
}

