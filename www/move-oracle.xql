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
  
  <fullquery name="get_move_objects">
    <querytext>
      select fs.object_id, fs.name,
      acs_permission.permission_p(fs.object_id, :user_id, 'write') as move_p
      from fs_objects fs
      where fs.object_id in ([template::util::tcl_to_sql_list $object_id])
	order by move_p
    </querytext>
  </fullquery>

  <fullquery name="move_item">
    <querytext>
      select content_item.move(
           :one_item,
           :folder_id
      )
    </querytext>
  </fullquery>

  <fullquery name="get_folder_tree">
    <querytext>
      select
      cf.folder_id, cf.label, ci1.level
      from cr_folders cf, (select item_id, level from
                           cr_items
                           connect by prior item_id=parent_id
                           start with :root_folder_id
                          ) ci1
      where
      ci1.item_id=cf.folder_id
      and exists (select 1
                   from acs_object_party_privilege_map m
                   where m.object_id = cf.folder_id
                     and m.party_id = :user_id
                     and m.privilege = 'write')
      order by order by ci1.level, cf.label
    </querytext>
  </fullquery>

</queryset>