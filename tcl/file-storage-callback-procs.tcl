# packages/file-storage/tcl/file-storage-callback-procs.tcl

ad_library {
    
    Callback procs for file storage
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-15
    @arch-tag: 921a2c2a-5593-495b-9a60-9d815d80a39d
    @cvs-id $Id$
}

namespace eval fs::folder_chunk {}

# Define file storage callbacks

ad_proc -public -callback fs::folder_chunk::add_bulk_actions {
    {-bulk_variable:required}
    {-folder_id:required}
    {-var_export_list:required}
} {
}

ad_proc -public -callback fs::file_delete {
    {-package_id:required}
    {-file_id:required}
} {
    Callback executed right before the file is deleted
    This should make sure that any foreign key constraints to the file are removed
} -


ad_proc -public -callback fs::before_file_new {
    {-package_id:required}
    {-folder_id:required}
    {-cancel_url:required}
    {-return_url:required}
} {
    this can be used to check for confirmation before upload to folder
} -

ad_proc -public -callback fs::file_new {
    {-package_id:required}
    {-file_id:required}
} {
}

ad_proc -public -callback fs::file_revision_new {
    {-package_id:required}
    {-file_id:required}
    {-parent_id:required}
} {
}


# Our callback implementations

ad_proc -public -callback search::datasource -impl file_storage_object {} {

    @author Dirk Gomez (openacs@dirkgomez.de)
    @author Jowell S. Sabino (jowellsabino@netscape.net)
    @creation_date 2005-06-13

    returns a datasource for the search package
    this is the content that will be indexed by the full text
    search engine.

} {
    # We probably don't need the whole big query here. TODO: Review.
    db_0or1row fs_datasource {
	select r.revision_id as object_id,
	       i.name as title,
	       case i.storage_type
		     when 'lob' then r.lob::text
		     when 'file' then '[cr_fs_path]' || r.content
	             else r.content
	        end as content,
	        r.mime_type as mime,
	        '' as keywords,
	        i.storage_type as storage_type
	from cr_items i, cr_revisions r
	where r.item_id = i.item_id
	and   r.revision_id = :object_id
    } -column_array datasource

    # retrieve the file-storage file
    set file_content [cr_write_content -string -revision_id $object_id ]

    # and convert the file to text. Currently using a very poor man's
    # INSO filter (==strings).

    # Also file creation might be implemented too poorly - e.g. there
    # are probably platforms which do not have /tmp.  I think there is
    # no need to muck around with highly temporary filenames
    # though. The revision_id (passed in in the variable object_id) is
    # unique anyway.

    set filename "/tmp/search$object_id"
    set fileId [open $filename "w"]
    puts -nonewline $fileId $file_content
    close $fileId

    # TODO: replace strings with a procedure.
    set text_file_content [exec strings $filename ]

    file delete $filename

    return [list object_id $object_id \
                title datasource(title) \
                content $text_file_content \
                keywords {} \
                storage_type text \
                mime text/plain ]
}


ad_proc -public -callback datamanager::copy_folder -impl datamanager {
     -object_id:required
     -selected_community:required
     {-mode: "both"}
} {
    Copy a folder to another class or community
} {
#get the destiny's root folder
    set parent_id [dotlrn_fs::get_community_root_folder -community_id $selected_community]
    set new_folder_id [fs_folder_copy -old_folder_id $object_id -new_parent_id $parent_id -mode $mode]

    return $new_folder_id
    
}

ad_proc -public -callback fs::folder_new {
    {-package_id:required}
    {-folder_id:required}
} {
}

ad_proc -public -callback pm::project_new -impl file_storage {
    {-package_id:required}
    {-project_id:required}
} {
    create a new folder for each new project
} {
    set pm_name [pm::project::name -project_item_id $project_id]

    foreach fs_package_id [application_link::get_linked -from_package_id $package_id -to_package_key "file-storage"] {
	set root_folder_id [fs::get_root_folder -package_id $fs_package_id]

	set folder_id [fs::new_folder \
			   -name $root_folder_id \
			   -pretty_name $pm_name \
			   -parent_id $root_folder_id \
			   -no_callback]

	application_data_link::new -this_object_id $project_id -target_object_id $folder_id
    }
}

#Callbacks for application-track

ad_proc -callback application-track::getApplicationName -impl file_storage {} { 
        callback implementation 
    } {
        return "file_storage"		
    }    

    ad_proc -callback application-track::getGeneralInfo -impl file_storage {} { 
        callback implementation 
    } {
    
	db_1row my_query {
		select count(1) as result
			from acs_objects a, acs_objects b
        		where b.object_id = :comm_id
			and a.tree_sortkey between b.tree_sortkey
        		and tree_right(b.tree_sortkey)       
			and a.object_type = 'file_storage_object'
		}
			
	
	return "$result"
    } 

    ad_proc -callback application-track::getSpecificInfo -impl file_storage {} { 
        callback implementation 
    } {
   	
	upvar $query_name my_query	
	upvar $elements_name my_elements
	
	set my_query {
	
	SELECT f.name as name, f.file_id, f.type as type, f.content_size as size,
              fo.name as folder_name,
		       to_char(f.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified,
		       to_char(o.creation_date, 'YYYY-MM-DD HH24:MI:SS') as creation_date,
		       (select site_node__url(site_nodes.node_id)
                       from site_nodes, acs_objects
                       where site_nodes.object_id = file_storage__get_package_id(f.parent_id) and acs_objects.object_id = f.file_id) as url,
                       com.community_id as class_id
                FROM fs_files f,fs_folders fo,dotlrn_communities_full com,acs_objects o, acs_objects o2
		WHERE f.file_id = o.object_id
        and com.community_id=:class_instance_id
		      and o2.object_id= file_storage__get_package_id(f.parent_id)
		      and o2.context_id=com.package_id
		      and fo.folder_id = f.parent_id
		      
		      }
	      
      		      
	set my_elements {
    		name {
	            label "Name"
                    display_col name                    
	 	    html {align center}	 	    
	 	              
	        }
	        type {
	            label "Type"
	            display_col type 	              	              
	 	    html {align center}	 	    
	 	                 
	        }
	        folder {
	            label "Folder"
	            display_col folder_name 	              	              
	 	    html {align center}	 	
	        }
	        size {
	            label "Size (bytes)"
	            display_col size
	 	    html {align center}	 	         
	 	          
	        }
	        last_modification_date {
	            label "Last_Modification_Date"
	            display_col last_modified 
	 	    html {align center}	 	      
	 	}
	        post_date {
	            label "Post_Date"
	            display_col creation_date
	 	    html {align center}    
	 	         
	        }	                  
	        
	}
	
	
    }      
