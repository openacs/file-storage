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
    ad_return_complaint 1 "bad folder id $folder_id"
    ad_script_abort
}

permission::require_permission -party_id $viewing_user_id -object_id $folder_id -privilege "read"

if {![exists_and_not_null n_past_days]} {
    set n_past_days 99999
}

if {![exists_and_not_null fs_url]} {
    set fs_url ""
}

set folder_name [fs::get_object_name -object_id  $folder_id]

db_multirow contents select_folder_contents {} {
    set file_upload_name [fs::remove_special_file_system_characters -string $file_upload_name]
}

#set rows [fs::get_folder_contents \
#    -folder_id $folder_id \
#    -user_id $viewing_user_id \
#    -n_past_days $n_past_days \
#]
#template::util::list_of_ns_sets_to_multirow -rows $rows -var_name "contents"

ad_return_template
