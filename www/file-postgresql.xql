<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="dbqd.file-storage.www.file.version_info">
    <rdbms><type>postgresql</type><version>8.4</version></rdbms>
    <querytext>

    select  r.title,
            r.revision_id as version_id,
            person__name(o.creation_user) as author,
                o.creation_user as author_id,
            r.mime_type as type,
            m.label as pretty_type,
                to_char(o.last_modified,'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,
            r.description,
            acs_permission__permission_p(r.revision_id,:user_id,'admin') as admin_p,
            acs_permission__permission_p(r.revision_id,:user_id,'delete') as delete_p,
            coalesce(r.content_length,0) as content_size
    from   acs_objects o, cr_items i,cr_revisions r
            left join cr_mime_types m on r.mime_type=m.mime_type
    where o.object_id = r.revision_id
      and r.item_id = i.item_id
      and r.item_id = :file_id
          and acs_permission__permission_p(r.revision_id, :user_id, 'read')
    $show_versions order by last_modified desc

    </querytext>
</fullquery>

</queryset>


