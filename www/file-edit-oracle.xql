<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="file_info">      
      <querytext>
      
	select name as title
	from   cr_items
	where  item_id = :file_id

      </querytext>
</fullquery>

 
</queryset>
