ad_library {
    Automated tests.

    @author Mounir Lallali.
    @creation-date 18 Junuary 2006

}

namespace eval file_storage::twt {}

ad_proc file_storage::twt::call_fs_page {} {
    set fs_page [aa_get_first_url -package_key file-storage]
    ::twt::do_request $fs_page
}

ad_proc file_storage:::twt::create_file { f_name }  {

    # Create a temporal file
    set file_name "/tmp/$f_name.txt"
    exec touch $file_name
    exec ls / >> $file_name
    exec chmod 777 $file_name
    return $file_name
}

ad_proc file_storage:::twt::delete_file { file_name }  {

    # Delete a file name
    file delete -force -- $file_name
}

ad_proc file_storage::twt::create_new_folder { folder_name folder_description }  {
    
    set response 0
    
    tclwebtest::link follow {New Folder}
    
    tclwebtest::form find ~n "folder-ae"
    tclwebtest::field find ~n "folder_name"
    tclwebtest::field fill $folder_name
    tclwebtest::field find ~n "description"
    tclwebtest::field fill $folder_description
    tclwebtest::form submit
    
    set response_url [tclwebtest::response url]

    if { [string match  "*/\?folder_id*" $response_url] } {

        if { [catch {tclwebtest::assert text $folder_name} errmsg]} {
            aa_error "file_storage::twt::create_new_folder failed $errmsg : Didn't Create a New Folder"
        } else {
            aa_log "a New Folder created"
            set response 1
        }
    } else {
        aa_error "file_storage::twt::create_new_folder failed, bad response url : $response_url"
    }

    return $response
}

ad_proc file_storage::twt::delete_folder {}  {

    set response 0

    tclwebtest::link follow {Delete this folder}
 
    tclwebtest::form find ~n "folder-delete"
    tclwebtest::form submit ~n {formbutton:ok}

    set response_url [tclwebtest::response url]

    if { [string match  "*\?folder_id*" $response_url] } {

        if { ![catch {tclwebtest::link find $folder_name} errmsg]} {
            aa_error "file_storage::twt::delete_folder failed $errmsg : Didn't Delete a Folder"
        } else {
            aa_log "a Folder deleted"
            set response 1
        }
    } else {
        aa_error "file_storage::twt::delete_folder failed, bad response url : $response_url"
    }

    return $response
}

ad_proc file_storage::twt::edit_folder { folder_name }  {

    set response 0

    tclwebtest::link follow {Edit Folder}

    tclwebtest::form find ~a "folder-edit-2"
    tclwebtest::field find ~n "folder_name"
    tclwebtest::field fill $folder_name
    tclwebtest::form submit 

    set response_url [tclwebtest::response url]

    if { [string match  "*\?folder_id*" $response_url] } {

        if { [catch {tclwebtest::assert text $folder_name} errmsg]} {
            aa_error "file_storage::twt::edit_folder failed $errmsg : Didn't Edit a Folder"
        } else {
            aa_log "a Folder edited"
            set response 1
        }
    } else {
        aa_error "file_storage::twt::edit_folder failed, bad response url : $response_url"
    }

    return $response
}

ad_proc file_storage::twt::add_file_to_folder { folder_name file_name file_description }  {

    set response 0

    # Follow the Add File link
    tclwebtest::link follow {Add File}

    tclwebtest::form find ~n "file-add"
    tclwebtest::field find ~n "upload_file"
    tclwebtest::field fill $file_name
    tclwebtest::field find ~n "title"
    tclwebtest::field fill $file_name
    tclwebtest::field find ~n "description"
    tclwebtest::field fill $file_description
    tclwebtest::form submit

    set response_url [tclwebtest::response url]

    if { [string match  "*\?folder*id*" $response_url] } {

        set list_words [split "$file_name" /]
        set short_file_name [lindex $list_words [llength $list_words]-1]

        if {[catch {tclwebtest::assert text $folder_name} errmsg] || [catch {tclwebtest::link find $short_file_name} errmsg]} {
            aa_error "file_storage::twt::add_file_to_folder failed $errmsg : Didn't add a file to folder"
        } else {
            aa_log "a File uploaded"
            set response 1
        }
    } else {
        aa_error "file_storage::twt::add_file_to_folder  failed, bad response url : $response_url"
    }

    return $response
}

