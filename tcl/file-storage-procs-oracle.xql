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

    <fullquery name="fs_get_folder_name.folder_name">
        <querytext>
            begin
                :1 := file_storage.get_folder_name(:folder_id);
            end;
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
                   end || i.item_id || :extra_vars,  
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
	select file_storage.delete_folder(:folder_id, :cascade_p ) from dual
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

</queryset>
