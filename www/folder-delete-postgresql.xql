<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="folder_delete">      
      <querytext>

        select file_storage__delete_folder(:folder_id);

      </querytext>
</fullquery>

 
</queryset>
