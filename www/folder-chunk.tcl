# file-storage/www/folder-chunk.tcl

ad_page_contract {
    @author yon (yon@openforce.net)
    @creation-date Feb 22, 2002
    @cvs-id $Id$
} -query {
} -properties {
    folder_name:onevalue
    contents:multirow
}

if {![exists_and_not_null folder_id]} {
    ad_return_complaint 1 [_ file-storage.lt_bad_folder_id_folder_]
    ad_script_abort
}

if {![exists_and_not_null viewing_user_id]} {
    set viewing_user_id [acs_magic_object "the_public"]
}

permission::require_permission -party_id $viewing_user_id -object_id $folder_id -privilege "read"

if {![exists_and_not_null n_past_days]} {
    set n_past_days 99999
}

if {![exists_and_not_null fs_url]} {
    set fs_url ""
}

db_multirow contents select_folder_contents {} {
    set file_upload_name [fs::remove_special_file_system_characters -string $file_upload_name]
    set last_modified [lc_time_fmt $last_modified "%x %X"]
    set content_size [lc_numeric $content_size]
}

set folder_name [fs::get_object_name -object_id  $folder_id]

ad_return_template
