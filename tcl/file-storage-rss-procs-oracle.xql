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
  </fullquery>

  <fullquery name="fs::rss::datasource.select_files">
    <querytext>
        select * from (
          select o.object_id as item_id,
                 o.title,
                 o.name,
                 o.file_upload_name,
                 o.type,
                 o.content_size,
                 to_char(o.last_modified,'YYYY-MM-DD HH24:MI:SS') as publish_date_ansi,
                 r.description,
                 r.revision_id
          from fs_objects o,
               cr_revisions r
          where $parent_clause
            and type != 'folder'
            and $revisions_clause
          order by last_modified desc
        ) where rownum < :max_items + 1
    </querytext>
  </fullquery>

  <fullquery name="fs::rss::lastUpdated.select_last_updated">
    <querytext>
	select (max(last_modified)-to_date('1970-01-01','YYYY-MM-DD'))*60*60*24 as last_update
        from fs_rss_subscrs s, fs_objects f
        where s.subscr_id = :summary_context_id
          and f.parent_id = s.folder_id
          and f.type != 'folder'
    </querytext>
  </fullquery>

</queryset>
