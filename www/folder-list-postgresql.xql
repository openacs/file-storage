<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="folder">
      <querytext>

	select lpad('&nbsp;&nbsp;',12 * tree_level(i.tree_sortkey),'&nbsp;&nbsp;') as spaces,
     		(select f.label from cr_folders f where f.folder_id = i.item_id) as label,
     		(select f.folder_id from cr_folders f where f.folder_id = i.item_id) as new_parent
	from   cr_items i, cr_items l
	where acs_permission__permission_p(i.item_id,:user_id,'write') 
          and exists (select 1 from cr_folders f where f.folder_id = i.item_id)
          $children_clause
          and i.tree_sortkey between l.tree_sortkey and tree_right(l.tree_sortkey)
          and l.item_id = file_storage__get_root_folder(:package_id)
	order by i.tree_sortkey


      </querytext>
</fullquery> 

<partialquery name="children_clause">      
      <querytext>

    	and not exists (select 1
    			from cr_items j, cr_items k
    			where i.item_id = j.item_id
                          and j.item_id != :file_id
    			  and j.tree_sortkey between k.tree_sortkey and tree_right(k.tree_sortkey)
                          and k.item_id = :file_id) 

      </querytext>
</partialquery> 	


</queryset>
