<?xml version="1.0"?>
<queryset>

    <fullquery name="fs::rss::datasource.select_subscription">      
        <querytext>
	    select s.subscr_id,
                   s.folder_id,
                   s.feed_title,
                   s.max_items,
                   s.descend_p,
                   s.include_revisions_p,
                   s.enclosure_match_patterns,
                   f.label as folder_title
            from fs_rss_subscrs s, cr_folders f
            where s.subscr_id = :summary_context_id
              and f.folder_id = s.folder_id
        </querytext>
    </fullquery>

    <fullquery name="fs::rss::build_feeds.select_subscrs">      
        <querytext>
	    select subscr_id
            from fs_rss_subscrs
            where folder_id = :folder_id
        </querytext>
    </fullquery>

</queryset>