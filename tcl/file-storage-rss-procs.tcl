namespace eval fs::rss {}

ad_proc -public fs::rss::create_rss_gen_subscr_impl {} {
    Register the service contract implementation and return the impl_id
    
    @return impl_id of the created implementation
} {
    return [acs_sc::impl::new_from_spec -spec {
        contract_name "RssGenerationSubscriber"
        name "fs_rss"
        owner "file-storage"
        aliases {
            datasource fs::rss::datasource
            lastUpdated fs::rss::lastUpdated
        }
    }]
}

ad_proc -public fs::rss::drop_rss_gen_subscr_impl {} {
    Unegister the service contract implementation and return the impl_id
    
    @return impl_id of the created implementation
} {
    acs_sc::impl::delete -contract_name RssGenerationSubscriber -impl_name fs_rss
}

ad_proc -private fs::rss::datasource {
    summary_context_id
} {
    This procedure implements the "datasource" operation of the
    RssGenerationSubscriber service contract.  

    Important: in this implementation, the summary_context_id is equal
    to the subscription_id, which we use to key into the fs_rss_subscrs table
    to find the folder_id.  

    @author Andrew Grumet (aegrumet@alum.mit.edu)
} {

    db_1row select_subscription {}

    set system_name [ad_system_name]

    set column_array(channel_title) $feed_title
    set column_array(channel_description) "Recent additions to the \"$folder_title\" folder on $system_name"

    set column_array(version) 2.0

    set folder_info [fs::get_folder_package_and_root $folder_id]
    set package_id [lindex $folder_info 0]
    set root_folder_id [lindex $folder_info 1]
    set base_url [site_node::get_url_from_object_id -object_id $package_id]
    set ad_url [ad_url]
    set folder_url "${ad_url}${base_url}?folder_id=$folder_id"

    set column_array(channel_link) $folder_url

    set image_url "/resources/dotlrn/logo-user.gif"

    if { [empty_string_p $image_url] } {
        set column_array(image) ""
    } else {
        set column_array(image) [list \
		url "${ad_url}$image_url" \
                title $folder_title \
                link $folder_url \
                width "133" \
                height "36"]
    }

    # We need this for enclosure URLs, which should end with an
    # actual filename so they can be downloaded cleanly.
    #
    # It looks like item::get_url returns unencoded folder paths.
    # But folder names can contain spaces, so we'll urlencode just in case.
    set pretty_folder_url "${ad_url}${base_url}"
    if { $folder_id != $root_folder_id } {
        set url_stub [content::item::get_virtual_path -item_id $root_folder_id $folder_id]
        set stub_parts [split $url_stub /]
        set enc_url_stub_list [list]
        foreach part $stub_parts {
            lappend enc_url_stub_list [ns_urlencode $part]
        }
        set enc_url_stub [join $enc_url_stub_list /]
        append pretty_folder_url ${enc_url_stub}/
    }

    set items [list]
    set counter 0

    if { [string equal $descend_p f] } {
        set parent_clause "parent_id = :folder_id"
    } else {
        set parent_clause [db_map descend_parent_clause]
    }

    if { [string equal $include_revisions_p f] } {
        set revisions_clause "r.revision_id = o.live_revision"
    } else {
        set revisions_clause "r.item_id = o.object_id"
    }

    db_foreach select_files {} {
        set link "${ad_url}${base_url}file?file_id=$item_id&version_id=$revision_id"
        set content "content"
        set description $description

        if { [string equal $include_revisions_p t] } {
            append description "<br><br><b>Note:</b> This may be a new revision of an existing file."
        }
        
        # Always convert timestamp to GMT
        set publish_date_ansi [lc_time_tz_convert -from [lang::system::timezone] -to "Etc/GMT" -time_value $publish_date_ansi]
        set publish_timestamp "[clock format [clock scan $publish_date_ansi] -format "%a, %d %b %Y %H:%M:%S"] GMT"
        
        set iteminfo [list \
                          link $link \
                          title $title \
                          description $description \
                          timestamp $publish_timestamp ]

        if { ![string equal $enclosure_match_patterns ""] } {
            foreach pattern $enclosure_match_patterns {
                if { [string match $pattern $title] } {
                    lappend iteminfo \
                        enclosure_url "${pretty_folder_url}$file_upload_name" \
                        enclosure_type $type \
                        enclosure_length $content_size
                    break
                }
            }
        }

        lappend items $iteminfo

        if { $counter == 0 } {
            set column_array(channel_lastBuildDate) $publish_timestamp
            incr counter
        }
    }

    set column_array(items) $items
    set column_array(channel_language)               ""
    set column_array(channel_copyright)              ""
    set column_array(channel_managingEditor)         ""
    set column_array(channel_webMaster)              ""
    set column_array(channel_rating)                 ""
    set column_array(channel_skipDays)               ""
    set column_array(channel_skipHours)              ""
    
    return [array get column_array]
}

ad_proc -private fs::rss::lastUpdated {
    summary_context_id
} {
    Returns the time that the last file was modified,
    in Unix time.  Returns 0 otherwise.

    @author Andrew Grumet (aegrumet@alum.mit.edu)
} {

    #result differs on whether we're including revisions

    db_1row select_last_updated {}

    return $last_update
}

ad_proc -private fs::rss::build_feeds {
    folder_id
} {
    Builds all rss feeds for a folder.

    @author Andrew Grumet (aegrumet@alum.mit.edu)
} {

    #Don't use nested db_ calls because then fs::rss::datasource will
    #not see the results of in-progress transactions.
    set subscr_id_list [db_list select_subscrs {}]
    
    foreach subscr_id $subscr_id_list {
        rss_gen_report $subscr_id
    }
}
