<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>
 
<fullquery name="duplicate_check">      
      <querytext>
      
    	select count(*)
    	from   cr_items
    	where  name = :title
    	and    parent_id = content_item.get_parent_folder(:file_id)

      </querytext>
</fullquery>


</queryset>
