ad_page_contract {
    page to add a new file to the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,optional,notnull
    folder_id:integer,optional,notnull
    upload_file:trim,optional
    upload_file.tmpfile:tmpfile,optional
    {title ""}
    {lock_title_p 0}
} -properties {
    folder_id:onevalue
    context:onevalue
    title:onevalue
    lock_title_p:onevalue
} -validate {
    file_id_or_folder_id {
	if {[exists_and_not_null file_id]} {
	    set folder_id [db_string get_folder_id "" -default ""]
	} else {
	    set folder_id ""
	}
	if {![fs_folder_p $folder_id]} {
	    ad_complain "The specified parent folder is not valid."
	}
    }
    max_size -requires {upload_file} {
	set n_bytes [file size ${upload_file.tmpfile}]
	set max_bytes [ad_parameter "MaximumFileSize"]
	if { $n_bytes > $max_bytes } {
	    ad_complain "Your file is larger than the maximum file size allowed on this system ([util_commify_number $max_bytes] bytes)"
	}
    }
}

set user_id [ad_conn user_id]

# check for write permission on the folder

ad_require_permission $folder_id write

# set templating datasources

set context [fs_context_bar_list -final "Add File" $folder_id]

# if title isn't passed in ignore lock_title_p
if {[empty_string_p $title]} {
    set lock_title_p 0
}

ad_form -html { enctype multipart/form-data } -export { folder_id } -form {
    file_id:key
    {upload_file:file {label "Upload File"} {html "size 30"}}
    {title:text,optional {label "Title"} {html "size 30"}}
    {description:text(textarea),optional {label "Description"} {html "rows 5 cols 35"}}
} -select_query_name {get_file} -new_data {
    set name [template::util::file::get_property filename $upload_file]
    set package_id [ad_conn package_id]
    set existing_item_id [fs::get_item_id -name $name -folder_id $folder_id]
    if {![empty_string_p $existing_item_id]} {
	# file with the same name already exists
	# in this folder, create a new revision
	set file_id $existing_item_id
	permission::require_permission \
	    -object_id $file_id \
	    -party_id $user_id \
	    -privilege $write
    }
    
    fs::add_file \
	-name [template::util::file::get_property filename $upload_file] \
	-item_id $file_id \
	-parent_id $folder_id \
	-tmp_filename [template::util::file::get_property tmp_filename $upload_file] \
	-creation_user $user_id \
	-creation_ip [ad_conn peeraddr] \
	-title $title \
	-description $description \
        -package_id $package_id
    
    ad_returnredirect "."
    ad_script_abort
}

ad_return_template