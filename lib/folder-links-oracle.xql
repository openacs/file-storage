<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <partialquery name="permission_clause">
    <querytext>
    and exists (select 1
                   from acs_object_party_privilege_map m
                   where m.object_id = fs_objects.object_id
                     and m.party_id = :viewing_user_id
                     and m.privilege = 'read')
    </querytext>
  </partialquery>
  
    <fullquery name="get_folder_path">
        <querytext>
            declare begin
                :1 := content_item.get_path(:folder_id, :root_folder_id);
            end;
        </querytext>
    </fullquery>

</queryset>
