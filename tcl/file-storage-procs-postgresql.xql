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

	select file_storage__get_folder_name(:folder_id);

      </querytext>
</fullquery>

 
<fullquery name="children_have_permission_p.child_perms">      
      <querytext>

    	select count(*)
    	from   cr_items c1, cr_items c2
    	where  c2.item_id = :item_id
          and c1.tree_sortkey between c2.tree_sortkey and tree_right(c2.tree_sortkey)
    	  and not acs_permission__permission_p(c1.item_id,:user_id,:privilege)

      </querytext>
</fullquery>

 
<fullquery name="children_have_permission_p.child_items">      
      <querytext>

	select c1.item_id as child_item_id
	from   cr_items c1, cr_items c2
   	where c2.item_id = :item_id
          and c1.tree_sortkey between c2.tree_sortkey and tree_right(c2.tree_sortkey)
	order by c1.tree_sortkey
	
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

	select file_storage__get_title(:item_id)

      </querytext>
</fullquery>

 
<fullquery name="fs_context_bar_list.context_bar">      
      <querytext>

    	select (case when file_storage__get_content_type(j.item_id) = 'content_folder' 
	             then 'index?folder_id=' 
	             else 'file?file_id=' 
                end) || j.item_id,
           	file_storage__get_title(j.item_id)
        from   cr_items i, cr_items j, cr_items k
        where i.item_id = :start_id
          and k.item_id = file_storage__get_root_folder([ad_conn package_id])
          and j.tree_sortkey between tree_left(k.tree_sortkey) and i.tree_sortkey
          and tree_ancestor_p(j.tree_sortkey, i.tree_sortkey)
    	order by j.tree_sortkey asc

      </querytext>
</fullquery>

 
</queryset>






