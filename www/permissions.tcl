ad_page_contract {
    Permissions for a folder

    @author Jeff Davis <davis@xarg.net>
    @creation-date 2005-03-05
    @cvs-id $Id$
} {
    {object_id:naturalnum,notnull}
}
set user_id [ad_conn user_id]

permission::require_permission \
    -party_id $user_id \
    -object_id $object_id \
    -privilege "admin"

set root_folder_id [fs::get_root_folder]

if {[fs_file_p $object_id]} {
    set context [fs_context_bar_list -final [_ acs-subsite.Permissions] $object_id]
    set page_title [db_string name {select name from fs_objects where object_id = :object_id} -default [_ file-storage.untitled]]
} {
    set page_title [fs_get_folder_name $object_id]
    set context [fs_context_bar_list -final [_ acs-subsite.Permissions] -root_folder_id $root_folder_id $object_id]
}
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
