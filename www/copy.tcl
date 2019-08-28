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

db_multirow -extend {copy_message} copy_objects get_copy_objects [subst {
      select fs.object_id, fs.name, fs.title, fs.parent_id,
      acs_permission.permission_p(fs.object_id, :user_id, 'read') as copy_p, fs.type
      from fs_objects fs
      where fs.object_id in ([template::util::tcl_to_sql_list $object_id])
	order by copy_p
}] {
    if {$copy_p} {
	set copy_message ""
	incr allowed_count
    } else {
	set copy_message [_ file-storage.Not_Allowed]
	incr not_allowed_count
    }
    if {$type eq "folder"} {
        lappend not_allowed_children $object_id
        # lappend not_allowed_parents $parent_id
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


    # Check for WRITE permission on each object to be copied.
    # DaveB: I think it should be DELETE instead of WRITE
    # but the existing file-copy page checks for WRITE
    set error_items [list]      
    template::multirow foreach copy_objects {
        db_transaction {
            # Allow to copy files into folders that already contain
            # one with the same name by appending a numeric suffix
            set suffix 1
            set orig_title $title
            set orig_name  $name
            while {[content::item::get_id_by_name \
                        -name $name \
                        -parent_id $folder_id] ne ""} {
                set title ${orig_title}-${suffix}
                # for name, put the suffix just before the extension,
                # so browser can keep guessing the correct filetype at
                # download
                set name_ext [file extension $name]
                set name [string range ${orig_name} 0 end-[string length $name_ext]]
                set name ${name}-${suffix}${name_ext}
                incr suffix
            }
            
            if {$type ne "folder" } {
                set file_rev_id [db_exec_plsql copy_item {}]
		callback fs::file_revision_new \
                    -package_id $package_id \
                    -file_id    $object_id \
                    -parent_id  $folder_id
            } else {
                db_exec_plsql copy_folder {}
            }
        } on_error {
            lappend error_items $name
	}
    }
     if {[llength $error_items]} {
	 set message "[_ file-storage.There_was_a_problem_copying_the_following_items]: [join $error_items ", "]"
     } else {
	 set message [_ file-storage.Selected_items_have_been_copied]
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
    db_multirow -extend {copy_url} folder_tree get_folder_tree {
        with recursive folder_tree (folder_id, parent_id, label, level_num, tree_sortkey) as (
            select cf.folder_id, cif.parent_id, cf.label, 0 as level_num, cast(cif.parent_id as text) as tree_sortkey
            from cr_folders cf, cr_items cif
            where cf.folder_id = :root_folder_id
              and cf.folder_id = cif.item_id
            and acs_permission.permission_p(cf.folder_id, :user_id, 'write')

            union all

            select cf.folder_id, cif.parent_id, cf.label, level_num + 1 as level_num, t.tree_sortkey || '|' || cif.parent_id as tree_sortkey
            from cr_folders cf, cr_items cif, folder_tree t
            where cif.parent_id = t.folder_id
              and cf.folder_id = cif.item_id
              and acs_permission.permission_p(cf.folder_id, :user_id, 'write')
       ) select folder_id, parent_id, label, level_num
           from folder_tree
          order by tree_sortkey asc, label asc
    } {
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
