ad_page_contract {
    display information about a file in the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 7 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
    {show_all_versions_p "f"}
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
	    ad_complain "The specified file is not valid."
	}
    }
} -properties {
    title:onevalue
    name:onevalue
    owner:onevalue
    version:multirow
    show_all_versions_p:onevalue
    context_bar:onevalue
    file_path:onevalue
}

# check they have read permission on this file

ad_require_permission $file_id read

#set templating datasources

set user_id [ad_conn user_id]
set context_bar [fs_context_bar_list $file_id]

db_1row file_info "
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
and    r.revision_id = i.live_revision"

# We use the new db_map here
if {[string equal $show_all_versions_p "t"]} {
#    append sql "
#and r.item_id = :file_id"
    set show_versions [db_map show_all_versions]
} else {
#    append sql "
#and r.revision_id = (select live_revision from cr_items where item_id = :file_id)"
    set show_versions [db_map show_live_version]
}

set sql "
select r.title,
       r.revision_id as version_id,
       person.name(o.creation_user) as author,
       r.mime_type as type,
       to_char(o.last_modified,'YYYY-MM-DD HH24:MI') as last_modified,
       r.description,
       acs_permission.permission_p(r.revision_id,:user_id,'admin') as admin_p,
       acs_permission.permission_p(r.revision_id,:user_id,'delete') as delete_p,
       r.content_length as content_size
from   acs_objects o, cr_revisions r
where  o.object_id = r.revision_id
and    acs_permission.permission_p(r.revision_id, :user_id, 'read') = 't'
$show_versions"

db_multirow version version_info $sql

ad_return_template