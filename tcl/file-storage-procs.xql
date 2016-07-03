<?xml version="1.0"?>
<queryset>

    <fullquery name="fs_folder_p.object_type">      
        <querytext>
            select object_type 
            from acs_objects
            where object_id = :folder_id
        </querytext>
    </fullquery>

    <fullquery name="fs_context_bar_list.parent_id">      
        <querytext>
            select parent_id
            from cr_items
            where item_id = :item_id
        </querytext>
    </fullquery>

    <fullquery name="fs::get_folder.select_folder">
        <querytext>
            select item_id
            from cr_items
            where parent_id = :parent_id
            and name = :name
        </querytext>
    </fullquery>

    <fullquery name="fs::object_p.select_object_p">
        <querytext>
            select count(*)
            from dual
            where exists (select 1
                          from fs_objects
                          where object_id = :object_id)
        </querytext>
    </fullquery>

    <fullquery name="fs::get_object_name.select_object_name">
        <querytext>
            select name
            from fs_objects
            where object_id = :object_id
        </querytext>
    </fullquery>

    <fullquery name="fs::folder_p.select_folder_p">
        <querytext>
            select count(*)
            from dual
            where exists (select 1
                          from fs_folders
                          where folder_id = :object_id)
        </querytext>
    </fullquery>

    <fullquery name="fs::get_folder_contents_count.select_folder_contents_count">
        <querytext>
            select count(*)
            from fs_objects
            where parent_id = :folder_id
        </querytext>
    </fullquery>

    <fullquery name="fs::publish_object_to_file_system.select_object_info">
        <querytext>
            select fs_objects.*
            from fs_objects
            where fs_objects.object_id = :object_id
        </querytext>
    </fullquery>

    <fullquery name="fs::publish_url_to_file_system.select_object_metadata">
        <querytext>
            select fs_urls_full.*
            from fs_urls_full
            where fs_urls_full.object_id = :object_id
        </querytext>
    </fullquery>

    <fullquery name="fs::publish_versioned_object_to_file_system.select_object_metadata">
        <querytext>
            select fs_objects.*,
                   cr_items.storage_type,
                   cr_items.storage_area_key,
                   cr_revisions.title
            from fs_objects,
                 cr_items,
                 cr_revisions
            where fs_objects.object_id = :object_id
            and fs_objects.object_id = cr_items.item_id
            and fs_objects.live_revision = cr_revisions.revision_id
        </querytext>
    </fullquery>

    <fullquery name="fs::add_file.item_exists">
      <querytext>
          select count(*) from cr_items
          where name=:name
          and parent_id=:parent_id
      </querytext>
    </fullquery>

    <fullquery name="fs::add_file.get_old_item">
      <querytext>
          select item_id from cr_items
          where name=:name
          and parent_id=:parent_id
      </querytext>
    </fullquery>

  <fullquery name="fs::get_parent.get_parent_id">
    <querytext>
	select parent_id from cr_items where item_id=:item_id
    </querytext>
  </fullquery>

<fullquery name="fs::delete_file.version_name">      
      <querytext>
      
    	select i.name as title, r.title as version_name 
	from cr_items i, cr_revisions r
	where i.item_id = r.item_id
	and r.revision_id = :version_id

      </querytext>
</fullquery>

  <fullquery name="fs::set_folder_description.set_folder_description">
    <querytext>
      update cr_folders set description=:description
      where folder_id = :folder_id
    </querytext>
  </fullquery>

<fullquery name="fs::add_version.get_storage_type">
  <querytext>
    select storage_type from cr_items where item_id=:item_id
  </querytext>
</fullquery>

  <fullquery name="fs::get_file_package_id.select_package_id">
    <querytext>
      select package__id
      from acs_objects
      where object_id = :file_id
    </querytext>
  </fullquery>

<fullquery name="fs::add_created_version.get_storage_type">
  <querytext>
    select storage_type from cr_items where item_id=:item_id
  </querytext>
</fullquery>

<fullquery name="fs::add_created_version.set_live_revision">
  <querytext>
      update cr_items set live_revision=:revision_id
      where item_id=:item_id
  </querytext>
</fullquery>

<fullquery name="fs::add_created_version.update_revision">
  <querytext>
	update	cr_revisions
	set content = :cr_file,	content_length = :file_size
	where revision_id = :revision_id
  </querytext>
</fullquery>

<fullquery name="fs::add_created_file.item_exists">
   <querytext>
          select count(*) from cr_items
          where name=:name
          and parent_id=:parent_id
   </querytext>
</fullquery>
   <fullquery name="fs::file_copy.file_data">
         <querytext>

	select i.name, i.latest_revision as file_rev_id, r.title
	from cr_items i, cr_revisions r
	where i.item_id = :file_id
	and r.revision_id = i.latest_revision

         </querytext>
   </fullquery>

   <fullquery name="fs::file_copy.update_title">
         <querytext>

	    update cr_revisions
	    set title = :title
	    where revision_id = :new_file_rev_id

         </querytext>
   </fullquery>

<fullquery name="fs::delete_file.get_all_symlinks">
	<querytext>
		select symlink_id from cr_symlinks
		where target_id=:item_id
	</querytext>
</fullquery>

   <fullquery name="fs::file_copy.file_data">
         <querytext>

	select i.name, i.latest_revision as file_rev_id, r.title
	from cr_items i, cr_revisions r
	where i.item_id = :file_id
	and r.revision_id = i.latest_revision

         </querytext>
   </fullquery>

   <fullquery name="fs::file_copy.update_title">
         <querytext>

	    update cr_revisions
	    set title = :title
	    where revision_id = :new_file_rev_id

         </querytext>
   </fullquery>

</queryset>
