<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="folder">
      <querytext>

	select lpad('&nbsp;&nbsp;',12 * tree_level(i.tree_sortkey),'&nbsp;&nbsp;') as spaces,
     		(select f.label from cr_folders f where f.folder_id = i.item_id) as label,
     		(select f.folder_id from cr_folders f where f.folder_id = i.item_id) as new_parent
	from   cr_items i
	where  acs_permission__permission_p(i.item_id,:user_id,'write') = 't'
	and    exists (select 1 from cr_folders f where f.folder_id = i.item_id)
	$children_clause
	and i.tree_sortkey like (select l.tree_sortkey || '%'
				 from cr_items l
				 where l.item_id = file_storage__get_root_folder(:package_id))
	order by i.tree_sortkey


      </querytext>
</fullquery> 

<partialquery name="children_clause">      
      <querytext>

    	and i.item_id not in (select j.item_id
    			      from cr_items j
    			      where j.item_id != :file_id
    			      and j.tree_sortkey like (select k.tree_sortkey || '%'
						       from cr_items k
						       where k.item_id = :file_id)) 

      </querytext>
</partialquery> 	


</queryset>
