<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="folder_rename">
      <querytext>
      select content_folder__rename (
                  :folder_id, 
                  null,    -- name
                  :folder_name, -- label
                  null -- description
          );
      </querytext>
</fullquery>

</queryset>
