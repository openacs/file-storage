ad_page_contract {
    go to a URL

    @author Ben Adida (ben@openforce.net)
    @creation-date 01 April 2002
    @cvs-id $Id$
} {
    url_id:notnull
} 

# Check for read permission on this url
ad_require_permission $url_id read

if { ![db_0or1row select_url {}] } {
    return -code error "no such URL"
}

ad_returnredirect $url
