ad_page_contract {
    Front page for file-storage.  Lists subfolders and file in the 
    folder specified (top level if none is specified).

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    {folder_id:integer [fs_get_root_folder]}
} -validate {
    valid_folder -requires {folder_id:integer} {
	if ![fs_folder_p $folder_id] {
	    ad_complain "The specified folder is not valid."
	}
    }
} -properties {
    folder_name:onevalue
    folder_id:onevalue
    file:multirow
    write_p:onevalue
    admin_p:onevalue
    delete_p:onevalue
    context_bar:onevalue
}

# check the user has permission to read this folder
ad_require_permission $folder_id read

# set templating datasources
set folder_name [fs_get_folder_name $folder_id]
set context_bar [fs_context_bar_list $folder_id]

set user_id [ad_conn user_id]
set write_p [ad_permission_p $folder_id write]
set admin_p [ad_permission_p $folder_id admin]

# might want a more complicated check here, since a person might have
# delete permission on the folder, but not on some child items and,
# thus, not be able to actually delete it.  We check this later, but
# sometime present a link that they won't be able to use.

set delete_p [ad_permission_p $folder_id delete]

set package_id [ad_conn package_id]
db_multirow file file_select "
select i.item_id as file_id,
       r.title as name,
       i.live_revision,
       content_item.get_path(i.item_id,file_storage.get_root_folder(:package_id)) as path,
       r.mime_type as type,
       to_char(o.last_modified,'YYYY-MM-DD HH24:MI') as last_modified,
       r.content_length as content_size,
       1 as ordering_key
from   cr_items i, cr_revisions r, acs_objects o
where  i.item_id       = o.object_id
and    i.live_revision = r.revision_id (+)
and    i.parent_id     = :folder_id
and    acs_permission.permission_p(i.item_id, :user_id, 'read') = 't'
and    i.content_type = 'content_revision'
UNION
select i.item_id as file_id,
       f.label as name,
       0,
       content_item.get_path(f.folder_id) as path,
       'Folder',
       NULL,
       0,
       0
from   cr_items i, cr_folders f
where  i.item_id   = f.folder_id
and    i.parent_id = :folder_id
and    acs_permission.permission_p(folder_id, :user_id, 'read') = 't'
order by ordering_key,name"

ad_return_template
