ad_page_contract {
    page to display search results

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 14 Nov 2000
    @cvs-id $Id$
} {
    query:trim,notnull
} -properties {
    results:multirow
    query:onevalue
    context:onevalue
}

set user_id [ad_conn user_id]
set context "Search"

# Bash the query to lowercase

set query [string tolower $query]
set orig_query $query

# In case they used wildcards, replace * with %

regsub -all {\*} $query {%} query
set query "%${query}%"
regsub -all {%+} $query {%} query

db_multirow results results {
    select item_id as file_id,
           content_item.get_title(item_id) as title
    from   cr_items
    where  lower(content_item.get_title(item_id)) like :query
    and    acs_permission.permission_p(item_id,:user_id,'read') = 't'
}

# get the (lowercased) original back to feed to the template

set query $orig_query

ad_return_template