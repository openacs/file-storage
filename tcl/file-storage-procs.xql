<?xml version="1.0"?>
<queryset>

<fullquery name="fs_folder_p.object_type">      
      <querytext>

       	select object_type 
       	from   acs_objects
       	where  object_id = :folder_id

      </querytext>
</fullquery>

<fullquery name="fs_context_bar_list.parent_id">      
      <querytext>

	select parent_id from cr_items where item_id = :item_id

      </querytext>
</fullquery>

<fullquery name="fs_maybe_create_new_mime_type.mime_type_exists">      
      <querytext>

	select count(*) from cr_mime_types
    	where  mime_type = :mime_type

      </querytext>
</fullquery>

 
<fullquery name="fs_maybe_create_new_mime_type.new_mime_type">      
      <querytext>

	insert into cr_mime_types
	(mime_type, file_extension)
	values
	(:mime_type, :extension)

      </querytext>
</fullquery>

    <fullquery name="fs::get_folder.get_folder">
        <querytext>
            select item_id
            from cr_items
            where parent_id = :parent_id
            and name = :name
        </querytext>
    </fullquery>

    <fullquery name="fs::get_folder_contents_count.get_folder_contents_count">
        <querytext>
            select (select count(*)
                    from cr_items
                    where cr_items.parent_id = :folder_id)
                   +
                   (select count(*)
                    from fs_simple_objects
                    where fs_simple_objects.folder_id = :folder_id)
            from dual
        </querytext>
    </fullquery>

</queryset>
