<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="fs::simple_delete.delete_item">
<querytext>
declare
begin
fs_simple_object.delete(:object_id);
end;
</querytext>
</fullquery>
 
</queryset>
