<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="folder_create">      
      <querytext>
      
begin
    :1 := file_storage.new_folder (
        name => :name,
        folder_name => :folder_name,
        parent_id => :parent_id,
        creation_user => :user_id,
        creation_ip => :creation_ip
    );
end;
      </querytext>
</fullquery>

</queryset>
