<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <partialquery name="fs::rss::datasource.descend_parent_clause">
    <querytext>
	parent_id in (select item_id from cr_items
                      where content_type = 'content_folder'
                      connect by prior item_id = parent_id
                      start with item_id = :folder_id)
    </querytext>
  </partialquery>

</queryset>
