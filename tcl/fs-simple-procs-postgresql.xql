<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="fs::simple_delete.delete_item">
  <querytext>
    select fs_simple_object__delete(:object_id);
  </querytext>
</fullquery>

<fullquery name="fs::url_copy.copy">
  <querytext>
  </querytext>
</fullquery>
 
</queryset>
