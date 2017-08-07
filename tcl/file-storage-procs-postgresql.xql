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

    <fullquery name="fs::get_folder_objects.select_folder_contents">
        <querytext>

          select cr_items.item_id as object_id, cr_items.name
          from   cr_items
          where  cr_items.parent_id = :folder_id
          and    acs_permission__permission_p(cr_items.item_id, :user_id, 'read')

        </querytext>
    </fullquery>

    <fullquery name="fs::get_folder_contents.select_folder_contents">
        <rdbms><type>postgresql</type><version>8.4</version></rdbms>
        <querytext>

           select fs_objects.object_id,
           fs_objects.name,
           fs_objects.title,
           fs_objects.live_revision,
           fs_objects.type,
           to_char(fs_objects.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,
           fs_objects.content_size,
           fs_objects.url,
           fs_objects.key,
           fs_objects.sort_key,
           fs_objects.file_upload_name,
           fs_objects.title,
           case when fs_objects.last_modified >= (now() - interval '$n_past_days days') then 1 else 0 end as new_p,
           acs_permission__permission_p(fs_objects.object_id, :user_id, 'admin') as admin_p,
           acs_permission__permission_p(fs_objects.object_id, :user_id, 'delete') as delete_p,
           acs_permission__permission_p(fs_objects.object_id, :user_id, 'write') as write_p
           from fs_objects
           where fs_objects.parent_id = :folder_id
           and acs_permission__permission_p(fs_objects.object_id, :user_id, 'read')
           order by fs_objects.sort_key, fs_objects.name

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
            from cr_items c1, cr_items c2
            where c2.item_id = :item_id
            and c1.tree_sortkey between c2.tree_sortkey and tree_right(c2.tree_sortkey)
            and not acs_permission__permission_p(c1.item_id, :user_id, :privilege)
        </querytext>
    </fullquery>

    <fullquery name="children_have_permission_p.child_items">
        <querytext>
            select c1.item_id as child_item_id
            from cr_items c1, cr_items c2
            where c2.item_id = :item_id
            and c1.tree_sortkey between c2.tree_sortkey and tree_right(c2.tree_sortkey)
            order by c1.tree_sortkey
        </querytext>
    </fullquery>

    <fullquery name="children_have_permission_p.revision_perms">
        <querytext>
            select count(*)
            from cr_revisions
            where item_id = :child_item_id
            and acs_permission__permission_p(revision_id, :user_id, :privilege) = 'f'
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

    <fullquery name="fs::do_notifications.get_owner_name">
        <querytext>
	  select person__name(o.creation_user) as owner from
          acs_objects o where o.object_id = :item_id
        </querytext>
    </fullquery>

    <fullquery name="fs::do_notifications.path1">
       <querytext>
		select site_node__url(node_id) as path1 from site_nodes
		       where object_id = (select package_id
						 from fs_root_folders where
						 fs_root_folders.folder_id = :root_folder)
       </querytext>
    </fullquery>

    <fullquery name="fs::publish_versioned_object_to_file_system.select_object_content">
        <querytext>
            select lob
            from cr_revisions
            where revision_id = $live_revision
        </querytext>
    </fullquery>

    <fullquery name="fs::publish_versioned_object_to_file_system.select_file_name">
        <querytext>
            select content
            from cr_revisions
            where revision_id = :live_revision
        </querytext>
    </fullquery>

    <fullquery name="fs::get_item_id.get_item_id">
      <querytext>
        select content_item__get_id ( :name, :folder_id, 'f' )
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
        select file_storage__delete_folder (
                       :folder_id,
                       :cascade_p
                       )
     </querytext>
  </fullquery>
  
  <fullquery name="fs::add_version.update_last_modified">
    <querytext>
      begin
      perform acs_object__update_last_modified
      (:parent_id,:creation_user,:creation_ip);
      perform
      acs_object__update_last_modified(:item_id,:creation_user,:creation_ip);
      return null;
      end;
    </querytext>
  </fullquery>

  <fullquery name="fs::get_folder_package_and_root.select_package_and_root">
    <querytext>
      select r.package_id,
             r.folder_id as root_folder_id
      from fs_root_folders r,
           (select parent.item_id as folder_id
            from cr_items parent,
                 cr_items children
            where children.item_id = :folder_id
              and children.tree_sortkey
                between parent.tree_sortkey
                and tree_right(parent.tree_sortkey)) t
      where r.folder_id = t.folder_id
    </querytext>
  </fullquery>

  <fullquery name="fs::add_created_version.new_file_revision">
    <querytext>
	select content_revision__new (
	      :title,    	-- title
              :description,	-- description
	      now(),		-- publish_date
	      :mime_type, 	-- mime_type
	      null,		-- ns_language
	      :content_body,	-- text
	      :item_id,		-- item_id
	      null,
	      now(),		-- creation_date
	      :creation_user, 	-- creation_user
	      :creation_ip,	-- creation_ip
	      null,	
	      :package_id	-- package_id
	)
    </querytext>
  </fullquery>

  <fullquery name="fs::add_created_version.new_text_revision">
    <querytext>
	select content_revision__new (
	      :title,    	-- title
              :description,	-- description
	      now(),		-- publish_date
	      :mime_type, 	-- mime_type
	      null,		-- ns_language
	      :content_body,	-- text
	      :item_id,		-- item_id
	      null,
	      now(),		-- creation_date
	      :creation_user, 	-- creation_user
	      :creation_ip,	-- creation_ip
	      null,	
	      :package_id	-- package_id
	)
    </querytext>
  </fullquery>

<fullquery name="fs::add_created_version.set_lob_content">      
      <querytext>

      update cr_revisions
      set mime_type = :mime_type,
         lob = [set __lob_id [db_string get_lob_id "select empty_lob()"]]
      where revision_id = :revision_id
         
      </querytext>
</fullquery>
 
<fullquery name="fs::add_created_version.set_lob_size">      
      <querytext>

         update cr_revisions
         set content_length = lob_length(lob)
         where revision_id = :revision_id

      </querytext>
</fullquery>


  <fullquery name="fs::add_created_version.update_last_modified">
    <querytext>
      begin
      perform acs_object__update_last_modified
      (:parent_id,:creation_user,:creation_ip);
      perform
      acs_object__update_last_modified(:item_id,:creation_user,:creation_ip);
      return null;
      end;
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

    <fullquery name="fs::get_object_prettyname.select_object_prettyname">
        <querytext>
            select coalesce(title,name) as prettyname
            from fs_objects
            where object_id = :object_id
        </querytext>
    </fullquery>

</queryset>
