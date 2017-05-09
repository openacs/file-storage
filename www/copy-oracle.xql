<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">

<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2004-05-09 -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>
  
  <fullquery name="get_copy_objects">
    <querytext>
      select fs.object_id, fs.name, fs.title, fs.parent_id,
      acs_permission.permission_p(fs.object_id, :user_id, 'read') as copy_p, fs.type
      from fs_objects fs
      where fs.object_id in ([template::util::tcl_to_sql_list $object_id])
	order by copy_p
    </querytext>
  </fullquery>

  <fullquery name="copy_item">
    <querytext>
	begin	      	
	:1 := file_storage.copy_file(
           :object_id,
           :folder_id,
	   :user_id,
           :peer_addr,
	   :name,
	   :title);
	end;
    </querytext>
  </fullquery>

  <fullquery name="copy_folder">
    <querytext>
        begin 
         :1 = content_folder.copy (
           :object_id,
           :folder_id,
	   :user_id,
           :peer_addr,
	   :name,
	   :title);
        end;
    </querytext>
  </fullquery>

  <fullquery name="get_folder_tree">
    <querytext>
      select
      cf.folder_id, ci1.parent_id, cf.label, ci1.level_num
      from cr_folders cf, (select item_id, level as level_num from
                           cr_items
			   where cr_items.item_id not in ($object_id_list)	
			   connect by (prior item_id=parent_id and parent_id not in ($object_id_list))
                           start with cr_items.item_id = :root_folder_id
                          ) ci1
      where
      ci1.item_id=cf.folder_id
      and exists (select 1
                   from acs_object_party_privilege_map m
                   where m.object_id = cf.folder_id
                     and m.party_id = :user_id
                     and m.privilege = 'write')
      order by ci1.level_num, cf.label
    </querytext>
  </fullquery>

</queryset>
