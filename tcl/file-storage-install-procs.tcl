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
    set url [apm_required_attribute_value $node url]
    set name [apm_required_attribute_value $node name]
    set pretty_name [apm_required_attribute_value $node pretty-name]

    set package_id [site_node::get_element -url $url -element package_id]

    set root [fs::get_root_folder -package_id $package_id]

    fs::new_folder -name $name -pretty_name $pretty_name -parent_id $root -creation_user 0 -creation_ip 127.0.0.1
}
