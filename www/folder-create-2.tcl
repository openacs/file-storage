ad_page_contract {
    script to create the new folder

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 7 Nov 2000
    @cvs-id $Id$
} {
    parent_id:integer,notnull
    folder_name:trim,notnull
} -validate {
    valid_folder -requires {parent_id:integer} {
	if ![fs_folder_p $parent_id] {
	    ad_complain "The specified parent folder is not valid."
	}
    }
}

set user_id [ad_conn user_id]

#check for write permission on the parent folder

ad_require_permission $parent_id write

# get their IP

set creation_ip [ad_conn peeraddr]

# strip out spaces from the name

regsub -all { +} [string tolower $folder_name] {_} name

db_transaction {

# create the folder

set folder_id [db_exec_plsql folder_create "
begin
    :1 := file_storage.new_folder (
        name => :name,
        label => :folder_name,
        parent_id => :parent_id,
        creation_user => :user_id,
        creation_ip => :creation_ip
    );
end;"]

} on_error {

    # most likely a duplicate name or a double click

    #if [db_string duplicate_check "
    #select count(*)
    #from   cr_items
    #where  name = :name
    #and    parent_id = :parent_id"] {
	ad_return_complaint 1 "Either there is already a folder with the name \"$folder_name\" or you clicked on the button more than once.  You can use the Back button to return and choose a new name, or <a href=\"index?folder_id=$parent_id\">return to the directory listing</a> to see if your folder is there."
    #} else {
#	ad_return_complaint 1 "We got an error that we couldn't readily identify.  Please let the system owner know about this.
#
#	<pre>$errmsg</pre>"
#    }
    
    return
}


ad_returnredirect "?folder_id=$folder_id"


