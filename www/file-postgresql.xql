<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_folder">      
      <querytext>
	select content_item__get_parent_folder(:file_id)
      </querytext>
</fullquery>

<fullquery name="file_info">      
      <querytext>
      
	select person__name(o.creation_user) as owner,
       		f.name as title,
       		coalesce(f.url,f.file_upload_name) as name,
       		acs_permission__permission_p(:file_id,:user_id,'write') as write_p,
       		acs_permission__permission_p(:file_id,:user_id,'delete') as delete_p,
       		acs_permission__permission_p(:file_id,:user_id,'admin') as admin_p,
                content_item__get_path(o.object_id, :root_folder_id) as file_url, f.live_revision
	from   acs_objects o, fs_objects f
	where  o.object_id = :file_id
	and    f.object_id = o.object_id
      </querytext>
</fullquery>

<fullquery name="version_info">      
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
          and exists (select 1
                      from acs_object_party_privilege_map m
                      where m.object_id = r.revision_id
                        and m.party_id = :user_id
                        and m.privilege = 'read')
	$show_versions order by last_modified desc

      </querytext>
</fullquery> 

<partialquery name="show_all_versions">      
      <querytext>

      </querytext>
</partialquery> 	

<partialquery name="show_live_version">      
      <querytext>

	and r.revision_id = i.live_revision

      </querytext>
</partialquery> 	

</queryset>


