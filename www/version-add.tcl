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
	    ad_complain "[_ file-storage.lt_The_specified_file_is]"
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

db_1row file_name "
select title 
from   cr_revisions
where  revision_id = (select live_revision
                      from   cr_items
                      where  item_id = :file_id)"

set context [fs_context_bar_list -final "[_ file-storage.Upload_New_Version]" $file_id]

# Message lookup uses variable title
set page_title [_ file-storage.version_add_page_title]

set upload_file_help [_ file-storage.lt_Use_the_Browse_button]
set submit_label [_ file-storage.Update]
ad_form -html { enctype multipart/form-data } -export { file_id title } -action version-add-2 -form {
    {upload_file:file {label \#file-storage.Version_filename_1\#} {help_text $upload_file_help}}
    {description:text(textarea),optional {html {rows 5 cols 50}} {label \#file-storage.Version_Notes_1\#}}
    {submit:text(submit) {label $submit_label}}
} -has_submit 1

ad_return_template
