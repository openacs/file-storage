<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="folder_rename">
      <querytext>
      begin
          content_folder.rename (
                  folder_id => :folder_id,
                  label => :folder_name
          );
      end;
      </querytext>
</fullquery>

</queryset>
