ad_page_contract {
    page to add a new file to the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    file_id:naturalnum,optional,notnull
    folder_id:naturalnum,optional,notnull
    upload_file:trim,optional
    return_url:localurl,optional
    upload_file.tmpfile:tmpfile,optional
    content_body:optional
    {title ""}
    {lock_title_p:boolean 0}
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
        if {![info exists folder_id] || ![fs_folder_p $folder_id]} {
            ad_complain "The specified parent folder is not valid."
        }
    }
    max_size -requires {upload_file} {
        set n_bytes [ad_file size ${upload_file.tmpfile}]
        set max_bytes [fs::max_upload_size]
        if { $n_bytes > $max_bytes } {
            set number_of_bytes [lc_numeric $max_bytes] ; # needed by message key
            ad_complain [_ file-storage.lt_Your_file_is_larger_t]
        }
    }
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set unpack_binary [util::which [string trim [parameter::get -parameter UnzipBinary]]]
set unpack_available_p [expr {$unpack_binary ne ""}]

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
    set page_title [_ file-storage.Add_Revision]
} else {
    set page_title [_ file-storage.Add_File]
}
set context [fs_context_bar_list -final $page_title $folder_id]

set max_upload_size [fs::max_upload_size]
set max_upload_size_pretty [lc_numeric $max_upload_size]
ad_form -html { enctype multipart/form-data } \
    -export { folder_id lock_title_p name return_url } \
    -form {
        file_id:key
        {upload_file:file
            {label "#file-storage.Upload_a_file#"}
            {html "size 30"}
            {help_text "[_ file-storage.Upload_Limit]: $max_upload_size_pretty"}
        }
    }

# Try to prevent upload of too big files from the client side. Saves
# us some useless requests and gives a quicker feedback to the user.
set number_of_bytes $max_upload_size_pretty ; # needed by message key
set file_too_big_msg [_ file-storage.lt_Your_file_is_larger_t]
template::add_event_listener -event submit -id file-add \
    -preventdefault=false -script [subst -nocommands {
    var uploadFileField = this.elements.namedItem('upload_file');
    var uploadFile = uploadFileField.files[0];
    if (uploadFile != undefined &&
        uploadFile.size > $max_upload_size) {
        alert('$file_too_big_msg');
        event.preventDefault();
    }
}]

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
        set mime_type [db_string get_mime_type {
            select mime_type from fs_objects where object_id = :file_id
        }]
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

if {$lock_title_p} {
    ad_form -extend -form {
        {title:text(hidden)
            {value $title}
        }
    }
} else {
    ad_form -extend -form {
        {title:text,optional
            {label "#file-storage.Title#"}
            {html {size 30}}
        }
    }
}
ad_form -extend -form {
    {description:text(textarea),optional
        {label "#file-storage.Description#"}
        {html "rows 5 cols 35"}
    }
}

if {[ad_form_new_p -key file_id] && $unpack_available_p } {
    ad_form -extend -form {
        {unpack_p:boolean(checkbox),optional
            {label "#file-storage.Multiple_files#"}
            {options {{"#file-storage.lt_This_is_a_ZIP#" t}}}
        }
    }
} else {
    set unpack_p false
}

if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
    if { [info exists file_id] && $file_id ne "" } {
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

ad_form -extend -form {} -select_query_name get_file -new_data {

    if { [string is true -strict $unpack_p]
         && [file extension [template::util::file::get_property filename $upload_file]] eq ".zip"
    } {

        set path [ad_tmpnam]
        file mkdir $path


        catch { exec $unpack_binary -jd $path ${upload_file.tmpfile} } errmsg

        # More flexible parameter design could be:
        # zip {unzip -jd {out_path} {in_file}} tar {tar xf {in_file} {out_path}} tgz {tar xzf {in_file} {out_path}}

        set upload_files [list]
        set upload_tmpfiles [list]

        foreach file [glob -nocomplain "$path/*"] {
            lappend upload_files [ad_file tail $file]
            lappend upload_tmpfiles $file
        }

    } else {
        set upload_files [list [template::util::file::get_property filename $upload_file]]
        set upload_tmpfiles [list [template::util::file::get_property tmp_filename $upload_file]]
    }
    if { [lindex $upload_files 0] eq ""} {
        if {[info exists content_body] && $content_body ne ""} {
            set content_body [template::util::richtext::get_property html_value $content_body]
        } else {
            ad_return_complaint 1 "You have to upload a file or create a new one"
            ad_script_abort
        }
        # create a temporary file to import from user entered HTML
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

        # The upload filename is the one we are going to use as
        # download filename. Must be safe.
        set upload_file [ad_sanitize_filename \
                             -collapse_spaces \
                             -tolower \
                             $upload_file]

        set existing_item_id [fs::get_item_id -name $upload_file -folder_id $folder_id]

        if {$existing_item_id ne ""} {
            # file with the same name already exists in this folder
            if { [parameter::get -parameter "BehaveLikeFilesystemP" -package_id $package_id] } {
                # create a new revision -- in effect, replace the existing file
                set this_file_id $existing_item_id
                permission::require_permission \
                    -object_id $this_file_id \
                    -party_id $user_id \
                    -privilege write
            } else {
                # create a new filename by appending the item_id to its rootname
                set extension [ad_file extension $upload_file]
                set rootname [ad_file rootname $upload_file]
                set upload_file ${rootname}-${this_file_id}${extension}
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

        file delete -- $tmpfile
        incr i
        if {$i < $number_upload_files} {
            set file_id [db_nextval "acs_object_id_seq"]
        }
    }
    file delete -- $upload_file.tmpfile
} -edit_data {
    set filename [template::util::file::get_property filename $upload_file]
    set this_title [expr {$title ne "" ? $title : $filename}]

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

    if {![info exists return_url] || $return_url eq ""} {
        set return_url [export_vars -base ./ {folder_id}]
    }
    ad_returnredirect $return_url
    ad_script_abort

}

# if title isn't passed in ignore lock_title_p
if {$title eq ""} {
    set lock_title_p 0
}

if { [parameter::get -parameter "BehaveLikeFilesystemP" -package_id $package_id] } {
    set instructions [_ file-storage.Add_Dup_As_Revision]
} else {
    set instructions [_ file-storage.Add_Dup_As_New_File]
}


if {$unpack_available_p} {
    template::add_body_script -script {
        function UnpackChanged(elm) {
            var form_name = "file-add";

            if (elm == null) return;
            if (document.forms == null) return;
            if (document.forms[form_name] == null) return;

            if (elm.checked == true) {
                document.forms[form_name].elements["title"].disabled = true;
                //document.getElementById('fs_title_msg').innerHTML= 'The title you entered will not be used if you upload multiple files at once';

            } else {
                document.forms[form_name].elements["title"].disabled = false;
                //document.getElementById('fs_title_msg').innerHTML= '';
            }
        };
        document.getElementById('file-add:elements:unpack_p:t').addEventListener('click', function (event) {
            UnpackChanged(this);
        }, false);
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
