<?xml version="1.0"?>
<queryset>

    <fullquery name="select_rebuild_folder">      
        <querytext>
            select folder_id as rebuild_folder_id,
                   short_name as rebuild_short_name
            from fs_rss_subscrs
            where subscr_id = :rebuild_subscr_id
        </querytext>
    </fullquery>

    <fullquery name="select_subscrs">      
        <querytext>
            select subscr_id, short_name, folder_id
            from fs_rss_subscrs
            where folder_id = :folder_id
            order by upper(feed_title)
        </querytext>
    </fullquery>

</queryset>
