ad_library {
    TCL library for the file-storage system (v.4)
    extensions for non-versioned (simple) items

    @author Ben Adida (ben@openforce.net)
    @creation-date 01 April 2002
    @cvs-id $Id$
}
 
namespace eval fs {

    ad_proc -public simple_get_types {} {
        return {
            {fs_url "url"}
        }
    }

    ad_proc -public simple_get_type_pretty_name {
        {-type:required}
    } {
        set lst [simple_get_types]
        foreach item $lst {
            if {$type == [lindex $item 0]} {
                return [lindex $item 1]
            }
        }

        return ""
    }

    ad_proc -public url_new {
        {-url_id ""}
        {-name:required}
        {-description ""}
        {-url:required}
        {-folder_id:required}
    } {
        Create a new URL
    } {
        # Context
        set context_id $folder_id

        set extra_vars [ns_set create]
        oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list {url_id name url folder_id description context_id}

        # Instantiate and return
        set url_id [package_instantiate_object -extra_vars $extra_vars fs_url]
        return $url_id
    }

    ad_proc -public url_edit {
        {-url_id:required}
        {-name:required}
        {-description ""}
        {-url:required}
    } {
        # Perform the update
        db_transaction {
            db_dml update_simple {}
            db_dml update_url {}
        }
    }

    ad_proc -public simple_object_move {
        {-object_id:required}
        {-folder_id:required}
    } {
        # Update the location
        db_dml update_folder{}
    }

    ad_proc -public simple_delete {
        {-object_id:required}
    } {
        # delete the item
        db_exec_plsql delete_item {}
    }

    ad_proc -public simple_p {
        {-object_id:required}
    } {
        # is this thing a simple fs object?
        return [db_string simple_check {}]
    }
    ad_proc -public url_copy {
        {-url_id:required}
        {-target_folder_id:required}
    } {
        # is this thing a simple fs object?
        return [db_exec_plsql copy {}]
    }

}
