<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="delete_version">      
      <querytext>

	begin
	   :1 := file_storage.delete_version(
			:item_id,
			:version_id
			);
	end;

      </querytext>
</fullquery>

<fullquery name="delete_file">      
      <querytext>
	
	begin
		file_storage.delete_file(
			:item_id
			);
	end;

      </querytext>
</fullquery>

</queryset>
