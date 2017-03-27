ad_page_contract {
} {
    subscr_id:notnull,naturalnum
}

#ns_return 200 text/plain "foo"
#ad_script_abort

db_1row folder_from_subscr {}

permission::require_permission -object_id $subscr_id -privilege admin

ad_form -name del -form {
    subscr_id:key
    {confirm_p:text(hidden)}
} -edit_request {
    set confirm_p 1
} -edit_data {
    #here's where we actually do the delete.
    db_exec_plsql delete_subscr {}
    file delete -- [rss_gen_report_file -summary_context_id $subscr_id -impl_name fs_rss]
} -after_submit {
    ad_returnredirect rss-subscrs?folder_id=$folder_id
    ad_script_abort
} -cancel_url rss-subscrs?folder_id=$folder_id
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
