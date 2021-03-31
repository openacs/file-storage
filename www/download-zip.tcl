ad_page_contract {
    Download items as a ZIP file
} {
    object_id:naturalnum,notnull,multiple
    {confirm_p:optional,boolean 0}
    {return_url:localurl ""}
} -errors {object_id:,notnull,integer,multiple {Please select at least one item to download.}
}

auth::require_login
set user_id [ad_conn user_id]

# publish the object to the filesystem
set in_path [ad_tmpnam]
file mkdir $in_path

if {[llength $object_id] == 1} {
    set object_name_id $object_id
} else {
    set object_name_id [fs::get_parent -item_id [lindex $object_id 0]]
}
set download_name [fs::get_file_system_safe_object_name -object_id $object_name_id]

append download_name ".zip"

foreach fs_object_id $object_id {
    # The minimal requirement is that the object exists. Don't throw
    # hard errors on following outdated links. We could test for
    # supported object_types.
    if {![acs_object::object_p -id $fs_object_id]} {
        ns_returnnotfound
        file delete -force -- $in_path
        ad_script_abort
    }
    set file [fs::publish_object_to_file_system -object_id $fs_object_id -path $in_path -user_id $user_id]
}

# create a temp dir to put the archive in
set out_path [ad_tmpnam]
file mkdir $out_path

set out_file [ad_file join ${out_path} ${download_name}]

# create the archive
ad_try {
    util::zip -source $in_path -destination $out_file
} on error {errorMsg} {
    # some day we'll do something useful here
    file delete -force -- $in_path
    file delete -force -- $out_path
    error $errorMsg
}

# return the archive to the connection.
ns_set put [ad_conn outputheaders] Content-Disposition "attachment;filename=\"$download_name\""
ns_set put [ad_conn outputheaders] Content-Type "application/zip"
ns_set put [ad_conn outputheaders] Content-Size "[ad_file size $out_file]"
ns_returnfile 200 application/octet-stream $out_file

# clean everything up
file delete -force -- $in_path
file delete -force -- $out_path

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
