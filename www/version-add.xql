<?xml version="1.0"?>
<queryset>

<fullquery name="file_name">      
      <querytext>
      
	select name as title
        from   cr_items
        where  item_id = :file_id

      </querytext>
</fullquery>

 
</queryset>
