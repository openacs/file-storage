ad_page_contract {

    Page to upload and decompress a zip file into the file storage.

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$

} {

    file_id:naturalnum,optional,notnull
    {folder_id:naturalnum,notnull ""}
    upload_file:trim,optional,notnull
    {return_url:localurl ""}
    upload_file.tmpfile:tmpfile,optional
    {title ""}
    {lock_title_p:boolean 0}

} -properties {

    folder_id:onevalue
    context:onevalue
    title:onevalue
    lock_title_p:onevalue

} -validate {

    file_id_or_folder_id {
        #
        # Get parent folder_id from file_id, if such exists and folder_id is
        # empty, and complain if the resultant folder is not valid.
        #
        if {[info exists file_id] && $file_id ne "" && $folder_id eq ""} {
            set folder_id [db_string get_folder_id {
                select parent_id as folder_id from cr_items where item_id=:file_id
            } -default ""]
        }
        if {$folder_id eq "" || ![fs_folder_p $folder_id]} {
            ad_complain "The specified parent folder is not valid."
        }
    }

    upload_file_tmpfile -requires {upload_file} {
        #
        # Check if the upload file looks like a zip file
        #
        set n_bytes [ad_file size ${upload_file.tmpfile}]
        if {$n_bytes < 5} {
            #
            # A zip file has at least 4 bytes.
            #
            set ok 0
        } else {
            #
            # Check the signature of the zip file.
            #
            set ok [util::file_content_check -type zip -file ${upload_file.tmpfile}]
        }
        if { !$ok} {
            ad_complain "The uploaded file does not look like a zip file."
        }
    }

    max_size -requires {upload_file} {
        #
        # Check if the file is larger than fs::max_upload_size.
        #
        set n_bytes [ad_file size ${upload_file.tmpfile}]
        set max_bytes [fs::max_upload_size]
        if { $n_bytes > $max_bytes } {
            ad_complain "Your file is larger than the maximum file size allowed on this system ([lc_content_size_pretty -size $max_bytes])"
        }
    }
}

set user_id     [ad_conn user_id]
set package_id  [ad_conn package_id]
set creation_ip [ad_conn peeraddr]

# Check for write permission on the folder.
permission::require_permission \
    -object_id $folder_id \
    -party_id $user_id \
    -privilege "write"

if {![ad_form_new_p -key file_id]} {
    #
    # Check for write permission on the file if we are editing existing data,
    # adding a file revision in this case, and set the context bar accordingly.
    #
    permission::require_permission \
        -object_id $file_id \
        -party_id $user_id \
        -privilege "write"
    set context [fs_context_bar_list -final "[_ file-storage.Add_Revision]" $folder_id]
} else {
    set context [fs_context_bar_list -final "[_ file-storage.Add_File]" $folder_id]
}

