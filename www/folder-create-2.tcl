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
	    ad_complain "[_ file-storage.lt_The_specified_parent_]"
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

    ad_return_complaint 1 [_ file-storage.lt_Either_there_is_alrea] [list folder_name $folder_name directory_url "index?folder_id=$parent_id"]]
    
     ad_script_abort
}


ad_returnredirect "?folder_id=$folder_id"
