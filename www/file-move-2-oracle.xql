<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="file_move">      
      <querytext>
      
	begin
    		content_item.move (
    			item_id => :file_id,
    			target_folder_id => :parent_id
    			);
	end;

      </querytext>
</fullquery>

 
</queryset>
