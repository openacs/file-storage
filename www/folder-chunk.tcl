# file-storage/www/folder-chunk.tcl

ad_page_contract {
    @author yon (yon@openforce.net)
    @creation-date Feb 22, 2002
    @cvs-id $Id$
} -query {
} -properties {
    folder_name:onevalue
    contents:multirow
    content_size_total:onevalue
}

if {![exists_and_not_null folder_id]} {
    ad_return_complaint 1 [_ file-storage.lt_bad_folder_id_folder_]
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

set content_size_total 0

set root_folder_id [fs::get_root_folder]

db_multirow -extend { last_modified_pretty content_size_pretty } contents select_folder_contents {} {
    set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]

    set last_modified_pretty [lc_time_fmt $last_modified_ansi "%x %X"]

    set content_size_pretty [lc_numeric $content_size]

    set file_upload_name [fs::remove_special_file_system_characters -string $file_upload_name]

    if { ![empty_string_p $content_size] } {
        incr content_size_total $content_size
    }

    set name [lang::util::localize $name]
}

ad_return_template