# Add file_id and upload_file to the form.
ad_form -name file_add -html { enctype multipart/form-data } -export { folder_id lock_title_p } -form {
    file_id:key
    {upload_file:file {label \#file-storage.Upload_a_file\#} {html "size 30"}}
}

# Add return_url to the form if is not empty.
if {$return_url ne ""} {
    ad_form -extend -name file_add -form {
        {return_url:text(hidden) {value $return_url}}
    }
}

# 'Lock' title if lock_title_p.
if {$lock_title_p} {
    ad_form -extend -name file_add -form {
        {title:text(hidden) {value $title}}
    }
} else {
    ad_form -extend -name file_add -form {
        {title:text {label \#file-storage.Title\#} {html {size 30}} }
    }
}

# Add an explanation about the purpose of the form.
if {[ad_form_new_p -key file_id]} {
    ad_form -extend -name file_add -form {
        {unpack_message:text(inform) {label "[_ file-storage.Important]"} {value "[_ file-storage.Use_this_form_to_upload_a_ZIP]"}}
    }
}

# Rest of the form.

# Folder names cannot contain slashes
ad_form -extend -name file_add -form {} -validate {
    {title
        {[string first "/" $title] == -1}
        "#acs-templating.Invalid_filename#"
    }
}

ad_form -extend -name file_add -form {} -new_data {
    #
    # new_data block, which unzips the file and uploads its contents to the file
    # storage, creating the necessary folders.
    #
    # Start defining the title if it does not exist already.
    #
    if {$title eq ""} {
        set title [file rootname [list [template::util::file::get_property filename $upload_file]]]
    }

    #
    # Create a new folder to hold the zip contents, if it does not exist already.
    #
    set parent_folder_id $folder_id
    set folder_id [content::item::get_id_by_name -name $title -parent_id $parent_folder_id]
    if {$folder_id eq ""} {
        set folder_id [content::folder::new -name $title -parent_id $parent_folder_id -label $title]
    }

    #
    # Uncompress the file.
    #
    set unzip_binary [string trim [parameter::get -parameter UnzipBinary]]
    if {$unzip_binary ne ""} {
        ns_log warning "package parameter UnzipBinary of file-storage is ignored, using systemwide util::unzip"
    }

    set unzip_binary [util::which unzip]
    if { $unzip_binary ne "" } {
        #
        # Create temp directory to unzip.
        #
        set unzip_path [ad_mktmpdir]

        #
        # Unzip.
        #
        util::unzip -source ${upload_file.tmpfile} -destination $unzip_path

        #
        # Get two lists of the files to upload, with and without their full path.
        #
        set upload_files [list]
        set upload_tmpfiles [list]
        foreach file [ad_find_all_files $unzip_path] {
            lappend upload_files [regsub "^$unzip_path\/" $file {}]
            lappend upload_tmpfiles $file
        }
    } else {
        #
        # No unzip available, just upload the whole zip file.
        #
        set upload_files    [list [template::util::file::get_property filename $upload_file]]
        set upload_tmpfiles [list [template::util::file::get_property tmp_filename $upload_file]]
    }
    set number_upload_files [llength $upload_files]

    #
    # Something is quite broken if there are no files to upload.
    #
    if {$number_upload_files == 0} {
        ad_return_complaint 1 "<li>You have to upload a file"
        ad_script_abort
    }

    #
    # Upload the files.
    #
    set i 0
    foreach upload_file $upload_files tmpfile $upload_tmpfiles {
        #
        # Upload a file.
        #
        set this_file_id $file_id
        set p_f_id $folder_id
        set file_paths [file split [ad_file dirname $upload_file]]
        if {"." ne $file_paths && [llength $file_paths] > 0} {
            #
            # Make sure every folder exists, or create it otherwise.
            #
            set path ""
            foreach p $file_paths {
                append path /${p}
                if {![info exists paths($path)]} {
                    set f_id [content::item::get_id -item_path $path -root_folder_id $p_f_id]
                    if {$f_id eq ""} {
                        set p_f_id [content::folder::new -parent_id $p_f_id -name $p -label $p]
                        set paths($path) $p_f_id
                    }
                } else {
                    set p_f_id $paths($path)
                }
            }
            set upload_file [ad_file tail $upload_file]
        }
        set this_title $upload_file
        set this_folder_id $p_f_id

        #
        # If the user choose upload from the folder view, and a file with the
        # same name already exists, we create a new revision.
        #
        # Check for permission in the existing file in order to do so.
        #
        set existing_item_id [fs::get_item_id -name $upload_file -folder_id $this_folder_id]
        if {$existing_item_id ne ""} {
            set this_file_id $existing_item_id
            permission::require_permission \
                -object_id $this_file_id \
                -party_id $user_id \
                -privilege write
        }

        #
        # Add the file.
        #
        set rev_id [fs::add_file \
            -name $upload_file \
            -item_id $this_file_id \
            -parent_id $this_folder_id \
            -tmp_filename $tmpfile \
            -creation_user $user_id \
            -creation_ip $creation_ip \
            -title $this_title \
            -package_id $package_id]

        #
        # Increment file_id to the next value of acs_object_id_seq.
        #
        incr i
        if {$i < $number_upload_files} {
            set file_id [db_nextval "acs_object_id_seq"]
        }

        #
        # Cleanup of the temporary file.
        #
        file delete -- $tmpfile
    }

    #
    # Cleanup of zip file and tmp directory.
    #
    file delete -- $upload_file.tmpfile
    if {$unzip_path ne ""} {
        file delete -force -- $unzip_path
    }

} -edit_data {
    #
    # edit_data block, which just adds a revision of a file.
    #
    fs::add_version \
        -name [template::util::file::get_property filename $upload_file] \
        -tmp_filename [template::util::file::get_property tmp_filename $upload_file] \
        -item_id $file_id \
        -creation_user $user_id \
        -creation_ip $creation_ip \
        -title $title \
        -package_id $package_id

} -after_submit {
    #
    # Code to be executed after new_data or edit_data, just redirecting to
    # return_url.
    #
    if {$return_url ne ""} {
        ad_returnredirect $return_url
    } else {
        ad_returnredirect [export_vars -base ./ {folder_id}]
    }
    ad_script_abort
}

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
