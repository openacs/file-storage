ad_include_contract {
    This include displays some admin links about specified folder.

    apisano: as in date 2018-12-03 its only usage on OpenACS was found
    in dotlrn-ecommerce/www/manage/one-section.adp, we might consider
    its deprecation.
} {
    folder_id:integer
}

set admin_p [permission::permission_p -object_id $folder_id -party_id [ad_conn user_id] -privilege "admin"]
set return_url [ad_return_url]
lassign [fs::get_folder_package_and_root $folder_id]  package_id root_folder_id 
set fs_url [site_node::get_url_from_object_id -object_id $package_id]
set folder_url [export_vars -base $fs_url {folder_id return_url}]
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
