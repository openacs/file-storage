<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="file_move">      
      <querytext>
      
	begin
    		file_storage.move_file (
    			file_id => :file_id,
    			target_folder_id => :parent_id,
                        creation_user => :user_id,
                        creation_ip => :address
    			);
	end;

      </querytext>
</fullquery>

 
</queryset>
