<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="file_move">      
      <querytext>

    	select file_storage__move_file (
    		:file_id,	-- file_id
    		:parent_id	-- target_folder_id
    		);

      </querytext>
</fullquery>

 
</queryset>
