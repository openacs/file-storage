ad_library {
    Support functions for automated tests of file storage.

    @author Gustaf Neumann
}

namespace eval file_storage::test {

    ad_proc -private ::file_storage::test::create_new_folder {
        -last_request:required
        folder_name
        folder_description
    } {
        Create a new folder via Web UI.
    } {
        #
        # Create a new folder based on the current page, which is from
        # a file-storage instance
        #
        set d [acs::test::follow_link -last_request $last_request -label {New Folder}]
        acs::test::reply_has_status_code $d 200

        set response [dict get $d body]
        set form [acs::test::get_form $response {//form[@id='folder-ae']}]
        aa_true "create form was returned" {[llength $form] > 2}

        set d [::acs::test::form_reply \
                   -last_request $d \
                   -form $form \
                   -update [subst {
                       folder_name "$folder_name"
                       description "$folder_description"
                   }]]
        acs::test::reply_has_status_code $d 302
        set location [::acs::test::get_url_from_location $d]

        if { [string match  "*/\?folder_id*" $location] } {
            set d [acs::test::http -last_request $d $location]
            acs::test::reply_contains $d $folder_name
        } else {
            aa_error "file_storage::test::create_new_folder failed, bad response url : $location"
        }

        return $d
    }

    ad_proc  -private ::file_storage::test::edit_folder {
        -last_request:required
        folder_name
    } {
        Create a new folder via Web UI.
    } {
        #
        # Create a new folder based on the current page, which is from
        # a file-storage instance
        #
        set d [acs::test::follow_link -last_request $last_request -label {Edit Folder}]
        acs::test::reply_has_status_code $d 200

        set response [dict get $d body]
        set form [acs::test::get_form $response {//form[@id='folder-edit']}]
        aa_true "edit form was returned" {[llength $form] > 2}
        set d [::acs::test::form_reply \
                   -last_request $d \
                   -form $form \
                   -update [subst {
                       folder_name "$folder_name"
                   }]]
        acs::test::reply_has_status_code $d 302
        set location [::acs::test::get_url_from_location $d]

        if { [string match  "*/\?folder_id*" $location] } {
            set d [acs::test::http -last_request $d $location]
            acs::test::reply_contains $d $folder_name
        } else {
            aa_error "file_storage::test::create_new_folder failed, bad response url : $location"
        }

        return $d
    }

    ad_proc -private ::file_storage::test::add_file_to_folder {
        -last_request:required
        folder_name
        file_name
        file_description
    } {
        Adds a file to a folder from the UI.
    } {
        set d [acs::test::follow_link -last_request $last_request -label {Add File}]
        #acs::test::reply_has_status_code $d 200
        #
        # "Add File" links to a redirect page file-upload-confirm...
        #
        acs::test::reply_has_status_code $d 302
        set location [::acs::test::get_url_from_location $d]
        set d [acs::test::http -last_request $d $location]

        set response [dict get $d body]
        set form [acs::test::get_form $response {//form[@id='file-add']}]

        # A 'real' simulation would actually upload a file via
        # multipart request, but this is enough for testing.
        set wfd [ad_opentmpfile tmpfile]
        puts $wfd 1234
        close $wfd

        aa_true "add form was returned" {[llength $form] > 2}
        set form_content [::acs::test::form_get_fields $form]
        dict set form_content title $file_name
        dict set form_content description $file_description
        set files [list \
                       [list \
                            file $tmpfile \
                            fieldname upload_file \
                            mime_type text/plain]]
        dict unset form_content upload_file
        set payload [util::http::post_payload \
                         -files $files \
                         -formvars_list $form_content]
        set body [dict get $payload payload]
        set headers [ns_set array [dict get $payload headers]]
        set d [acs::test::http \
                   -last_request $d \
                   -method POST \
                   -body $body \
                   -headers $headers \
                   [dict get $form @action]]
        acs::test::reply_has_status_code $d 302
        set location [::acs::test::get_url_from_location $d]

        if { [string match  "*\?folder*id*" $location] } {
            aa_log "location contains folder*id"
            set list_words [split $file_name /]
            set short_file_name [lindex $list_words end]

            set d [acs::test::http -last_request $d $location]
            acs::test::reply_contains $d $folder_name
        } else {
            aa_error "file_storage::test::add_file_to_folder failed, bad redirect url: '$location'"
        }

        return $d
    }

    ad_proc -private ::file_storage::test::delete_first_file {
        -last_request:required
        file_name
    } {
        Delete the current file via Web UI.
    } {

        #
        # Delete the first displayed file (current rather crude,
        # failure must be detectable from return code). Using a class
        # for the anchor in the bulk actions would be helpful
        #
        acs::test::dom_html root [dict get $last_request body] {
            #
            # We are looking for links of the following form
            #
            #    <a href="/file-storage/file-add?file_id=36962" title="Upload a new version">Neu</a>
            #
            # to obtain the instance and the object_id

            foreach a [$root selectNodes {//a[contains(@href,'file-add')]}] {
                set href1 [$a getAttribute href]
                #
                # make sure the match was not from a return_url
                #
                if {[regexp {^[^?]+[?]} $href1 match]} {
                    if {[string match *file-add* $match]} {
                        set href $href1
                        break
                    }
                }
            }
        }
        aa_log "Download link '$href'"

        regsub -all /file-add $href /delete href
        regsub -all file_id= $href object_id= href
        aa_log "Delete link '$href'"
        set d [acs::test::http -last_request $last_request? $href]
        acs::test::reply_has_status_code $d 200
        #
        # Get confirm form
        #
        set form [acs::test::get_form [dict get $d body] {//form[@id='delete_confirm']}]
        aa_true "delete confirm form was returned" {[llength $form] > 2}
        set d [::acs::test::form_reply -last_request $d -form $form]
        acs::test::reply_has_status_code $d 302

        return $d
    }


    ad_proc  -private ::file_storage::test::delete_current_folder {
        -last_request:required
    } {
        Delete the current folder via Web UI.
    } {
        #
        # Delete the current folder
        #
        set d [acs::test::follow_link -last_request $last_request -label {Delete this folder}]
        acs::test::reply_has_status_code $d 200
        set form [acs::test::get_form [dict get $d body] {//form[@id='folder-delete']}]
        aa_true "delete form was returned" {[llength $form] > 2}

        set d [::acs::test::form_reply -last_request $d -form $form \
                   -update [subst {
                       formbutton:ok "OK"
                       __refreshing_p 0
                   }]]

        acs::test::reply_has_status_code $d 302
        return $d
    }

    ad_proc -private ::file_storage::test::call_fs_page {-last_request} {
        Requests the file-storage page.
    } {
        set fs_page [aa_get_first_url -package_key file-storage]
        return [::acs::test::http -last_request $last_request $fs_page]
    }

    ad_proc -private ::file_storage::test::create_file { f_name }  {
        Creates a temporary file.
    } {
        # Create a temporary file
        set file_name "[ad_tmpdir]/$f_name.txt"
        exec [::util::which touch] $file_name
        exec [::util::which ls] / >> $file_name
        exec [::util::which chmod] 777 $file_name
        return $file_name
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
