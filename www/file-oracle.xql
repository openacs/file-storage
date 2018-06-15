<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="version_info">      
      <querytext>

	select  r.title,
       		r.revision_id as version_id,
       		person.name(o.creation_user) as author,
                o.creation_user as author_id,
       		r.mime_type as type,
       		m.label as pretty_type,
		i.name,
                to_char(o.last_modified,'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,
       		r.description,
       		acs_permission.permission_p(r.revision_id,:user_id,'admin') as admin_p,
       		acs_permission.permission_p(r.revision_id,:user_id,'delete') as delete_p,
       		nvl(r.content_length,0) as content_size
	from   acs_objects o, cr_revisions r, cr_items i,
       		cr_mime_types m
	where o.object_id = r.revision_id
	  and r.item_id = i.item_id
	  and r.item_id = :file_id
          and r.mime_type = m.mime_type(+)
          and exists (select 1
                      from acs_object_party_privilege_map m
                      where m.object_id = r.revision_id
                        and m.party_id = :user_id
                        and m.privilege = 'read')
	$show_versions order by last_modified desc

      </querytext>
</fullquery> 

</queryset>
