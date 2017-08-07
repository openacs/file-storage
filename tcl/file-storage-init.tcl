ad_library {
    Startup script for the file-storage system.  Currently empty
    because a VUH handles all our registered proc needs.

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 November 2000
    @cvs-id $Id$
}

# unused after mount callback handles this now

# JS: proc to execute every time a new package instance is created.
# This avoids the ugly hack in the original version that checks for
# the existence of a root folder every time fs_get_root_folder is called
# (i.e., every visit to a file-storage tree!) Essentially, we let APM
# do part of what fs_get_root_folder does, once, i.e., when the package instance 
# is created. We save a query (albeit an inexpensive one) since we can simplify
# fs_get_root_folder to not do the check for the root folder anymore. 

# Note that APM calls the proc with a name that uses the "package-key"
# (all "-" replaced by "_") concatenated with the string
# "post_instantiation".  The parameter passed is always
# package_id. The name of the proc is thus:

# ad_proc file_storage_post_instantiation {
#     package_id
# } {
#     Post package instantiation procedure to insert a package_id, 
#     folder_id pair in fs_root_folders
# } {
#     # We should probably just define this function here, and remove from the fs namespace
#     return [fs::new_root_folder -package_id $package_id]
# }


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
