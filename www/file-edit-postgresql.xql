<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="file_info">      
      <querytext>
      
	select content_item__get_title(:file_id) as title,name
	from   cr_items
	where  item_id = :file_id

      </querytext>
</fullquery>

 
</queryset>
