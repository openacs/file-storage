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
	if ![fs_folder_p $folder_id] {
	    ad_complain "The specified parent folder is not valid."
	}
    }

} 

# Check for write permission on this folder
ad_require_permission $folder_id write

# Create the URL (for now)
set url_id [fs::url_new -url $url -name $title -description $description -folder_id $folder_id]

ad_returnredirect "?folder_id=$folder_id"
