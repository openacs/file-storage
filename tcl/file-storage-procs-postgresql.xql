<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="fs_get_root_folder.fs_root_folder">      
      <querytext>

	select file_storage__get_root_folder(:package_id);

      </querytext>
</fullquery>

 
<fullquery name="fs_get_folder_name.folder_name">      
      <querytext>

	select content_folder__get_label(:folder_id);

      </querytext>
</fullquery>

 
<fullquery name="children_have_permission_p.child_perms">      
      <querytext>

    	select count(*)
    	from   cr_items
    	where  item_id in (select item_id
                       	   from   cr_items
			   where tree_sortkey like (select tree_sortkey || '%'
						    from cr_items
						    where item_id = :item_id)
			    order by tree_sortkey)
    	and    acs_permission__permission_p(item_id,:user_id,:privilege) = 'f'

      </querytext>
</fullquery>

 
<fullquery name="children_have_permission_p.child_items">      
      <querytext>

	select item_id as child_item_id
	from   cr_items
   	where tree_sortkey like (select tree_sortkey || '%'
				from cr_items
				where item_id = :item_id)
	order by tree_sortkey
	
      </querytext>
</fullquery>

 
<fullquery name="children_have_permission_p.revision_perms">      
      <querytext>
      
	select count(*)
	from   cr_revisions
	where  item_id = :child_item_id
	and    acs_permission__permission_p(revision_id,:user_id,:privilege) = 'f'

      </querytext>
</fullquery>

 
<fullquery name="fs_context_bar_list.title">      
      <querytext>

	select content_item__get_title(:item_id);

      </querytext>
</fullquery>

 
<fullquery name="fs_context_bar_list.context_bar">      
      <querytext>

    	select (case when content_item__get_content_type(j.item_id) = 'content_folder' 
	             then '?folder_id=' 
	             else 'file?file_id=' 
                end) || j.item_id,
           	content_item__get_title(j.item_id)
        from   cr_items i,cr_items j
        where  j.item_id not in (select o2.item_id
        		         from   cr_items o1, cr_items o2
			         where o1.item_id = file_storage__get_root_folder([ad_conn package_id])
				 and o2.tree_sortkey <= o1.tree_sortkey
				 and o1.tree_sortkey like (o2.tree_sortkey || '%')
				)
	and i.item_id = :start_id
	and j.tree_sortkey <= i.tree_sortkey
	and i.tree_sortkey like (j.tree_sortkey || '%')
    	order by j.tree_sortkey asc

      </querytext>
</fullquery>

 
</queryset>






