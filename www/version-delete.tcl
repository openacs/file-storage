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
	    ad_complain "The specified version is not valid."
	}
    }
} -properties {
    version_id:onevalue
    version_name:onevalue
    title:onevalue
    context_bar:onevalue
}

# check for delete permission on the version

ad_require_permission $version_id delete

db_1row item_select "
select item_id
from   cr_revisions
where  revision_id = :version_id"

if {[string equal $confirmed_p "t"]} {
    # they have confirmed that they want to delete the version

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

	 # Redirect to the folder, instead of the latest revision (which does not exist anymore)
	 ad_returnredirect "index?folder_id=$parent_id"

    } else {

	 # Ok, we don't have to do anything fancy, just redirect to th last revision
	 ad_returnredirect "file?file_id=$item_id"

    }

} else {
    # they still need to confirm

    db_1row version_name "
    select i.name as title,r.title as version_name 
    from cr_items i,cr_revisions r
    where i.item_id = r.item_id
    and revision_id = :version_id"

    set context_bar [fs_context_bar_list -final "Delete Version" $item_id]
    ad_return_template
}
