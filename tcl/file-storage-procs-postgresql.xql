<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="fs::new_root_folder.new_root_folder">
        <querytext>
            select file_storage__new_root_folder(
                :package_id,
                :pretty_name,
                :description
            );
        </querytext>
    </fullquery>

    <fullquery name="fs::get_root_folder.get_root_folder">
        <querytext>
            select file_storage__get_root_folder(:package_id);
        </querytext>
    </fullquery>

    <fullquery name="fs::new_folder.new_folder">
        <querytext>
            select file_storage__new_folder(
                :name,
                :pretty_name,
                :parent_id,
                :creation_user,
                :creation_ip
            );
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

    	select (case when file_storage__get_content_type(i.item_id) = 'content_folder' 
	             then 'index?folder_id=' 
	             else 'file?file_id=' 
                end) || i.item_id,
           	file_storage__get_title(i.item_id)
        from (select tree_ancestor_keys(cr_items_get_tree_sortkey(:start_id)) as tree_sortkey) parents,
          (select tree_sortkey from cr_items where item_id = file_storage__get_root_folder([ad_conn package_id])) root,
          cr_items i
        where i.tree_sortkey = parents.tree_sortkey
          and i.tree_sortkey > root.tree_sortkey
    	order by i.tree_sortkey asc

      </querytext>
</fullquery>

 
</queryset>






