<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="fs::new_root_folder.new_root_folder">
        <querytext>
            begin
                :1 := file_storage.new_root_folder(
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

    <fullquery name="fs::get_folder_contents.get_folder_contents">
        <querytext>
            select cr_items.item_id as file_id,
                   cr_items.name as name,
                   cr_items.live_revision,
                   cr_revisions.mime_type as type,
                   to_char(acs_objects.last_modified,'YYYY-MM-DD HH24:MI') as last_modified,
                   cr_revisions.content_length as content_size,
                   1 as sort_key
            from cr_items,
                 cr_revisions,
                 acs_objects
            where cr_items.parent_id = :folder_id
            and cr_items.content_type = 'file_storage_object'
            and 't' = acs_permission.permission_p(cr_items.item_id, :user_id, 'read')
            and cr_items.item_id = acs_objects.object_id
            and cr_items.live_revision = cr_revisions.revision_id(+)
            union
            select cr_items.item_id as file_id,
                   cr_folders.label as name,
                   0 as live_revision,
                   'Folder' as type,
                   NULL as last_modified,
                   0 as content_size,
                   0 as sort_key
            from cr_items,
                 cr_folders
            where cr_items.parent_id = :folder_id
            and cr_items.item_id = cr_folders.folder_id
            and 't' = acs_permission.permission_p(cr_folders.folder_id, :user_id, 'read')
            order by sort_key, name
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
    	from   cr_items
    	where  item_id in (select item_id
                       	   from   cr_items
                       	   connect by prior item_id = parent_id
                           start with item_id = :item_id)
    	and    acs_permission.permission_p(item_id,:user_id,:privilege) = 'f'

      </querytext>
</fullquery>

 
<fullquery name="children_have_permission_p.child_items">      
      <querytext>
      
	select item_id as child_item_id
	from   cr_items
	connect by prior item_id = parent_id
	start with item_id = :item_id
    
      </querytext>
</fullquery>

 
<fullquery name="children_have_permission_p.revision_perms">      
      <querytext>
      
	select count(*)
	from   cr_revisions
	where  item_id = :child_item_id
	and    acs_permission.permission_p(revision_id,:user_id,:privilege) = 'f'

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
	            then 'index?folder_id=' 
	            else 'file?file_id=' 
	       end || i.item_id,
               file_storage.get_title(i.item_id)
    	from   cr_items i
    	where  item_id not in (
        		       	select i2.item_id
        			from   cr_items i2
        			connect by prior i2.parent_id = i2.item_id
        			start with i2.item_id = 
				    file_storage.get_root_folder([ad_conn package_id]))
    	connect by prior i.parent_id = i.item_id
    	start with item_id = :start_id
    	order by level desc

      </querytext>
</fullquery>
 
</queryset>
