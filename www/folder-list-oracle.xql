<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="folder">
      <querytext>

	select lpad('&nbsp;&nbsp;',12 * level,'&nbsp;&nbsp;') as spaces,
     		(select f.label from cr_folders f where f.folder_id = i.item_id) as label,
     		(select f.folder_id from cr_folders f where f.folder_id = i.item_id) as new_parent
	from   cr_items i
	where  acs_permission.permission_p(i.item_id,:user_id,'write') = 't'
	and    exists (select 1 from cr_folders f where f.folder_id = i.item_id)
	$children_clause
	connect by prior item_id = parent_id
	start with item_id = file_storage.get_root_folder([ad_conn package_id])

      </querytext>
</fullquery> 

<partialquery name="children_clause">      
      <querytext>

    	and item_id not in (select item_id
    	from cr_items
    	where item_id != :file_id
    	connect by prior item_id = parent_id
    	start with item_id = :file_id)


      </querytext>
</partialquery> 	

</queryset>
