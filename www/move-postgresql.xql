<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">

<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2004-05-09 -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>postgresql</type>
    <version>7.2</version>
  </rdbms>

  <fullquery name="get_folder_tree">
    <querytext>
      select
         cf.folder_id, ci1.parent_id, cf.label, tree_level(ci1.tree_sortkey) as level_num
         from cr_folders cf, cr_items ci1, cr_items ci2
      where
         ci1.tree_sortkey between ci2.tree_sortkey and  tree_right(ci2.tree_sortkey)
         and ci2.item_id=:root_folder_id
         and ci1.item_id=cf.folder_id
         and acs_permission__permission_p(cf.folder_id, :user_id, 'write')

      order by ci1.tree_sortkey, cf.label
    </querytext>
  </fullquery>

  <fullquery name="dbqd.file-storage.www.move.get_folder_tree">
    <rdbms><type>postgresql</type><version>8.4</version></rdbms>
    <querytext>
    With folder_tree as (
        select
        cf.folder_id, ci1.parent_id, cf.label, tree_level(ci1.tree_sortkey) as level_num, acs_permission__permission_p(cf.folder_id, :user_id, 'write') as permission_p
        from cr_folders cf, cr_items ci1, cr_items ci2
        where
        ci1.tree_sortkey between ci2.tree_sortkey and
        tree_right(ci2.tree_sortkey)
        and ci2.item_id= :root_folder_id
        and ci1.item_id=cf.folder_id
        order by ci1.tree_sortkey, cf.label
    ) select folder_id, parent_id, label, level_num from folder_tree where permission_p is true;
    </querytext>
  </fullquery>

</queryset>
