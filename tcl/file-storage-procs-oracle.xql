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

    <fullquery name="fs::rename_folder.rename_folder">
        <querytext>
            begin
                content_folder.rename(
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
                   fs_objects.live_revision,
                   fs_objects.type,
                   to_char(fs_objects.last_modified, 'Month DD YYYY HH24:MI') as last_modified,
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
                        then :folder_url || '?' || :extra_vars || '&folder_id='
                        else :file_url || '?' || :extra_vars || '&file_id='
                   end || i.item_id,
                   file_storage.get_title(i.item_id)
            from cr_items i
            where item_id not in (select i2.item_id
                                  from cr_items i2
                                  connect by prior i2.parent_id = i2.item_id
                                  start with i2.item_id = file_storage.get_parent_id(:root_folder_id))
            connect by prior i.parent_id = i.item_id
            start with item_id = :start_id
            order by level desc
        </querytext>
    </fullquery>

</queryset>
