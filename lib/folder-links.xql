<?xml version="1.0"?>
<queryset>

    <fullquery name="select_subscrs">      
        <querytext>
            select subscr_id, short_name, folder_id
            from fs_rss_subscrs
            where folder_id = :folder_id
            order by upper(short_name)
        </querytext>
    </fullquery>

</queryset>
