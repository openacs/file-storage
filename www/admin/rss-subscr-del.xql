<?xml version="1.0"?>
<queryset>

    <fullquery name="folder_from_subscr">
        <querytext>
            select folder_id, feed_title
            from fs_rss_subscrs
            where subscr_id = :subscr_id
        </querytext>
    </fullquery>

</queryset>