ad_proc file_storage::twt::create_url_in_folder { url_title url url_description }  {

    set response 0

    # Follow the Create URL link
    tclwebtest::link follow {Create a URL}

    tclwebtest::form find ~n "simple-add"
    tclwebtest::field find ~n "title"
    tclwebtest::field fill $url_title
    tclwebtest::field find ~n "url"
    tclwebtest::field fill $url
    tclwebtest::field find ~n "description"
    tclwebtest::field fill $url_description
    tclwebtest::form submit

    set response_url [tclwebtest::response url]

    if { [string match  "*\?folder_id*" $response_url] } {

        if {[catch {tclwebtest::link find $url_title} errmsg]} {
            aa_error "file_storage::twt::create_url_in_folder $errmsg : Didn't create an URL in a folder"
        } else {
            aa_log "an URL created in a folder"
            set response 1
        }

    } else {
        aa_error "file_storage::twt::create_url_in_folder  failed, bad response url : $response_url"
    }
}

ad_proc file_storage::twt::upload_file { file_name file_description }  {

    set response 0

    # Follow the Upload File link
    tclwebtest::link follow {Add File}

     tclwebtest::form find ~n "file-add"
     tclwebtest::field find ~n "upload_file"
     tclwebtest::field fill $file_name
     tclwebtest::field find ~n "title"
     tclwebtest::field fill $file_name
     tclwebtest::field find ~n "description"
     tclwebtest::field fill $file_description
     tclwebtest::form submit

     set response_url [tclwebtest::response url]

     if { [string match  "*\?folder*id*" $response_url] } {

 	set list_words [split "$file_name" /]
         set short_file_name [lindex $list_words [llength $list_words]-1]

         if {[catch {tclwebtest::link find $short_file_name} errmsg]} {
             aa_error "file_storage::twt::upload_file failed $errmsg : Didn't upload a File"
         } else {
             aa_log "a File uploaded"
             set response 1
         }
     } else {
         aa_error "file_storage::twt::upload_file failed, bad response url : $response_url"
     }
    
     return $response
 }

 ad_proc file_storage::twt::delete_uploaded_file { file_name }  {

     set response 0

     # Follow the Delete File Link
     tclwebtest::link follow properties
     tclwebtest::link follow {Delete File}

     tclwebtest::form find ~n "file-delete"
     tclwebtest::form submit

     set response_url [tclwebtest::response url]

     if { [string match  "*\?folder*id*" $response_url] } {

 	# Get the short file name
 	set list_words [split "$file_name" /]
 	set short_file_name [lindex $list_words [llength $list_words]-1]

         if {![catch {tclwebtest::link find $short_file_name} errmsg]} {
             aa_error "file_storage::twt::delete_file failed $errmsg : Didn't delete a File"
         } else {
             aa_log "a File deleted"
             set response 1
         }
     } else {
         aa_error "file_storage::twt::delete_file failed, bad response url : $response_url"
     }
    
     return $response
 }

 ad_proc file_storage::twt::rename_file { file_name }  {

     set response 0

     tclwebtest::link follow {properties}

     # Follow the Rename File link
     tclwebtest::link follow {Rename File}

     tclwebtest::form find ~n "file-edit"
     tclwebtest::field find ~n "title"
     tclwebtest::field fill $file_name
     tclwebtest::form submit

     set response_url [tclwebtest::response url]

     if { [string match  "*/file\?file_id*" $response_url] } {

         if {[catch {tclwebtest::link find $file_name} errmsg]} {
             aa_error "file_storage::twt::rename_file $errmsg : Didn't rename a file"
         } else {
             aa_log "a File ranamed"
             set response 1
         }

     } else {
         aa_error "file_storage::twt::rename_file failed, bad response url : $response_url"
     }

     return $response
 }

 ad_proc file_storage::twt::copy_file { folder_name file_name }  {

    set response 0

    tclwebtest::link follow {properties}

    # Follow the Move File link
    tclwebtest::link follow {Move File}
    tclwebtest::link follow $folder_name

    set response_url [tclwebtest::response url]

    if { [string match  "*/dotlrn/file-storage/\?folder*id*" $response_url] } {

        # Get the short file name
        set list_words [split "$file_name" /]
        set short_file_name [lindex $list_words [llength $list_words]-1]

        if {![catch {tclwebtest::link find $short_file_name} errmsg]} {
            aa_error "file_storage::twt::move_file $errmsg : Didn't move a file"
        } else {
            aa_log "a File moved"
            set response 1
        }

    } else {
        aa_error "file_storage::twt::move_file failed, bad response url : $response_url"
    }

    return $response
}

