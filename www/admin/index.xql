<?xml version="1.0"?>

<queryset>
  <fullquery name="check_dav_enabled">
    <querytext>
      select count(*) from dav_site_node_folder_map
      where node_id=:node_id
    </querytext>
  </fullquery>
  
</queryset>