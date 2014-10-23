ad_page_contract {
    page to add a new file to the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    file_id:naturalnum,optional,notnull
    folder_id:naturalnum,optional,notnull
    upload_file:trim,optional
    return_url:optional
    upload_file.tmpfile:tmpfile,optional
    content_body:optional
    {title ""}
    {lock_title_p 0}
    {name ""}

} -properties {
    folder_id:onevalue
    context:onevalue
    title:onevalue
    lock_title_p:onevalue
    instructions:onevalue
} -validate {
    file_id_or_folder_id {
	if {[info exists file_id] && ![info exists folder_id]} {
	    set folder_id [content::item::get_parent_folder -item_id $file_id]
	    if {$folder_id eq ""} {
		ad_complain "The specified file_id is not valid."
		return
	    }
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
set unpack_binary [string trim [parameter::get -parameter UnzipBinary]]
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

ad_form -html { enctype multipart/form-data } -export { folder_id lock_title_p name } -form {
    file_id:key
    {upload_file:file {label \#file-storage.Upload_a_file\#} {html "size 30"}}
}

if {[parameter::get -parameter AllowTextEdit -default 0]} {
    if {[ad_form_new_p -key file_id]} { 
            
        # To allow the creation of files
        ad_form -extend -form {
            {content_body:richtext(richtext),optional 
                {label "Create a file"} 
                {html "rows 20 cols 70" } 
                {htmlarea_p 1}
            }
        }
    } else {
        # To make content editable
        set revision_id [content::item::get_live_revision -item_id $file_id]
        set mime_type [db_string get_mime_type "select mime_type from cr_revisions where revision_id = :revision_id"]
        if {$mime_type eq "text/html"} {
            ad_form -extend -form {
                {edit_content:richtext(richtext),optional 
                    {label "Content"} 
                    {html "rows 20 cols 70" } 
                    {htmlarea_p 1}
                }
                {mime_type:text(hidden) 
                    {value $mime_type}
                }
            }
        }
    }
}

if {([info exists return_url] && $return_url ne "")} {
    ad_form -extend -form {
	{return_url:text(hidden) {value $return_url}}
    }
}

if {$lock_title_p} {
    ad_form -extend -form {
	{title:text(hidden) {value $title}}
    }
} else { 
   ad_form -extend -form {
	{title:text,optional {label \#file-storage.Title\#} {html {size 30}} }
    }
}

ad_form -extend -form {
    {description:text(textarea),optional {label \#file-storage.Description\#} {html "rows 5 cols 35"}}
}

if [catch {set binary [exec $unpack_binary]} errormsg] {
      set unpack_bin_installed 0
} else {
        set unpack_bin_installed 1
}

if {([ad_form_new_p -key file_id]) && $unpack_bin_installed } { 
    ad_form -extend -form {
	{unpack_p:boolean(checkbox),optional {label \#file-storage.Multiple_files\#} {html {onclick "javascript:UnpackChanged(this);"}} {options { {\#file-storage.lt_This_is_a_ZIP\# t} }} }
    }
}
if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
     if { ([info exists file_id] && $file_id ne "") } {
	 set categorized_object_id $file_id
     } else {
	 # pre-populate with categories from the folder
	 set categorized_object_id $folder_id
     }
    
    category::ad_form::add_widgets \
	 -container_object_id $package_id \
	 -categorized_object_id $categorized_object_id \
	 -form_name file-add
}

ad_form -extend -form {} -select_query_name {get_file} -new_data {
    
  if {(![info exists unpack_p] || $unpack_p eq "")} {
      set unpack_p f
  }
  if { $unpack_p && $unpack_binary ne "" && [file extension [template::util::file::get_property filename $upload_file]] eq ".zip"  } {
	
	set path [ad_tmpnam]
	file mkdir $path
	
	
	catch { exec $unpack_binary -jd $path ${upload_file.tmpfile} } errmsg
	
	# More flexible parameter design could be:
	# zip {unzip -jd {out_path} {in_file}} tar {tar xf {in_file} {out_path}} tgz {tar xzf {in_file} {out_path}} 

	set upload_files [list]
	set upload_tmpfiles [list]
	
	foreach file [glob -nocomplain "$path/*"] {
	    lappend upload_files [file tail $file]
	    lappend upload_tmpfiles $file
	}
	
    } else {
	set upload_files [list [template::util::file::get_property filename $upload_file]]
	set upload_tmpfiles [list [template::util::file::get_property tmp_filename $upload_file]]
    }
    set mime_type ""
    if { [empty_string_p [lindex $upload_files 0]]} {
        if {[parameter::get -parameter AllowTextEdit -default 0] && [empty_string_p [template::util::richtext::get_property html_value $content_body]] } {
            ad_return_complaint 1 "You have to upload a file or create a new one"
            ad_script_abort
        }
        # create a tmp file to import from user entered HTML
        set content_body [template::util::richtext::get_property html_value $content_body]
        set mime_type text/html
        set tmp_filename [ad_tmpnam]
        set fd [open $tmp_filename w] 
        puts $fd $content_body
        close $fd
        set upload_files [list $title]
        set upload_tmpfiles [list $tmp_filename]
    }
    # ns_log notice "file_add mime_type='${mime_type}'"	    
    set i 0
    set number_upload_files [llength $upload_files]
    foreach upload_file $upload_files tmpfile $upload_tmpfiles {
	set this_file_id $file_id
	set this_title $title
	set mime_type [cr_filename_to_mime_type -create -- $upload_file]
	# upload a new file
	# if the user choose upload from the folder view
	# and the file with the same name already exists
	# we create a new revision
	
	if {$this_title eq ""} {
	    set this_title $upload_file
	}
	
	if {$name ne ""} {
	    set upload_file $name
	}

	set existing_item_id [fs::get_item_id -name $upload_file -folder_id $folder_id]
	
	if {$existing_item_id ne ""} {
	    # file with the same name already exists in this folder
            if { [parameter::get -parameter "BehaveLikeFilesystemP" -package_id [ad_conn package_id]] } {
                # create a new revision -- in effect, replace the existing file
                set this_file_id $existing_item_id
                permission::require_permission \
                    -object_id $this_file_id \
                    -party_id $user_id \
                    -privilege write
            } else {
                # create a new file by altering the filename of the
                # uploaded new file (append "-1" to filename)
                set extension [file extension $upload_file]
                set root [string trimright $upload_file $extension]
                append new_name $root "-$this_file_id" $extension
                set upload_file $new_name
            }
	}

	fs::add_file \
	    -name $upload_file \
	    -item_id $this_file_id \
	    -parent_id $folder_id \
	    -tmp_filename $tmpfile\
	    -creation_user $user_id \
	    -creation_ip [ad_conn peeraddr] \
	    -title $this_title \
	    -description $description \
	    -package_id $package_id \
            -mime_type $mime_type

	if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
	    category::map_object -remove_old -object_id $this_file_id [category::ad_form::get_categories \
									   -container_object_id $package_id \
									   -element_name category_id]
        }

        file delete $tmpfile
        incr i
        if {$i < $number_upload_files} {
            set file_id [db_nextval "acs_object_id_seq"]
        }
    }
    file delete $upload_file.tmpfile
} -edit_data {
    set this_title $title
    set filename [template::util::file::get_property filename $upload_file]
    if {$this_title eq ""} {
	set this_title $filename
    }
	
    fs::add_version \
	-name $filename \
	-tmp_filename [template::util::file::get_property tmp_filename $upload_file] \
        -item_id $file_id \
	-creation_user $user_id \
	-creation_ip [ad_conn peeraddr] \
	-title $this_title \
	-description $description \
	-package_id $package_id
	
    if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
	category::map_object -remove_old -object_id $file_id [category::ad_form::get_categories \
								  -container_object_id $package_id \
								  -element_name category_id]
    }
} -after_submit {

    if {([info exists return_url] && $return_url ne "")} {
	ad_returnredirect $return_url
    } else {
	ad_returnredirect "./?[export_vars -url {folder_id}]"
    }
    ad_script_abort

}

# if title isn't passed in ignore lock_title_p
if {$title eq ""} {
    set lock_title_p 0
}

if { [parameter::get -parameter "BehaveLikeFilesystemP" -package_id [ad_conn package_id]] } {
    set instructions "[_ file-storage.Add_Dup_As_Revision]"
} else {
    set instructions "[_ file-storage.Add_Dup_As_New_File]"
}

set unpack_available_p [expr {[string trim [parameter::get -parameter UnzipBinary]] ne ""}]

ad_return_template
