ad_page_contract {
    page to select a new folder to copy a file to

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 14 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
	    ad_complain "[_ file-storage.lt_The_specified_file_is]"
	}
    }
} -properties {
    file_id:onevalue
    file_name:onevalue
    context:onevalue
}

# check for read permission on the file

ad_require_permission $file_id read

# set templating datasources

set file_name [db_string file_name "
select name as title
from   cr_items
where  item_id = :file_id"]

set context [fs_context_bar_list -final "[_ file-storage.Copy]" $file_id]

ad_return_template
