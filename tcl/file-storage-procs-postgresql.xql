<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="fs::new_root_folder.new_root_folder">
        <querytext>
	select file_storage__new_root_folder (
	    :package_id,
            :pretty_name, -- label
	    :name, -- name
	    :description
        )
        </querytext>
    </fullquery>

    <fullquery name="fs::get_root_folder.get_root_folder">
        <querytext>
            select file_storage__get_root_folder(:package_id);
        </querytext>
    </fullquery>

    <fullquery name="fs::rename_folder.rename_folder">
        <querytext>
            select content_folder__edit_name(
                :folder_id,
                null,
                :name,
                null
            );
        </querytext>
    </fullquery>

    <fullquery name="fs_get_folder_name.folder_name">
        <querytext>
            select file_storage__get_folder_name(:folder_id);
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
                         then :folder_url || '?folder_id='
                         else :file_url || '?file_id='
                    end) || i.item_id || :extra_vars,
                   file_storage__get_title(i.item_id)
            from (select tree_ancestor_keys(cr_items_get_tree_sortkey(:start_id)) as tree_sortkey) parents,
                 (select tree_sortkey from cr_items where item_id = :root_folder_id) root,
                 cr_items i
            where i.tree_sortkey = parents.tree_sortkey
            and i.tree_sortkey > root.tree_sortkey
            order by i.tree_sortkey asc
        </querytext>
    </fullquery>

  <fullquery name="fs::add_file.create_item">
    <querytext>
      select file_storage__new_file (
          :name,
          :parent_id,
	  :creation_user,
          :creation_ip,
          :indbp,
          :item_id,
          :package_id
      )
    </querytext>
  </fullquery>

  <fullquery name="fs::delete_version.delete_version">      
      <querytext>

	select file_storage__delete_version(
			:item_id,
			:version_id
			);
      </querytext>
  </fullquery>

   <fullquery name="fs::delete_file.delete_file">      
      <querytext>

	select file_storage__delete_file(
			:item_id
			);
      </querytext>
  </fullquery>

  <fullquery name="fs::delete_folder.delete_folder">
     <querytext>
       select content_folder__del(:folder_id, :cascade_p)
     </querytext>
  </fullquery>
  
  <fullquery name="fs::get_folder_package_and_root.select_package_and_root">
    <querytext>
      With RECURSIVE items AS (
        select cr.item_id from cr_items cr where cr.item_id = :folder_id
      UNION ALL
        select cr.parent_id from cr_items cr, items where items.item_id = cr.item_id
      )
      select r.package_id, r.folder_id as root_folder_id
      from   items i, fs_root_folders r
      where  r.folder_id = i.item_id
    </querytext>
  </fullquery>

  <fullquery name="fs::add_created_file.create_item">
    <querytext>
      select file_storage__new_file (
          :name,
          :parent_id,
	  :creation_user,
          :creation_ip,
          :indbp,
          :item_id,
          :package_id
      )
    </querytext>
  </fullquery>

</queryset>
