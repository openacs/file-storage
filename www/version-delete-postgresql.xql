<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="delete_version">      
      <querytext>

	select file_storage__delete_version(
			:item_id,
			:version_id
			);
      </querytext>
</fullquery>

<fullquery name="delete_file">      
      <querytext>

	select file_storage__delete_file(
			:item_id
			);
      </querytext>
</fullquery>

</queryset>

