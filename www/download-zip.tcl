ad_page_contract {
    delete items
} {
    object_id:naturalnum,notnull,multiple
    {confirm_p:optional,boolean 0}
    {return_url ""}
} -errors {object_id:,notnull,integer,multiple {Please select at least one item to download.}
}

auth::require_login 
set user_id [ad_conn user_id]

# publish the object to the file system
set in_path [ad_tmpnam]
file mkdir $in_path

if {[llength $object_id] == 1} {
    set download_name [fs::get_file_system_safe_object_name -object_id $object_id]
} else {
    set download_name [fs::get_file_system_safe_object_name -object_id [fs::get_parent -item_id [lindex $object_id 0]]]
}

append download_name ".zip"

foreach fs_object_id $object_id {
    # The minimal requirment is that the object exists. Don't throw
    # hard errors on following outdated links. We could test for
    # supported object_types.
    if {![acs_object::object_p -id $fs_object_id]} {
	ns_returnnotfound
	file delete -force $in_path
	ad_script_abort 
    }
    set file [fs::publish_object_to_file_system -object_id $fs_object_id -path $in_path -user_id $user_id]
}

# create a temp dir to put the archive in
set out_path [ad_tmpnam]
file mkdir $out_path

set out_file [file join ${out_path} ${download_name}]

# get the archive command
set cmd "zip -r \"$out_file\" ."

# create the archive
with_catch errmsg {
    exec bash -c "cd $in_path; $cmd; cd -"
} {
    # some day we'll do something useful here
    file delete -force $in_path
    file delete -force $out_path
    error $errmsg
}

# return the archive to the connection.
ns_set put [ad_conn outputheaders] Content-Disposition "attachment;filename=\"$download_name\""
ns_set put [ad_conn outputheaders] Content-Type "application/zip"
ns_set put [ad_conn outputheaders] Content-Size "[file size $out_file]"
ns_returnfile 200 application/octet-stream $out_file

# clean everything up
file delete -force $in_path
file delete -force $out_path
