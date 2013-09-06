ad_page_contract {
    confirmation page for version deletion

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 10 November 2000
    @cvs-id $Id$
} {
    version_id:integer,notnull
    {confirmed_p "f"}
} -validate {
    valid_version -requires {version_id} {
	if ![fs_version_p $version_id] {
	    ad_complain [_ file-storage.lt_version_not_valid]
	}
    }
} -properties {
    version_id:onevalue
    version_name:onevalue
    title:onevalue
    context:onevalue
}

# check for delete permission on the version

permission::require_permission -object_id $version_id -privilege delete

db_1row item_select "
select item_id
from   cr_revisions
where  revision_id = :version_id"

db_1row version_name "
    select i.name as title,r.title as version_name 
    from cr_items i,cr_revisions r
    where i.item_id = r.item_id
    and revision_id = :version_id"

set context [fs_context_bar_list -final [_ file-storage.Delete_Version] $item_id]

set delete_message [_ file-storage.lt_Are_you_sure_that_you]
ad_form -export version_id -cancel_url "file?[export_vars {{file_id $item_id}}]" -form {
    {delete_message:text(inform) {label $delete_message}}
} -on_submit {

    set parent_id [db_exec_plsql delete_version "
         begin

             :1 := file_storage.delete_version(:item_id,:version_id);

         end;"]

    if {$parent_id > 0} {

	 # Delete the item if there is no more revision. We do this here only because of PostgreSQL's RI bug
	 db_exec_plsql delete_file "
	          begin
	                   file_storage.delete_file(:item_id);
	          end;"

 	 fs::do_notifications -folder_id $parent_id -filename $version_name -item_id $item_id -action "delete_file"

	 # Redirect to the folder, instead of the latest revision (which does not exist anymore)
	 ad_returnredirect "index?folder_id=$parent_id"
         ad_script_abort

    } else {

	 # Ok, we don't have to do anything fancy, just redirect to th last revision
	 ad_returnredirect "file?file_id=$item_id"
         
         ad_script_abort
    }

}

# Message lookup uses variable version_name
set page_title [_ file-storage.version_delete_page_title]
