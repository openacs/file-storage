<?xml version="1.0"?>
<queryset>

<fullquery name="child_count">      
      <querytext>
      
	select count(*) from cr_items where parent_id = :folder_id
      </querytext>
</fullquery>

 
<fullquery name="parent_id">      
      <querytext>
      
    select parent_id from cr_items where item_id = :folder_id
      </querytext>
</fullquery>

 
<fullquery name="folder_name">      
      <querytext>
      
    select label from cr_folders where folder_id = :folder_id
      </querytext>
</fullquery>

 
</queryset>
