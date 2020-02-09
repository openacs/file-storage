ad_library {
    Support functions for automated tests of file storage.

    @author Gustaf Neumann
}

namespace eval file_storage::test {

    ad_proc ::file_storage::test::create_new_folder {
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
        set location [::xowiki::test::get_url_from_location $d]

        if { [string match  "*/\?folder_id*" $location] } {
            set d [acs::test::http -last_request $d $location]
            acs::test::reply_contains $d $folder_name
        } else {
            aa_error "file_storage::test::create_new_folder failed, bad response url : $location"
        }

        return $d
    }

    ad_proc ::file_storage::test::edit_folder {
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
        set location [::xowiki::test::get_url_from_location $d]

        if { [string match  "*/\?folder_id*" $location] } {
            set d [acs::test::http -last_request $d $location]
            acs::test::reply_contains $d $folder_name
        } else {
            aa_error "file_storage::test::create_new_folder failed, bad response url : $location"
        }

        return $d
    }

    ad_proc ::file_storage::test::delete_current_folder {
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

        set d [::acs::test::form_reply -last_request $d -form $form]
        acs::test::reply_has_status_code $d 302
        return $d
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
