<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="rename">      
      <querytext>

    	select content_item__rename (
        	:file_id, -- item_id
        	:name	  -- name
    		);

      </querytext>
</fullquery>

 
<fullquery name="duplicate_check">      
      <querytext>
      
    	select count(*)
    	from   cr_items
    	where  name = :name
    	and    parent_id = content_item__get_parent_folder(:file_id)

      </querytext>
</fullquery>

 
</queryset>
