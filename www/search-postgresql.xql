<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="results">      
      <querytext>
      
    	select item_id as file_id,
           	content_item__get_title(item_id) as title
    		from   cr_items
    		where  lower(content_item__get_title(item_id)) like :query
    		and    acs_permission__permission_p(item_id,:user_id,'read') = 't'

      </querytext>
</fullquery>

 
</queryset>
