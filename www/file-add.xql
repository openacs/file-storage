<?xml version="1.0"?>

<queryset>
  <fullquery name="get_folder_id"> 
    <querytext>
      select parent_id
      from cr_items
      where item_id=:file_id
    </querytext>
  </fullquery>

  <fullquery name="get_file">
    <querytext>
      select name from cr_items where item_id=:file_id
    </querytext>
  </fullquery>

  <fullquery name="set_live_revision">
    <querytext>
      update cr_items set live_revision=:revision_id
      where item_id=:item_id
    </querytext>
  </fullquery>
</queryset>