ad_proc file_storage::twt::move_file { folder_name file_name }  {

    set response 0

    tclwebtest::link follow {properties}

    # Follow the Rename URL link
    tclwebtest::link follow {Copy File}
    tclwebtest::link follow $folder_name

    set response_url [tclwebtest::response url]

    if { [string match  "*/dotlrn/file-storage/\?folder*id*" $response_url] } {

        # Get the short file name
        set list_words [split "$file_name" /]
        set short_file_name [lindex $list_words [llength $list_words]-1]

        if {[catch {tclwebtest::link find $short_file_name} errmsg]} {
            aa_error "file_storage::twt::copy_file $errmsg : Didn't copy a file"
        } else {
            aa_log "a File copied"
            set response 1
        }

    } else {
        aa_error "file_storage::twt::copy_file failed, bad response url : $response_url"
    }

    return $response
}



ad_proc file_storage::twt::create_url { url_title url url_description }  {

    set response 0

    # Follow the Create URL link
    tclwebtest::link follow {Create a URL}

    tclwebtest::form find ~n "simple-add"
    tclwebtest::field find ~n "title"
    tclwebtest::field fill $url_title
    tclwebtest::field find ~n "url"
    tclwebtest::field fill $url
    tclwebtest::field find ~n "description"
    tclwebtest::field fill $url_description
    tclwebtest::form submit

    set response_url [tclwebtest::response url]

    if { [string match  "*\?folder*id*" $response_url] } {
	
        if {[catch {tclwebtest::link find $url_title} errmsg]} {
            aa_error "file_storage::twt::create_url $errmsg : Didn't create an URL"
        } else {
            aa_log "an URL created"
            set response 1
        }
        
    } else {
	aa_error "file_storage::twt::create_url  failed, bad response url : $response_url"
    }
    
    return $response
}

ad_proc file_storage::twt::edit_url {url_title url url_description }  {

    set response 0


    tclwebtest::link follow properties

    # Follow the Edit URL link
    tclwebtest::link follow {Edit}

    tclwebtest::form find ~n "simple-edit"
    tclwebtest::field find ~n "name"
    tclwebtest::field fill $url_title
    tclwebtest::field find ~n "url"
    tclwebtest::field fill $url
    tclwebtest::field find ~n "description"
    tclwebtest::field fill $url_description
    tclwebtest::form submit

    set response_url [tclwebtest::response url]

    if { [string match  "*/dotlrn/file-storage/\?folder*id*" $response_url] } {

        if {[catch {tclwebtest::link find $url_title} errmsg]} {
            aa_error "file_storage::twt::edit_url $errmsg : Didn't edit an URL"
        } else {
            aa_log "an URL edited"
            set response 1
        }

    } else {
        aa_error "file_storage::twt::edit_url  failed, bad response url : $response_url"
    }

    return $response
}

ad_proc file_storage::twt::delete_url { url_title }  {

    set response 0

    tclwebtest::link follow {properties}

    # Follow the Delete URL link
    tclwebtest::link follow {delete}
    
    set response_url [tclwebtest::response url]

    if { [string match  "*/dotlrn/file-storage/\?folder*id*" $response_url] } {

        if {![catch {tclwebtest::link find $url_title} errmsg]} {
            aa_error "file_storage::twt::delete_url $errmsg : Didn't delete an URL"
        } else {
            aa_log "an URL deleted"
            set response 1
        }

    } else {
        aa_error "file_storage::twt::delete_url  failed, bad response url : $response_url"
    }

    return $response
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
