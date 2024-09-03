ad_page_contract {
    Download a file that has been exported in the previous UI.
} {
    {f:verify}
    {n:verify}
    {u:verify}
}

auth::require_login

if {![file exists $f] ||
    [ad_conn user_id] != $u} {
    ns_returnnotfound
    ad_script_abort
}

# return the archive to the connection.
ns_set put [ad_conn outputheaders] Content-Disposition "attachment;filename=\"$n\""
ns_set put [ad_conn outputheaders] Content-Type "application/zip"
ns_set put [ad_conn outputheaders] Content-Size [ad_file size $f]
ns_returnfile 200 application/octet-stream $f

# clean everything up
file delete -- $f

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
