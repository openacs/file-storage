<?xml version="1.0"?>
<queryset>

  <fullquery name="get_folder_info">
    <querytext>
      select cf.label,
      cf.description,
      ci.parent_id
      from cr_folders cf,
      cr_items ci
      where cf.folder_id=:folder_id
      and   cf.folder_id = ci.item_id
      </querytext>
    </fullquery>
</queryset>