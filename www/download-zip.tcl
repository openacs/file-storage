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
                          from acs_objects
                          where object_id in ([join $object_id ,]))
    from dual
"]} {
    ns_returnnotfound
    ad_script_abort
}

set user_id [ad_conn user_id]

# publish the object to the filesystem
set in_path [ad_tmpnam]
file mkdir $in_path

if {$n_objects == 1} {
    set object_name_id $object_id
} else {
    set object_name_id [fs::get_parent -item_id [lindex $object_id 0]]
}
set download_name [fs::get_file_system_safe_object_name -object_id $object_name_id]

append download_name ".zip"

foreach fs_object_id $object_id {
    set file [fs::publish_object_to_file_system \
                  -object_id $fs_object_id \
                  -path $in_path \
                  -user_id $user_id]
}

set out_file [ad_tmpnam]

ad_try {

    # create the archive
    util::zip -source $in_path -destination $out_file

} on ok {d} {

    # return the archive to the connection.
    ns_set put [ad_conn outputheaders] Content-Disposition "attachment;filename=\"$download_name\""
    ns_set put [ad_conn outputheaders] Content-Type "application/zip"
    ns_set put [ad_conn outputheaders] Content-Size [ad_file size $out_file]
    ns_returnfile 200 application/octet-stream $out_file

} on error {errorMsg} {

    # some day we'll do something useful here
    error $errorMsg

} finally {

    # clean everything up
    file delete -force -- $in_path
    file delete -- $out_file

}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
