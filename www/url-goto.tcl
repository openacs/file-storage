ad_page_contract {
    go to a URL

    @author Ben Adida (ben@openforce.net)
    @creation-date 01 April 2002
    @cvs-id $Id$
} {
    url_id:notnull
} 

# Check for write permission on this folder
ad_require_permission $url_id read

# Check the URL
set url [db_string select_url "select url from fs_urls where url_id= :url_id" -default ""]

if {![empty_string_p $url]} {
    ad_returnredirect $url
} else {
    return -code error "no such URL"
}
