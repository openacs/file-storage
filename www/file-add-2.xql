<?xml version="1.0"?>
<queryset>

<fullquery name="duplicate_check">      
      <querytext>
      
    	select count(*)
   	from   cr_items
	where  name = :filename
    	and    parent_id = :folder_id

      </querytext>

</fullquery>

 
</queryset>
