ad_page_contract {
    Script to rename a folder.

    @author Andrew Grumet (aegrumet@alum.mit.edu)
    @creation-date 24 Jun 2002
    @cvs-id $Id$
} {
    folder_id:integer,notnull
    folder_name:trim,notnull
} -validate {
    valid_folder -requires {folder_id:integer} {
	if ![fs_folder_p $folder_id] {
	    ad_complain "[_ file-storage.lt_The_specified_folder_]"
	}
    }
}

set user_id [ad_conn user_id]

ad_require_permission $folder_id admin

# get their IP

set creation_ip [ad_conn peeraddr]

# strip out spaces from the name

#We can't rename the item because this breaks the syllabus
#portlet.  aegrumet/2002-08-28
#regsub -all { +} [string tolower $folder_name] {_} name

db_exec_plsql folder_rename {}

ad_returnredirect "?folder_id=$folder_id"
