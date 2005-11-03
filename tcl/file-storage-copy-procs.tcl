ad_library {
    TCL library for the file-storage system (v.4)

    @author Luis de la Fuente (lfuente@it.uc3m.es)
    @creation-date 16 September 2005
}
 
ad_proc fs_folder_copy {
    {-old_folder_id:required}
    {-new_parent_id:required}
    {-also_subfolders_p "t"}
    {-also_files_p "t"}   
    {-mode: "both"}
} {
    Copy a folder and its subfolders and files, if selected.
} {

    switch $mode {
        "empty" { 
            set also_subfolders_p "f"
            set also_files_p "f"
        }
        "files" { 
            set also_subfolders_p "f"
            set also_files_p "t"
        }
        "subfolders" { 
            set also_subfolders_p "t"
            set also_files_p "f"
        }
        "both" { 
            set also_subfolders_p "t"
            set also_files_p "t"
        }
    }
#get data
    db_1row get_folder_data {}

#create forders  copy 
	set new_folder_id [fs::new_folder -name $pretty_name\
    -pretty_name $name -parent_id $new_parent_id -creation_user $creation_user -creation_ip $creation_ip  -description $description]

#copy containing files
    if {$also_files_p=="t"} {
        #get files list
        set file_list [db_list_of_lists get_file_list {}]
        set file_number [llength $file_list]
        ns_log Notice "listado de ficheros: $file_list"
        ns_log Notice "numero de ficheros a copiar: $file_number"

        #copy them
        for {set i 0} {$i < $file_number} {incr i} {
# Question - do we copy revisions or not?
# Current Answer - we copy the live revision only

            set file_id [lindex [lindex $file_list $i] 0]
            set user_id [lindex [lindex $file_list $i] 1]
            set ip_address [lindex [lindex $file_list $i] 2]

            ns_log Notice "file_id: $file_id"
            ns_log Notice "parent_id: $new_folder_id"
            ns_log Notice "user_id: $user_id"
            ns_log Notice "ip_address: $ip_address"
                
#            db_transaction {
#
                db_exec_plsql file_copy "
                begin
                    file_storage.copy_file(
                        item_id => :file_id
                        target_folder_id => :new_folder_id,
                        creation_user => :user_id,
                        creation_ip => :ip_address
                        );
                end;"

#            } on_error {

#                set folder_name "[_ file-storage.folder]"
#                set folder_link "<a href=\"index?folder_id=$parent_id\">$folder_name</a>"
#                ad_return_complaint 1 "[_ file-storage.lt_The_folder_link_you_s]"

##    <pre>$errmsg</pre>

#                ad_script_abort
#            }
        }
    }

    
#while there are more subfolders...
    if {$also_subfolders_p=="t"} {
        
        set subfolders_list [db_list get_subfolders_list {}]
        set subfolders_number [llength $subfolders_list]

        for {set i 0} {$i < $subfolders_number} {incr i} {

            set object_id [lindex $subfolders_list $i]

            fs_folder_copy -old_folder_id $object_id -new_parent_id $new_folder_id       
        }
    }

    
}



