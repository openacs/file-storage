<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="fs::new_root_folder.new_root_folder">
        <querytext>
            begin
                :1 := file_storage.new_root_folder(
	 	    folder_url => :name,
		    package_id => :package_id,
                    folder_name => :pretty_name,
		    description => :description
                );
            end;
        </querytext>
    </fullquery>

    <fullquery name="fs::get_root_folder.get_root_folder">
        <querytext>
            begin
                :1 := file_storage.get_root_folder(
                    package_id => :package_id
                );
            end;
        </querytext>
    </fullquery>

    <fullquery name="fs::new_folder.new_folder">
        <querytext>
            begin
                :1 := file_storage.new_folder(
                    name => :name,
                    folder_name => :pretty_name,
                    parent_id => :parent_id,
                    creation_user => :creation_user,
                    creation_ip => :creation_ip
                );
            end;
        </querytext>
    </fullquery>

    <fullquery name="fs::rename_folder.rename_folder">
        <querytext>
            begin
                content_folder.edit_name(
                    folder_id => :folder_id,
                    label => :name
                );
            end;
        </querytext>
    </fullquery>

    <fullquery name="fs::get_folder_contents.select_folder_contents">
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
                   case when fs_objects.last_modified >= (sysdate - :n_past_days) then 1 else 0 end as new_p,
                   acs_permission.permission_p(fs_objects.object_id, :user_id, 'admin') as admin_p,
                   acs_permission.permission_p(fs_objects.object_id, :user_id, 'delete') as delete_p,
                   acs_permission.permission_p(fs_objects.object_id, :user_id, 'write') as write_p
            from fs_objects
            where fs_objects.parent_id = :folder_id
              and exists (select 1
                   from acs_object_party_privilege_map m
                   where m.object_id = fs_objects.object_id
                     and m.party_id = :user_id
                     and m.privilege = 'read')
            order by fs_objects.sort_key, fs_objects.name
        </querytext>
    </fullquery>

    <fullquery name="fs_get_folder_name.folder_name">
        <querytext>
            begin
                :1 := file_storage.get_folder_name(:folder_id);
            end;
        </querytext>
    </fullquery>

    <fullquery name="children_have_permission_p.child_perms">
        <querytext>
            select count(*)
            from cr_items
            where item_id in (select item_id
                              from cr_items
                              connect by prior item_id = parent_id
                              start with item_id = :item_id)
            and acs_permission.permission_p(item_id, :user_id, :privilege) = 'f'
        </querytext>
    </fullquery>

    <fullquery name="children_have_permission_p.child_items">
        <querytext>
            select item_id as child_item_id
            from cr_items
            connect by prior item_id = parent_id
            start with item_id = :item_id
        </querytext>
    </fullquery>

    <fullquery name="children_have_permission_p.revision_perms">
        <querytext>
            select count(*)
            from cr_revisions
            where item_id = :child_item_id
            and acs_permission.permission_p(revision_id, :user_id, :privilege) = 'f'
        </querytext>
    </fullquery>

    <fullquery name="fs_context_bar_list.title">
        <querytext>
            begin
                :1 := file_storage.get_title(:item_id);
            end;
        </querytext>
    </fullquery>

    <fullquery name="fs_context_bar_list.context_bar">
        <querytext>
            select case when file_storage.get_content_type(i.item_id) = 'content_folder'
                        then :folder_url || '?folder_id='
                        else :file_url || '?file_id='
                   end || i.item_id,
                   file_storage.get_title(i.item_id)
            from cr_items i
            where item_id not in (select i2.item_id
                                  from cr_items i2
                                  connect by prior i2.parent_id = i2.item_id
                                  start with i2.item_id = :root_folder_id)
            connect by prior i.parent_id = i.item_id
            start with item_id = :start_id
            order by level desc
        </querytext>
    </fullquery>

   <fullquery name="fs::do_notifications.get_owner_name">
        <querytext>
	  select person.name(o.creation_user) as owner
		 from acs_objects o where o.object_id = :item_id
        </querytext>
    </fullquery>

    <fullquery name="fs::do_notifications.path1">
       <querytext>
		select site_node.url(node_id) as path1 from site_nodes
		where object_id = (select package_id
				   from fs_root_folders where
				   fs_root_folders.folder_id = :root_folder)
       </querytext>
    </fullquery>

    <fullquery name="fs::publish_versioned_object_to_file_system.select_object_content">
        <querytext>
            select content
            from cr_revisions
            where revision_id = $live_revision
        </querytext>
    </fullquery>

    <fullquery name="fs::publish_versioned_object_to_file_system.select_file_name">
        <querytext>
            select filename
            from cr_revisions
            where revision_id = :live_revision
        </querytext>
    </fullquery>
  
    <fullquery name="fs::get_item_id.get_item_id">
      <querytext>
        begin
          :1 := content_item.get_id ( :name, :folder_id, 'f' );
	end;
      </querytext>
    </fullquery>


  <fullquery name="fs::add_file.create_item">
    <querytext>
      	begin 
          :1 := file_storage.new_file (
                  folder_id => :parent_id,
                  title => :name,
		  creation_user => :creation_user,
		  creation_ip => :creation_ip,
		  item_id => :item_id,
		  indb_p => :indbp
               );
	end;
    </querytext>
  </fullquery>

<fullquery name="fs::delete_version::delete_version">      
      <querytext>

	begin
	   :1 := file_storage.delete_version(
			:item_id,
			:version_id
			);
	end;

      </querytext>
</fullquery>

  <fullquery name="fs::delete_file.delete_file">      
      <querytext>
	
	
	begin
	    file_storage.delete_file(
			:item_id
			);
	end;

      </querytext>
  </fullquery>

  <fullquery name="fs::delete_folder.delete_folder">      
      <querytext>

	begin
	        file_storage.delete_folder(:folder_id, :cascade_p );
	end;
      </querytext>
  </fullquery>
  
  <fullquery name="fs::add_version.update_last_modified">
    <querytext>
      begin
      acs_object.update_last_modified(:parent_id,:creation_user,:creation_ip);
      acs_object.update_last_modified(:item_id,:creation_user,:creation_ip);
      end;
    </querytext>
  </fullquery>

  <fullquery name="fs::get_folder_package_and_root.select_package_and_root">
    <querytext>
	select r.package_id,
               r.folder_id as root_folder_id
	from fs_root_folders r,
	     (select item_id as folder_id
              from cr_items
              connect by prior parent_id = item_id 
              start with item_id = :folder_id) t
        where r.folder_id = t.folder_id
    </querytext>
  </fullquery>

  <fullquery name="fs::notification::get_url.select_fs_package_url">
    <querytext>
      select site_node.url(node_id) 
      from site_nodes
      where object_id = (select r.package_id,
               r.folder_id as root_folder_id
	from fs_root_folders r,
	     (select item_id as folder_id
              from cr_items
              connect by prior parent_id = item_id 
              start with item_id = :folder_id) t
        where r.folder_id = t.folder_id)
    </querytext>
  </fullquery>

    <fullquery name="fs::get_object_prettyname.select_object_prettyname">
        <querytext>
            select nvl(title,name) as prettyname
            from fs_objects
            where object_id = :object_id
        </querytext>
    </fullquery>

</queryset>
