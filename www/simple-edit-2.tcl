ad_page_contract {
    Edit a nonversioned item

    @author Ben Adida
    @creation-date 01 April 2002
    @cvs-id $Id$
} {
    object_id:notnull
    url
    name
    description
} 

# Check for write permission on this folder
ad_require_permission $object_id write

# edit the URL
fs::url_edit -url_id $object_id -name $name -description $description -url $url

set folder_id [db_string select_folder_id "select folder_id from fs_simple_objects where object_id= :object_id"]

ad_returnredirect "?folder_id=$folder_id"
