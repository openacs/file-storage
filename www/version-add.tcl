ad_page_contract {
    page to add a new version of a file

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 8 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
	    ad_complain "The specified file is not valid."
	}
    }
} -properties {
    file_id:onevalue
    name:onevalue
    context_bar:onevalue
}

# check for write permission on the file

ad_require_permission $file_id write

# set templating datasources

db_1row file_name "
select title as name
from   cr_revisions
where  revision_id = (select live_revision
                      from   cr_items
                      where  item_id = :file_id)"

set context_bar [fs_context_bar_list -final "Upload New Version" $file_id]

ad_return_template
