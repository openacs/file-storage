<?xml version="1.0"?>
<queryset>

<fullquery name="context_update">      
      <querytext>
      
	update acs_objects
	set    context_id = :parent_id
	where  object_id = :file_id

      </querytext>
</fullquery>

 
<fullquery name="filename">      
      <querytext>
      
    	select name from cr_items where item_id = :file_id

      </querytext>
</fullquery>

 
<fullquery name="duplicate_check">      
      <querytext>
      
    	select count(*)
    	from   cr_items
    	where  name = :filename
    	and    parent_id = :folder_id

      </querytext>
</fullquery>

 
</queryset>
