<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="file_storage_folders">
    <querytext>
      select fs.folder_id,
             fs.package_id,
             content_item.get_path(fs.folder_id,-100) as url,
             cf.label, 
             case when d.node_id is not null then 1 else 0 end as
             dav_enabled_p
      from fs_root_folders fs, dav_site_node_folder_map d,
             cr_folders cf
      where fs.folder_id=cf.folder_id
        and d.folder_id(+) = fs.folder_id
    </querytext>
  </fullquery>

</queryset>

