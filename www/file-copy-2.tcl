ad_page_contract {
    script to copy a file into a new folder

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 14 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
    parent_id:integer,notnull
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
	    ad_complain "The specified file is not valid."
	}
    }

    valid_folder -requires {parent_id} {
	if ![fs_folder_p $parent_id] {
	    ad_complain "The specified parent folder is not valid."
	}
    }
}

# check for read permission on the file and write permission on the
# target folder

ad_require_permission $file_id read
ad_require_permission $parent_id write

set user_id [ad_conn user_id]
set ip_address [ad_conn peeraddr]

# Question - do we copy revisions or not?
# Current Answer - we copy the live revision only

db_transaction {

    db_1row item_info " 
    select name, content_type from cr_items where item_id = :file_id"

    # I'd like to use content_item.copy but the current version (4.0.1)
    # doesn't return the new item_id.  This would be okay except that
    # content_revision.copy doesn't set the context_id properly
    # and we will have no way to fix it.  Also, the live revision
    # doesn't get set.

    # Post-4.0.1 revisions to the content repository add the function
    # copy2 which does return the item_id, so ultimately a call to
    # that function will replace all this.

    set new_file_id [db_exec_plsql file_copy "
    begin
        :1 := content_item.new (
            parent_id => :parent_id,
            context_id => :parent_id,
            name => :name,
            content_type => :content_type,
            creation_user => :user_id,
            creation_ip => :ip_address,
            item_subtype => 'file_storage_item' -- needed by site-wide search
        );
    end;"]

    # We could use content_revision.copy, but we would have to 
    # fix up the context_id by hand, so we'll just keep this
    # for the time being.
    set new_version_id [db_exec_plsql revision_copy "
    begin
        select acs_object_id_seq.nextval into :1 from dual;

        insert into acs_objects 
        (object_id, object_type, context_id, security_inherit_p,
         creation_user, creation_ip, last_modified, modifying_user, 
         modifying_ip)
        (select
         :1, object_type, :new_file_id, security_inherit_p,
         creation_user, creation_ip, last_modified, modifying_user,
         modifying_ip
         from acs_objects 
         where object_id = content_item.get_live_revision(:file_id));

        insert into cr_revisions 
        (revision_id, title, description, publish_date, mime_type,
         nls_language, content, item_id)
        (select
         :1, title, description, publish_date, mime_type,
         nls_language, content, :new_file_id
         from cr_revisions
         where revision_id = content_item.get_live_revision(:file_id));

         content_item.set_live_revision(:1);

    end;"] 

} on_error {
    ad_return_complaint 1 "We received an error from the database.  Probably
    the folder you selected already contains a file with the same name.

    <pre>$errmsg</pre>"

    return
}

ad_returnredirect "?folder_id=$parent_id"
