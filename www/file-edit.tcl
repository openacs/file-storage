ad_page_contract {
    Page to specify a new name for a file

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 5 Dec 2000
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
    title:onevalue
}


#check they have write permission on this file

ad_require_permission $file_id write

db_1row file_info "
select content_item.get_title(:file_id) as title,
       name
from   cr_items
where  item_id = :file_id"

set context_bar [fs_context_bar_list -final "Rename" $file_id]

ad_return_template
