<?xml version="1.0"?>
<queryset>

<fullquery name="select_folder_id">      
      <querytext>
         select parent_id as folder_id
         from cr_items
         where item_id = :object_id
      </querytext>
</fullquery>
 
</queryset>
