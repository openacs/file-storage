set admin_p [permission::permission_p -object_id $folder_id -party_id [ad_conn user_id] -privilege "admin"]
set return_url [ad_return_url]
foreach { package_id root_folder_id } [fs::get_folder_package_and_root $folder_id] break
set fs_url [site_node::get_url_from_object_id -object_id $package_id]
set folder_url [export_vars -base $fs_url {folder_id return_url}]