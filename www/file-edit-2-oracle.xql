<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="rename">      
      <querytext>
      
	begin
    		content_item.rename (
        		item_id => :file_id,
        		name => :name
    			);
	end;

      </querytext>
</fullquery>

 
<fullquery name="duplicate_check">      
      <querytext>
      
    	select count(*)
    	from   cr_items
    	where  name = :name
    	and    parent_id = content_item.get_parent_folder(:file_id)

      </querytext>
</fullquery>

 
</queryset>
