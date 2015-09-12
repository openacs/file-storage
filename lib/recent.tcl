set fs_package [site_node::get_element -url $url -element package_id]
set fs_root [fs::get_root_folder -package_id $fs_package]
set fs_folder [fs::get_folder -parent_id $fs_root -name $folder]


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
