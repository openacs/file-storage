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
    {lock_title_p 1}

} -properties {
    folder_id:onevalue
    context:onevalue
    title:onevalue
    lock_title_p:onevalue
} -validate {
    file_id_or_folder_id {
	if {[exists_and_not_null file_id] && ![exists_and_not_null folder_id]} {
	    set folder_id [db_string get_folder_id "" -default ""]
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
set package_id [ad_conn package_id]
# check for write permission on the folder or item

permission::require_permission \
    -object_id $folder_id \
    -party_id $user_id \
    -privilege "write"

if {![ad_form_new_p -key file_id]} {
    permission::require_permission \
	-object_id $file_id \
	-party_id $user_id \
	-privilege "write"
set context [fs_context_bar_list -final "[_ file-storage.Add_Revision]" $folder_id]
    
} else {
    set context [fs_context_bar_list -final "[_ file-storage.Add_File]" $folder_id]
}
# if title isn't passed in ignore lock_title_p
if {[empty_string_p $title]} {
    set lock_title_p 0
}

ad_form -html { enctype multipart/form-data } -export { folder_id } -form {
    file_id:key
    {upload_file:file {label \#file-storage.Upload_a_file\#} {html "size 30"}}
}

if {$lock_title_p} {
    ad_form -extend -form {
	{title_display:text(inform) {label \#file-storage.Title\#} }
	{title:text(hidden) {value $title}}
    }
} else {
    ad_form -extend -form {
	{title:text,optional {label \#file-storage.Title\#} {html {size 30}} }
    }
}

ad_form -extend -form {
    {description:text(textarea),optional {label \#file-storage.Description\#} {html "rows 5 cols 35"}}
} -select_query_name {get_file} -new_data {
    # upload a new file
    # if the user choose upload from the folder view
    # and the file with the same name already exists
    # we create a new revision
    set name [template::util::file::get_property filename $upload_file]
    if {[string equal $title ""]} {
	set title $name
    }
    set existing_item_id [fs::get_item_id -name $name -folder_id $folder_id]
    if {![empty_string_p $existing_item_id]} {
	# file with the same name already exists
	# in this folder, create a new revision
	set file_id $existing_item_id
	permission::require_permission \
	    -object_id $file_id \
	    -party_id $user_id \
	    -privilege write
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
} -edit_data {

    fs::add_version \
	-name [template::util::file::get_property filename $upload_file] \
	-tmp_filename [template::util::file::get_property tmp_filename $upload_file] \
        -item_id $file_id \
	-parent_id $folder_id \
	-creation_user $user_id \
	-creation_ip [ad_conn peeraddr] \
	-title $title \
	-description $description \
	-package_id $package_id

    ad_returnredirect "."
    ad_script_abort
}

# if title isn't passed in ignore lock_title_p
if {[empty_string_p $title]} {
    set lock_title_p 0
}

set unpack_available_p [expr ![empty_string_p [string trim [parameter::get -parameter UnzipBinary]]]]

ad_return_template