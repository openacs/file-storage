ad_page_contract {
    delete items
} {
    object_id:notnull,multiple
    {confirm_p:optional,boolean 0}
    {return_url ""}
}

set user_id [ad_conn user_id]

    template::list::create \
        -name delete_list \
        -multirow delete_list \
        -key fs_object_id \
        -no_data "No items selected" \
        -elements {
            name {
                label "\#file-storage.Name\#"
            }
            delete_message {
                label ""
            }
        }

set allowed_count 0
set not_allowed_count 0

# make sure none of these items are root folders. There is no way to
# click a checkbox, but who knows how the item_id might get in there
if {[llength $object_id] == 1} {
    set object_id [split [lindex $object_id 0]]
}
ns_log notice "
DB --------------------------------------------------------------------------------
DB DAVE debugging /var/lib/aolserver/openacs-5-1/packages/file-storage/www/delete.tcl
DB --------------------------------------------------------------------------------
DB object_id = '${object_id}'
DB llength object_id = '[llength $object_id]'
DB --------------------------------------------------------------------------------"

set root_folders_count [db_string count_root_folders "" -default 0]
if {$root_folders_count > 0} {
    ad_complain [_ file-storage.lt_You_may_not_delete_th]
    ad_script_abort
}

db_multirow -extend {delete_message} delete_list get_to_be_deleted "
                       select fs.object_id as fs_object_id, fs.name,
      acs_permission__permission_p(fs.object_id, :user_id, 'write') as delete_p
      from fs_objects fs
      where fs.object_id in ([template::util::tcl_to_sql_list $object_id])" {
	  if {$delete_p} {
	      set delete_message ""
	      incr allowed_count
	  } else {
	      set delete_message [_ file_storage.Not_Allowed]
	      incr not_allowed_count
	  }

      }

set total_count [template::multirow size delete_list]

set delete_inform [_ file-storage.lt_Do_you_want_to_delete]

ad_form -name delete_confirm -cancel_url $return_url -form {
    {notice:text(inform) {label ""} {value $delete_inform}}
    {return_url:text(hidden) {value $return_url}}
    {object_id:text(hidden) {value $object_id}}
}

ad_form -extend -name delete_confirm -on_submit {
    set object_id [split $object_id]
    db_transaction {
        template::multirow foreach delete_list {
            if {$delete_p} {
		db_exec_plsql delete_item ""
	    }
	}
    }
    ad_returnredirect $return_url
    ad_script_abort
}

set title "\#file-storage.Delete\#"
set context [list "\#file-storage.Delete\#"]

   
