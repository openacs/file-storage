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

    db_exec_plsql version_delete "
    begin


        if :version_id = content_item.get_live_revision(:item_id) then
            content_revision.delete (:version_id);
            content_item.set_live_revision(content_item.get_latest_revision(:item_id));
        else
            content_revision.delete (:version_id);
        end if;

    end;"

    # JS:
    # If the version is the last revision available, we also need to remove the
    # item from cr_items! How come CR does not take care of this? (Note: CR merely 
    # sets live_revision in cr_items to null).  The redirect should be to the parent 
    # folder if there are no more revisions, so we need to get the parent folder before we
    # actually remove the entry in cr_items (I guess this is the reason why CR does not
    # actually delete the item even if there are no more revisions for it).
    if [db_string deleted_last_revision "
           select (case when live_revision = null
                        then 1
                        else 0
                   end) 
           from cr_items
           where item_id = :item_id"] {

	       # Get the parent if we will be deleting the item
	       set parent_id [db_string parent_folder "
	                       select parent_id from cr_items where item_id = :item_id"]

	       # Actually delete
	       db_exec_plsql delete_item "
	               begin
	                      content_item.delete(:item_id);
	               end;"

	       # Redirect to the folder, instead of the latest revision (which does not exist anymore)
	       ad_returnredirect "?folder_id=$parent_id"

   } else {

	       # Ok, we don't have to do anything fancy, just redirect to th last revision
	       ad_returnredirect "file?file_id=$item_id"
   }

} else {
    # they still need to confirm

    set version_name [db_string version_name "
    select title from cr_revisions where revision_id = :version_id"]

    set context_bar [fs_context_bar_list -final "Delete Version" $item_id]
    ad_return_template
}
