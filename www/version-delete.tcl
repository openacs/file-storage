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

    ad_returnredirect "file?file_id=$item_id"

} else {
    # they still need to confirm

    set version_name [db_string version_name "
    select title from cr_revisions where revision_id = :version_id"]

    set context_bar [fs_context_bar_list -final "Delete Version" $item_id]
    ad_return_template
}
