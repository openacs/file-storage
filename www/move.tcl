ad_page_contract {

    Multiple move page.
    Supports any file-storage supported content_item
    Allows move of single or multiple items

    @author Dave Bauer dave@thedesignexperience.org
    
} -query {
    object_id:notnull,integer,multiple
    folder_id:integer,optional
    {return_url ""}
    {redirect_to_folder:boolean 0}
    {show_items:boolean 0}
}

set objects_to_move $object_id
set user_id [ad_conn user_id]

set allowed_count 0
set not_allowed_count 0

db_multirow -extend {move_message} move_objects get_move_objects "" {
    if {$move_p} {
	set move_message ""
	incr allowed_count
    } else {
	set move_message [_ file_storage.Not_Allowed]
	incr not_allowed_count
    }
  
}

set total_count [template::multirow size move_objects]

if {$not_allowed_count > 0} {
    set show_items 1
}

if {[info exists folder_id]} {
     permission::require_permission \
 	-party_id $user_id \
 	-object_id $folder_id \
 	-privilege "write"


    # check for WRTIE permission on each object to be moved
    # DaveB: I think it should be DELETE instead of WRITE
    # but the existing file-move page checks for WRITE
      
    template::multirow foreach move_objects {
 	db_exec_plsql move_item {}
     }

     ad_returnredirect $return_url
     ad_script_abort

 } else {

    template::list::create \
	-name move_objects \
	-multirow move_objects \
	-elements {
	    name {label \#file-storage.Files_to_be_moved\#}
	    move_message {}
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
                link_url_col move_url
		link_html {title "\#file-storage.Move_to_folder_title\#"}
		display_template {<div style="text-indent: @folder_tree.level@em;">@folder_tree.label@</div>} 
            }
        }
    set root_folder_id [fs::get_root_folder]
    set object_id $objects_to_move
    db_multirow -extend {move_url} folder_tree get_folder_tree "" {
	set move_url [export_vars -base "move" { object_id:multiple folder_id return_url }]

	
    }

}

set context [list "\#file-storage.Move\#"]
set title "\#file-storage.Move\#"
