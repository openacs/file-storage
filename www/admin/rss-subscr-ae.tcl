ad_page_contract {

    Create or edit an RSS feed generation request.
    Technically we only need to require either subscr_id or
    folder_id.  When subscr_id is passed in, any passed-in folder_id
    will get overwritten by the select query.  This provides a
    safeguard against url surgery.

    Security: OpenACS ensures that the user has admin permission on this
    package instance.  However, we can't trust the incoming subscription_id
    or folder_id.

    RSS feed requests (subscrs) are placed in the permission context of the
    folder being summarizing, so permission checks can be done against either
    the folder_id or subscr_id.

} {
    subscr_id:optional,naturalnum
    folder_id:notnull,naturalnum
}

set folder_name [fs_get_folder_name $folder_id]
set system_name [ad_system_name]

ad_form -name rss -form {
    subscr_id:key
    {short_name:text(text)
        {label {Short Name}}
        {html {size 25 maxlen 80}}
        {help_text {This name is displayed next to the XML button on folder contents page.  Example: "Recent files feed"}}
    }
    {feed_title:text(text)
        {label {Full Feed Title}}
        {html {size 50 maxlen 200}}
        {help_text {The full feed title that will be displayed in a newsreader.  Example: "Recent files in the Contributed Documentation folder on OpenACS.org."}}
    }
    {max_items:naturalnum(text)
        {label {Max Items}}
        {html {size 3 maxlen 3}}
        {help_text {How many items should appear, at most, in the feed?}}
    }
    {descend_p:boolean(radio)
        {label {Include sub-folders}}
        {options {{Yes t} {No f}}}
    }
    {include_revisions_p:boolean(radio)
        {label {Include revisions}}
        {options {{Yes t} {No f}}}
    }
    {enclosure_match_patterns:text(text),optional
        {label {Enclosure match patterns}}
        {help_text {Enable auto-downloading for some or all files.  We'll create an <a href="http://www.thetwowayweb.com/payloadsforrss">RSS enclosure</a> if the filename matches one of these patterns.  Leave empty for no enclosures, set to * for all files, set to *.mp3 for just files with an mp3 extension.}}
    }
    {folder_id:naturalnum(hidden)}
} -on_request {
} -new_request {
    set descend_p f
    set include_revisions_p f
    set feed_title "$folder_name on $system_name"
    set max_items 15
} -select_query "
    [db_map select_query]
" -new_data {
    #Protection against URL surgery.
    permission::require_permission -object_id $folder_id -privilege admin
    set fs_rss_impl_id [acs_sc::impl::get_id -owner "file-storage" -name fs_rss]
    set user_id [ad_conn user_id]
    set peeraddr [ad_conn peeraddr]
    set subscr_id [db_exec_plsql create_subscr {}]
} -edit_data {
    #Protection against URL surgery.
    permission::require_permission -object_id $folder_id -privilege admin
    db_dml update_subscr {}
} -after_submit {
    rss_gen_report $subscr_id
    ad_returnredirect rss-subscrs?folder_id=$folder_id
    ad_script_abort
}

if { ![ad_form_new_p -key subscr_id] } {
    template::form get_values rss folder_id
}

set root_folder_id [fs_get_root_folder -package_id [ad_conn package_id]]
set context [fs_context_bar_list -root_folder_id $root_folder_id $folder_id]
