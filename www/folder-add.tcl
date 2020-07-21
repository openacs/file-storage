ad_page_contract {
    page to add a new file to the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    folder_id:naturalnum,optional,notnull
    upload_folder:trim,optional
    return_url:localurl,optional
    {lock_title_p:boolean 0}

} -properties {
    folder_id:onevalue
    context:onevalue
    title:onevalue
    lock_title_p:onevalue
} -validate {
    folder {
        if {![fs_folder_p $folder_id]} {
            ad_complain "The specified parent folder is not valid."
        }
    }
}

set user_id [ad_conn user_id]

if {![acs_user::site_wide_admin_p]} {
    ad_returnredirect [export_vars -base ./ {folder_id}]
    ad_script_abort
}

set package_id [ad_conn package_id]
# check for write permission on the folder or item

permission::require_permission \
    -object_id $folder_id \
    -party_id $user_id \
    -privilege "write"

set context [fs_context_bar_list -final "[_ file-storage.Add_File]" $folder_id]
set title "[_ file-storage.Add_File]"

ad_form -name file_add -html { enctype multipart/form-data } -export { folder_id lock_title_p } -form {
    {upload_folder:text(text) {label \#file-storage.Upload_a_folder#} {html "size 30"} {help_text "[_ file-storage.Upload_folder_help]"}}
}

if {[info exists return_url] && $return_url ne ""} {
    ad_form -extend -name file_add -form {
        {return_url:text(hidden) {value $return_url}}
    }
}


ad_form -extend -name file_add -form {} -on_submit {

    foreach file [ad_find_all_files "$upload_folder"] {
        lappend upload_files [regsub "^$upload_folder\/" $file {}]
        lappend upload_tmpfiles $file
    }

    if { [lindex $upload_files 0] eq ""} {
        ad_return_complaint 1 "You have to upload a file"
        ad_script_abort
    }

    set i 0
    set number_upload_files [llength $upload_files]
    foreach upload_file $upload_files tmpfile $upload_tmpfiles {
        # upload a new file
        # if the user chose upload from the folder view
        # and the file with the same name already exists
        # we create a new revision

        # check if this is in a folder inside the zip and create
        # the folders if they don't exist
        set p_f_id $folder_id
        set file_paths [file split [ad_file dirname $upload_file]]

        if {"." ne $file_paths && [llength $file_paths]} {
            # make sure every folder exists
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

        set this_folder_id $p_f_id
        set this_title $upload_file

        set existing_item_id [fs::get_item_id -name $upload_file -folder_id $this_folder_id]

        if {$existing_item_id ne ""} {
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
            -parent_id $this_folder_id \
            -tmp_filename $tmpfile \
            -creation_user $user_id \
            -creation_ip [ad_conn peeraddr] \
            -title $this_title \
            -package_id $package_id]

        incr i

        if {$rev_id ne ""} {
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

} -after_submit {

    if {[info exists return_url] && $return_url ne ""} {
        ad_returnredirect $return_url
    } else {
        ad_returnredirect [export_vars -base ./ {folder_id}]
    }
    ad_script_abort
}

set unpack_available_p [expr {[string trim [parameter::get -parameter UnzipBinary]] ne ""}]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
