<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="file_move">      
      <querytext>

    	select content_item__move (
    		:file_id,	-- item_id
    		:parent_id	-- target_folder_id
    		);

      </querytext>
</fullquery>

 
</queryset>
