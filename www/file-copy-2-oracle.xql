<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="file_copy">      
      <querytext>

   	 begin
          :1 :=	file_storage.copy_file(
            		file_id => :file_id,
            		target_folder_id => :parent_id,
            		creation_user => :user_id,
            		creation_ip => :ip_address
            		);
    	 end;

      </querytext>
</fullquery>

</queryset>
