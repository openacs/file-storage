# file-storage/www/folder-chunk.tcl

ad_page_contract {
    @author yon (yon@openforce.net)
    @creation-date Feb 22, 2002
    @version $Id$
} -query {
} -properties {
    folder_name:onevalue
    contents:multirow
}

if {![exists_and_not_null folder_id]} {
    ad_return_complaint 1 "bad folder id $folder_id"
    ad_script_abort
}

if {![exists_and_not_null viewing_user_id]} {
    set viewing_user_id [acs_magic_object "the_public"]
}

if {![exists_and_not_null n_past_days]} {
    set n_past_days 99999
}

set folder_name [fs::get_object_name -object_id  $folder_id]

set rows [fs::get_folder_contents \
    -folder_id $folder_id \
    -user_id $viewing_user_id \
    -n_past_days $n_past_days \
]
template::util::list_of_ns_sets_to_multirow -rows $rows -var_name "contents"

ad_return_template
