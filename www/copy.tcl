ad_page_contract {

    Multiple copy page.
    Supports any file-storage supported content_item
    Allows copy of single or multiple items

    @author Dave Bauer dave@thedesignexperience.org
    
} -query {
    object_id:notnull,integer,multiple
    folder_id:naturalnum,optional
    {return_url:localurl ""}
    {root_folder_id:integer ""}
    {redirect_to_folder:boolean 0}
    {show_items:boolean 0}
} -errors {object_id:,notnull,integer,multiple {Please select at least one item to copy.}
}

set objects_to_copy $object_id
set object_id_list [join $object_id ","]

set user_id [ad_conn user_id]
set peer_addr [ad_conn peeraddr]
set allowed_count 0
set not_allowed_count 0
set package_id [ad_conn package_id]
set not_allowed_parents [list]
set not_allowed_children [list]

db_multirow -extend {copy_message} copy_objects get_copy_objects "" {
    if {$copy_p} {
	set copy_message ""
	incr allowed_count
    } else {
	set copy_message [_ file-storage.Not_Allowed]
	incr not_allowed_count
    }
    if {$type eq "folder"} {
        lappend not_allowed_children $object_id
        lappend not_allowed_parents $parent_id
    }
  
}

set total_count [template::multirow size copy_objects]

if {$not_allowed_count > 0} {
    set show_items 1
}

if {[info exists folder_id]} {
     permission::require_permission \
 	-party_id $user_id \
 	-object_id $folder_id \
 	-privilege "write"


    # check for WRTIE permission on each object to be copyd
    # DaveB: I think it should be DELETE instead of WRITE
    # but the existing file-copy page checks for WRITE
     set error_items [list]      
    template::multirow foreach copy_objects {
        db_transaction {
            if {$type ne "folder" } {
                set file_rev_id [db_exec_plsql copy_item {}]
		callback fs::file_revision_new -package_id $package_id -file_id $object_id -parent_id $folder_id
            } else {
                db_exec_plsql copy_folder {}
            }
        } on_error {
	    lappend error_items $name
	}
    }
     if {[llength $error_items]} {
	 set message "There was a problem copying the following items: [join $error_items ", "]"
     } else {
	 set message "Selected items copied."
     }
     ad_returnredirect -message $message $return_url
     ad_script_abort

 } else {

    template::list::create \
	-name copy_objects \
	-multirow copy_objects \
	-elements {
	    name {label \#file-storage.Files_to_be_copied\#}
	    copy_message {}
	}
    
    template::list::create \
        -name folder_tree \
        -pass_properties { item_id redirect_to_folder return_url } \
        -multirow folder_tree \
        -key folder_id \
        -no_data [_ file-storage.No_valid_destination_folders_exist] \
        -elements {
            label {
                label "\#file-storage.Choose_Destination_Folder\#"
                display_template {
                    <if @folder_tree.copy_url@ nil>
                    <div style="padding-left: @folder_tree.level_num@em;">@folder_tree.label@</div>
                    </if><else>@folder_tree.label@</else>
                }
                link_url_col copy_url
                link_html {title "\#file-storage.Copy_to_folder_title\#" style "padding-left: @folder_tree.level_num@em;"}
            }
        }

    if {$root_folder_id eq ""} {
	set root_folder_id [fs::get_root_folder]
    }
    set object_id $objects_to_copy
    set cancel_url "[ad_conn url]?[ad_conn query]"
    db_multirow -extend {copy_url} folder_tree get_folder_tree "" {
        if {$folder_id in [concat $not_allowed_parents $not_allowed_children] 
	    || $parent_id in $not_allowed_children
	} {
            if {$parent_id in $not_allowed_children} {
                lappend not_allowed_children $folder_id
            }
            set copy_url ""
        } else {
            set target_url [export_vars -base "[ad_conn package_url]copy" { object_id:multiple folder_id return_url }]
            set copy_url [export_vars -base "file-upload-confirm" {folder_id cancel_url {return_url $target_url}}]
        }
    }
    
}

set context [list "\#file-storage.Copy\#"]
set title "\#file-storage.Copy\#"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
