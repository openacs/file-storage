ad_page_contract {
    Download items as a ZIP file
} {
    object_id:naturalnum,notnull,multiple
    {confirm_p:optional,boolean 0}
    {return_url:localurl ""}
} -errors {object_id:,notnull,integer,multiple {Please select at least one item to download.}
}

auth::require_login

# Make sure all selected objects exist. This is the minimal
# requirement. Don't throw hard errors on following outdated links. We
# could test for supported object_types.
set n_objects [llength $object_id]
if {[db_string objects_do_not_exist "
    select :n_objects <> (select count(*)
                          from cr_items
                          where item_id in ([join $object_id ,]))
    from dual
"]} {
    ns_returnnotfound
    ad_script_abort
}

ad_try {

    ad_progress_bar_begin \
        -title [_ file-storage.download_zip_creating_archive_msg]

    set user_id [ad_conn user_id]

    # copy all files together in a temporary folder on the filesystem
    set in_path [ad_tmpnam]
    file mkdir $in_path

    foreach fs_object_id $object_id {
        fs::publish_object_to_file_system \
            -object_id $fs_object_id \
            -path $in_path \
            -user_id $user_id
    }

    set out_file [ad_tmpnam]

    # create the archive
    util::zip -source $in_path -destination $out_file

} on ok {d} {

    # compute the archive download filename
    if {$n_objects == 1} {
        set object_name_id $object_id
    } else {
        set object_name_id [fs::get_parent -item_id [lindex $object_id 0]]
    }
    set download_name [fs::get_file_system_safe_object_name -object_id $object_name_id].zip

    set n $download_name
    set f $out_file
    set u $user_id
    # The download URL always points to the file-storage instance of
    # the file, unlike the return_url, which might be arbitrary.
    set package_id [fs::get_file_package_id -file_id $object_name_id]
    set package_url [site_node::get_url_from_object_id -object_id $package_id]
    set file_url [export_vars -base ${package_url}/download-zip-2 {
        f:sign(max_age=300)
        n:sign(max_age=300)
        u:sign(max_age=300)
    }]

    set message "#file-storage.download_zip_file_is_ready_msg#
                 <iframe style='display:none' src='[ns_quotehtml $file_url]'></iframe>"

    util_user_message \
        -html \
        -message $message

    if {$return_url eq ""} {
        # Return URL must be not-empty or we will redirect to
        # ourselves...
        set return_url $package_url
    }

    ad_progress_bar_end \
        -url $return_url

} on error {errorMsg} {

    error $errorMsg

} finally {

    # clean everything up
    file delete -force -- $in_path

}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
