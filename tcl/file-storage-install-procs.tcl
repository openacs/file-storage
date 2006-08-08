ad_library {
    
    Sets up WebDAV support service contracts
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2003-11-09
    @cvs-id $Id$
    
}


namespace eval fs::install {}

ad_proc -private fs::install::package_install {} {
    setup DAV service contracts
} {
    db_transaction {
	register_implementation
	fs::rss::create_rss_gen_subscr_impl
    }
}

ad_proc -private fs::install::package_uninstall {} {
    clean up for package uninstall
} {
    db_transaction {
	unregister_implementation
    }
}

ad_proc -private fs::install::after_instantiate {
    {-package_id:required}
} {
} {
    # using site_node name for root folder name
    # doesn't work in the case that multiple instances of
    # a node called "file-storage" for example, are mounted
    # all file storage root folders have parent_id=0 and
    # parent_id, name must be unique.

    # this isn't a problem in resolving URLs because we know which
    # root folder is associated with a site_node/package_id
    set instance_name [apm_instance_name_from_id $package_id]
    set folder_id [fs::new_root_folder \
		       -package_id $package_id \
		       -pretty_name $instance_name \
		       ]
}

ad_proc -private fs::install::before_uninstantiate {
    {-package_id:required}
} {
} {
    # TODO: make this clean up the root folder
}

ad_proc -private fs::install::register_implementation {
} {
    add file-storage repository service contract
    implementation
} {
    ns_log Notice "registering fs dav implementations."

    ### dav contract

    set spec {
        name "file_storage_object"
        aliases {
            get fs::impl::fs_object::get
            head fs::impl::fs_object::head	    
            put fs::impl::fs_object::put
	    propfind fs::impl::fs_object::propfind
	    delete fs::impl::fs_object::delete
	    mkcol fs::impl::fs_object::mkcol
	    proppatch fs::impl::fs_object::proppatch
	    copy fs::impl::fs_object::copy
	    move fs::impl::fs_object::move
	    lock fs::impl::fs_object::lock
	    unlock fs::impl::fs_object::unlock
        }
	contract_name {dav}
	owner "file-storage"
    }
    
    acs_sc::impl::new_from_spec -spec $spec

    ### dav_put_type

    set spec {
	name "file-storage"
	aliases {
	    get_type fs::impl::dav_put_type::get_type
	}
	contract_name {dav_put_type}
	owner "file-storage"
    }

    acs_sc::impl::new_from_spec -spec $spec

    set spec {
	name "file-storage"
	aliases {
	    get_type fs::impl::dav_mkcol_type::get_type
	}
	contract_name {dav_mkcol_type}
	owner "file-storage"
    }

    acs_sc::impl::new_from_spec -spec $spec
}

ad_proc -private fs::install::unregister_implementation {
} {
    remove file-storage service contract implementation
} {
    acs_sc::impl::delete -contract_name dav -impl_name file_storage_object
}

ad_proc -private fs::install::upgrade {
    -from_version_name
    -to_version_name
} {
    Install new DAV service contracts
} {
    apm_upgrade_logic \
	-from_version_name $from_version_name \
	-to_version_name $to_version_name \
	-spec {
	    4.6.2 5.1.1 {
		fs::install::package_install
		# delete the tcl file for the /view template created
		# by content::init so it can be recreated
		file delete [file join [acs_root_dir] templates "file-storage-default.tcl"]
	    }
	    5.1.0a10 5.1.0a11 {
		set spec {
		    name "file-storage"
		    aliases {
			get_type fs::impl::dav_mkcol_type::get_type
		    }
		    contract_name {dav_mkcol_type}
		    owner "file-storage"
		}
		acs_sc::impl::new_from_spec -spec $spec
	    }
            5.1.0a11 5.1.0a12 {
		fs::rss::create_rss_gen_subscr_impl
	    }
	}

}

ad_proc -private ::install::xml::action::file-storage-folder { node } {
    Create a file storage folder from install.xml
} {
    set name [apm_required_attribute_value $node name]
    set pretty_name [apm_required_attribute_value $node pretty-name]
    set id [apm_attribute_value -default "" $node id]

    set package_id [install::xml::object_id::package $node]

    set root [fs::get_root_folder -package_id $package_id]

    set folder_id [fs::new_folder -name $name -pretty_name $pretty_name -parent_id $root -creation_user [ad_conn user_id] -creation_ip 127.0.0.1]

    if {![string equal $id ""]} {
      set ::install::xml::ids($id) $folder_id
    }
}

ad_proc -public -callback fs::folder_new {
    {-package_id:required}
    {-folder_id:required}
} {
}

ad_proc -public -callback fs::folder_edit {
    {-package_id:required}
    {-folder_id:required}
} {
}

ad_proc -public -callback fs::folder_delete {
    {-package_id:required}
    {-folder_id:required}
} {
}

ad_proc -public -callback fs::file_new {
    {-package_id:required}
    {-file_id:required}
} {
}

ad_proc -public -callback fs::file_edit {
    {-package_id:required}
    {-file_id:required}
} {
}

ad_proc -public -callback fs::file_delete {
    {-package_id:required}
    {-file_id:required}
} {
}

ad_proc -public -callback pm::project_new -impl file_storage {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
} {
    create a new folder for each new project
} {
    set pm_name [pm::project::name -project_item_id $project_id]

    foreach fs_package_id [application_link::get_linked -from_package_id $package_id -to_package_key "file-storage"] {
	set root_folder_id [fs::get_root_folder -package_id $fs_package_id]

	set folder_id [fs::new_folder \
			   -name $project_id \
			   -pretty_name $pm_name \
			   -parent_id $root_folder_id \
			   -no_callback]

	application_data_link::new -this_object_id $project_id -target_object_id $folder_id
    }
}


