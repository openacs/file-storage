<?xml version="1.0"?>
<queryset>

    <fullquery name="select_query">      
        <querytext>
            select folder_id,
                   short_name,
                   feed_title,
                   max_items,
                   descend_p,
                   include_revisions_p,
                   enclosure_match_patterns
            from fs_rss_subscrs
            where subscr_id = :subscr_id
        </querytext>
    </fullquery>

    <fullquery name="update_subscr">      
        <querytext>
            update fs_rss_subscrs
            set feed_title = :feed_title,
                short_name = :short_name,
                max_items = :max_items,
                descend_p = :descend_p,
                enclosure_match_patterns = :enclosure_match_patterns,
                include_revisions_p = :include_revisions_p
            where subscr_id = :subscr_id
        </querytext>
    </fullquery>

</queryset>
