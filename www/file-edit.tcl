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
    context:onevalue
    title:onevalue
}


#check they have write permission on this file

ad_require_permission $file_id write

ad_form -form {
    key:item_id
    {title:text {label "Title"} {html {size 40}}}
    {description:text(textarea) {label "Description"} {html {rows 10 cols 50}} }
} -select_query_name {file_info} -edit_data {

}

}
db_1row file_info "
select name as title
from   cr_items
where  item_id = :file_id"

set context [fs_context_bar_list -final "Rename" $file_id]

ad_return_template
