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

    <fullquery name="fs_maybe_create_new_mime_type.select_mime_type">      
        <querytext>
	        select mime_type
            from cr_mime_types
        	where file_extension = :file_extension
        </querytext>
    </fullquery>

    <fullquery name="fs_maybe_create_new_mime_type.insert_mime_type">      
        <querytext>
            insert into cr_mime_types
            (mime_type, file_extension)
            values
            (:mime_type, :extension)
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

    <fullquery name="fs::get_folder_objects.select_folder_contents">
        <querytext>

           select *
           from (select cr_items.item_id as object_id,
                   cr_items.name
                 from cr_items
                 where cr_items.parent_id = :folder_id
                 union all
                 select fs_simple_objects.object_id,
                   fs_simple_objects.name
                 from fs_simple_objects
                 where fs_simple_objects.folder_id = :folder_id) contents
           where exists (select 1
                         from acs_object_party_privilege_map m
                         where m.object_id = contents.object_id
                           and m.party_id = :user_id
                           and m.privilege = 'read')

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

    <fullquery name="fs::publish_simple_object_to_file_system.select_object_info">
        <querytext>
            select fs_objects.*
            from fs_objects
            where fs_objects.object_id = :object_id
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

</queryset>
