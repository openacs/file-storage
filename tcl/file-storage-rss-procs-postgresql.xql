<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <partialquery name="fs::rss::datasource.descend_parent_clause">
    <querytext>
    parent_id in (select children.item_id
                  from cr_items parent,
                       cr_items children
                  where parent.item_id = :folder_id
                    and children.content_type = 'content_folder'
                    and children.tree_sortkey
                      between parent.tree_sortkey
                      and tree_right(parent.tree_sortkey)) 
    </querytext>
  </partialquery>

</queryset>
