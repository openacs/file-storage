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
    title:onevalue
    context:onevalue
}

# check for write permission on the file

ad_require_permission $file_id write

# set templating datasources

db_1row file_title ""

set context [fs_context_bar_list -final "Upload New Version" $file_id]

ad_return_template
