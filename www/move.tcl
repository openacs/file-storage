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
}

set user_id [ad_conn user_id]

if {[info exists folder_id]} {
     permission::require_permission \
 	-party_id $user_id \
 	-object_id $folder_id \
 	-privilege "write"

    # FIXME check READ permission on every item
     foreach one_item $object_id {
 	db_exec_plsql move_item {}
     }

     ad_returnredirect $return_url
     ad_script_abort

 } else {

    template::list::create \
        -name folder_tree \
        -pass_properties { item_id redirect_to_folder return_url } \
        -multirow folder_tree \
        -key folder_id \
        -elements {
            label {
                label "Folder"
                link_url_col move_url
		link_html {title "Move to @folder_tree.label@"}
		display_template {<div style="text-indent: @folder_tree.level@em;">@folder_tree.label@</div>} 
            }
        }
    set root_folder_id [fs::get_root_folder]
    db_multirow -extend {move_url} folder_tree get_folder_tree "" {
	set move_url [export_vars -base "move" { object_id:multiple folder_id return_url }]
	
    }

    set title "Move"

}

set context "Move Items"
set title "Move Items"
set file_name "FIX ME"