ad_page_contract {
    page to add a new file to the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,optional,notnull
    folder_id:integer,optional,notnull
    upload_file:trim,optional
    return_url:optional
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
        if {[exists_and_not_null file_id] && ![exists_and_not_null folder_id]} {
            set folder_id [db_string get_folder_id "select parent_id as folder_id from cr_items where item_id=:file_id" -default ""]
        }
        if {![fs_folder_p $folder_id]} {
            ad_complain "The specified parent folder is not valid."
        }
    }
    max_size -requires {upload_file} {
        set n_bytes [file size ${upload_file.tmpfile}]
        set max_bytes [parameter::get -parameter "MaximumFileSize"]
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

ad_form -name file_add -html { enctype multipart/form-data } -export { folder_id lock_title_p } -form {
    file_id:key
    {upload_file:file {label \#file-storage.Upload_a_file\#} {html "size 30"}}
}

if {[exists_and_not_null return_url]} {
    ad_form -extend -name file_add -form {
	{return_url:text(hidden) {value $return_url}}
    }
}

if {$lock_title_p} {
    ad_form -extend -name file_add -form {
	{title:text(hidden) {value $title}}
    }
} else {
    ad_form -extend -name file_add -form {
	{title:text {label \#file-storage.Title\#} {html {size 30}} }
    }
}

if {[ad_form_new_p -key file_id]} { 
    ad_form -extend -name file_add -form {
        {unpack_message:text(inform) {label "[_ file-storage.Important]"} {value "[_ file-storage.Use_this_form_to_upload_a_ZIP]"}}
    }
}

ad_form -extend -name file_add -form {} -new_data {
    
    # create a new folder to hold the zip contents
    # TODO make sure its name is unique?
    
    if {[empty_string_p $title]} {
	set title [file rootname [list [template::util::file::get_property filename $upload_file]]]
    }
    set folder_id [content::folder::new -name $title -parent_id $folder_id -label $title]
    
    set unzip_binary [string trim [parameter::get -parameter UnzipBinary]]
    
    if { ![empty_string_p $unzip_binary] } {
        
        set unzip_path [ns_tmpnam]
        file mkdir $unzip_path
        # save paths! get rid of -j switch --DAVEB 20050628
        catch { exec $unzip_binary -d $unzip_path ${upload_file.tmpfile} } errmsg
        
        # More flexible parameter design could be:
        # zip {unzip -jd {out_path} {in_file}} tar {tar xf {in_file} {out_path}} tgz {tar xzf {in_file} {out_path}} 
        
        set upload_files [list]
        set upload_tmpfiles [list]
        
        foreach file [ad_find_all_files "$unzip_path"] {
            lappend upload_files [regsub "^$unzip_path\/" $file {}]
            lappend upload_tmpfiles $file
        }
        
    } else {
        set upload_files [list [template::util::file::get_property filename $upload_file]]
        set upload_tmpfiles [list [template::util::file::get_property tmp_filename $upload_file]]
    }
    
    if { [empty_string_p [lindex $upload_files 0]]} {
        ad_return_complaint 1 "<li>You have to upload a file"
        ad_script_abort
    }
    
    set i 0
    set number_upload_files [llength $upload_files]
    foreach upload_file $upload_files tmpfile $upload_tmpfiles {
	set this_file_id $file_id
	set this_title $title
	# upload a new file
	# if the user choose upload from the folder view
	# and the file with the same name already exists
	# we create a new revision
	
	# check if this is in a folder inside the zip and create
	# the folders if they don't exist
	set p_f_id $folder_id
	set file_paths [file split [file dirname $upload_file]]
	ns_log notice "\n DAVEB1 \n '${file_paths}'"
	if {![string equal "." $file_paths] && [llength $file_paths]} {
	    # make sure every folder exists
	    set path ""
	    foreach p $file_paths {
		append path /${p}
		if {![info exists paths($path)]} {
		    set f_id [content::item::get_id -item_path $path -root_folder_id $p_f_id]
		    if {[string equal "" $f_id]} {
			set p_f_id [content::folder::new -parent_id $p_f_id -name $p -label $p]
			set paths($path) $p_f_id
		    }
		} else { 
		    set p_f_id $paths($path)
		}
                
	    }
	    set upload_file [file tail $upload_file]
	} 
	
	set this_folder_id $p_f_id
	set this_title $upload_file
	
	set existing_item_id [fs::get_item_id -name $upload_file -folder_id $this_folder_id]
	
	if {![empty_string_p $existing_item_id]} {
	    # file with the same name already exists
	    # in this folder, create a new revision
	    set this_file_id $existing_item_id
	    permission::require_permission \
		-object_id $this_file_id \
		-party_id $user_id \
		-privilege write
	}
	
	set rev_id [fs::add_file \
			-name $upload_file \
			-item_id $this_file_id \
			-parent_id $this_folder_id \
			-tmp_filename $tmpfile \
			-creation_user $user_id \
			-creation_ip [ad_conn peeraddr] \
			-title $this_title \
			-package_id $package_id]
	
	file delete $tmpfile
	incr i

	if {![empty_string_p $rev_id]} {
	    set this_file_id [db_string get_item_id {
		select item_id
		from cr_revisions
		where revision_id = :rev_id
	    } -default 0]
	}
	
	if {$i < $number_upload_files} {
	    set file_id [db_nextval "acs_object_id_seq"]
	}
	
    }
    if {![string equal "" $unzip_path]} {
	file delete -force $unzip_path
    }
    file delete $upload_file.tmpfile
} -edit_data {
    fs::add_version \
	-name [template::util::file::get_property filename $upload_file] \
	-tmp_filename [template::util::file::get_property tmp_filename $upload_file] \
	-item_id $file_id \
	-creation_user $user_id \
	-creation_ip [ad_conn peeraddr] \
	-title $title \
	-package_id $package_id
    
} -after_submit {
    
    if {[exists_and_not_null return_url]} {
	ad_returnredirect $return_url
    } else {
	ad_returnredirect "./?[export_url_vars folder_id]"
    }
    ad_script_abort
    
}

set unpack_available_p [expr ![empty_string_p [string trim [parameter::get -parameter UnzipBinary]]]]

ad_return_template