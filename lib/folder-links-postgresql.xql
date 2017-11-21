<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.3</version></rdbms>
  
  <partialquery name="permission_clause">
    <querytext>
      and acs_permission__permission_p(fs_objects.object_id, :viewing_user_id, 'read')
    </querytext>
  </partialquery>

  <fullquery name="get_folder_path">
    <querytext>
      select content_item__get_path(:folder_id, :root_folder_id)
    </querytext>
  </fullquery>

</queryset>
