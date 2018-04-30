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
set context [_ file-storage.Search]

# Bash the query to lowercase

set query [string tolower $query]
set orig_query $query

# In case they used wildcards, replace * with %

regsub -all {\*} $query {%} query
set query "%${query}%"
regsub -all {%+} $query {%} query

db_multirow results get_ids_and_titles {}

# get the (lowercased) original back to feed to the template

set query $orig_query

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
