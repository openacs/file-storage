ad_page_contract {
    Add a nonversioned item

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    folder_id:integer,notnull
    title:notnull,trim
    description
    url:notnull,trim
} -validate {
    valid_folder -requires {folder_id:integer} {
	if {![fs_folder_p $folder_id]} {
	    ad_complain "[_ file-storage.lt_The_specified_parent_]"
	}
    }

} 

set user_id [ad_conn user_id]

# Check for write permission on this folder
permission::require_permission -object_id $folder_id -privilege write

set item_id [content::extlink::new -url $url -label $title -description $description -parent_id $folder_id]

# Analogous as for files (see file-add-2) we know the user has write permission to this folder, 
# but they may not have admin privileges.
# They should always be able to admin their own url (item) by default, so they can delete it, control
# who can read it, etc.

if { [string is false [permission::permission_p -party_id $user_id -object_id $folder_id -privilege admin]] } {
    permission::grant -party_id $user_id -object_id $item_id -privilege admin
}

fs::do_notifications -folder_id $folder_id -filename $url -item_id $item_id -action "new_url"

ad_returnredirect "?folder_id=$folder_id"

