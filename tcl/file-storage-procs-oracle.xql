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
            select fs_folders_and_files.file_id,
                   fs_folders_and_files.name,
                   fs_folders_and_files.live_revision,
                   fs_folders_and_files.type,
                   to_char(fs_folders_and_files.last_modified, 'YYYY-MM-DD HH24:MI') as last_modified,
                   case when fs_folders_and_files.last_modified >= (sysdate - :n_past_days) then 1 else 0 end as new_p,
                   fs_folders_and_files.content_size,
                   decode(acs_permission.permission_p(fs_folders_and_files.file_id, :user_id, 'write'), 'f', 0, 1) as write_p,
                   decode(acs_permission.permission_p(fs_folders_and_files.file_id, :user_id, 'delete'), 'f', 0, 1) as delete_p,
                   decode(acs_permission.permission_p(fs_folders_and_files.file_id, :user_id, 'admin'), 'f', 0, 1) as admin_p
            from fs_folders_and_files
            where fs_folders_and_files.parent_id = :folder_id
            and 't' = acs_permission.permission_p(fs_folders_and_files.file_id, :user_id, 'read')
            order by fs_folders_and_files.sort_key,
                     fs_folders_and_files.name
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
