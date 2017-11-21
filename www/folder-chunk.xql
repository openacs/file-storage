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

  <partialquery name="categories_limitation">
    <querytext>
      and fs_objects.object_id in ( select object_id from category_object_map where category_id = :category_id )
    </querytext>
  </partialquery>

</queryset>
