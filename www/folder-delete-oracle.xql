<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="folder_delete">      
      <querytext>
      
    begin
        file_storage.delete_folder(:folder_id);
    end;

      </querytext>
</fullquery>

 
</queryset>
