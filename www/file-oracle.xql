<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="file_info">      
      <querytext>
      
	select person.name(o.creation_user) as owner,
       		i.name,
       		r.title,
       		content_item.get_path(i.item_id,file_storage.get_root_folder([ad_conn package_id])) as file_path,
       		acs_permission.permission_p(:file_id,:user_id,'write') as write_p,
       		acs_permission.permission_p(:file_id,:user_id,'delete') as delete_p,
       		acs_permission.permission_p(:file_id,:user_id,'admin') as admin_p
	from   acs_objects o, cr_revisions r, cr_items i
	where  o.object_id = :file_id
	and    i.item_id   = o.object_id
	and    r.revision_id = i.live_revision
      </querytext>
</fullquery>

 
</queryset>
