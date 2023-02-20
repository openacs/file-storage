ad_library {

    Procedures for DAV service contract implementations

    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2003-11-09
    @cvs-id $Id$

}

namespace eval fs::dav {}

ad_proc -private fs::dav::require {} {
    oacs-dav used to be a requirement for file-storage. We now made
    this optional, with the caveat that some operations need to happen
    only depending if the package is there or not.
} {
    if { ![apm_package_installed_p oacs-dav] } {
        #
        # Delete the Service Contract implementation if they existed.
        #
        fs::install::unregister_implementation

        if { [db_table_exists dav_site_node_folder_map] } {
            #
            # oacs-dav registers folders for access after mount. We remove
            # this registration.
            #
            db_dml unregister_folders {
                delete from dav_site_node_folder_map
                where folder_id in (select folder_id from fs_root_folders)
            }
        }

        #
        # We do not need to define the DAV callbacks, exit now.
        #
        return

    } elseif { ![db_0or1row implementation_exists {
        select 1 from acs_sc_impls
         where impl_owner_name = 'file-storage'
           and impl_contract_name = 'dav'
         fetch first 1 rows only
    }] } {
        #
        # Check at load time whether the Service Contract implementations
        # exist and register them on the fly in case.
        #
        fs::install::register_implementation

        #
        # Map the root folder of all mounted file-storage instances. Do
        # not do anything if the DAV folders table has already tuples.
        #
        db_dml register_folders {
            insert into dav_site_node_folder_map
            select n.node_id, f.folder_id, true as enabled_p
            from fs_root_folders f,
                 site_nodes n
            where n.object_id = f.package_id
              and not exists (select 1 from dav_site_node_folder_map)
        }
    }
}

if { ![apm_package_installed_p oacs-dav] } {
    ns_log notice "oacs-dav not installed, fs::impl::fs_object callbacks won't be loaded"
    return
}

namespace eval fs::impl::fs_object {}

ad_proc -private fs::impl::fs_object::get {} {
    GET method
} {
    acs_sc::invoke \
        -contract dav \
        -operation get \
        -impl content_revision
}

ad_proc -private fs::impl::fs_object::head {} {
    HEAD method
} {
    acs_sc::invoke \
        -contract dav \
        -operation head \
        -impl content_revision
}

ad_proc -private fs::impl::fs_object::put {} {
    PUT method
} {
    set user_id [oacs_dav::conn user_id]
    set item_id [oacs_dav::conn item_id]
    set root_folder_id [oacs_dav::conn folder_id]
    set uri [oacs_dav::conn uri]

    if {"unlocked" ne [tdav::check_lock $uri] } {
	return [list 423]
    }

    set tmp_filename [oacs_dav::conn tmpfile]
    set tmp_size [ad_file size $tmp_filename]

    set name [oacs_dav::conn item_name]
    set parent_id [oacs_dav::item_parent_folder_id $uri]
    array set sn [site_node::get -url $uri]
    set package_id $sn(package_id)
    ns_log debug "\n ----- \n file_storage::dav::put package_id $package_id \n parent_id $parent_id \n uri $uri \n ----- \n "
    if {$parent_id eq ""} {
	set response [list 409]
	return $response
    }

    if {$item_id eq ""} {
        fs::add_file \
            -package_id $package_id \
            -name $name \
            -title $name \
            -item_id $item_id \
            -parent_id $parent_id \
            -tmp_filename $tmp_filename \
            -creation_user $user_id \
            -creation_ip [ad_conn peeraddr] \

	if {[file exists [tdav::get_lock_file $uri]]} {
	    # if there is a null lock use 204
	    set response [list 204]
	} else {
	    set response [list 201]
	}
    } else {
	fs::add_version \
	    -name $name\
            -title $name \
	    -tmp_filename $tmp_filename\
	    -item_id $item_id \
	    -creation_user $user_id \
	    -package_id $package_id

	set response [list 204]
    }
    file delete -- $tmp_filename
    return $response

}

ad_proc -private fs::impl::fs_object::propfind {} {
    PROPFIND method
} {
    acs_sc::invoke \
        -contract dav \
        -operation propfind \
        -impl content_revision
}

ad_proc -private fs::impl::fs_object::delete {} {
    DELETE method
} {
    acs_sc::invoke \
        -contract dav \
        -operation delete \
        -impl content_revision
}

ad_proc -private fs::impl::fs_object::mkcol {} {
    MKCOL method
} {
    set uri [oacs_dav::conn uri]
    set user_id [oacs_dav::conn user_id]
    set peer_addr [oacs_dav::conn peeraddr]
    set item_id [oacs_dav::conn item_id]
    set fname [oacs_dav::conn item_name]
    set parent_id [oacs_dav::item_parent_folder_id $uri]
    if {$parent_id eq ""} {
	return [list 409]
    }
    if { $item_id ne ""} {
	return [list 405]
    }

    if { [catch {
	fs::new_folder \
	    -name $fname \
	    -pretty_name $fname \
	    -parent_id $parent_id \
	    -creation_user $user_id \
	    -creation_ip $peer_addr \
        } ]} {
	return [list 500]
    }

    return [list 201]
}

ad_proc -private fs::impl::fs_object::proppatch {} {
    PROPPATCH method
} {
    acs_sc::invoke \
        -contract dav \
        -operation proppatch \
        -impl content_revision
}

ad_proc -private fs::impl::fs_object::copy {} {
    COPY method
} {
    acs_sc::invoke \
        -contract dav \
        -operation copy \
        -impl content_revision
}

ad_proc -private fs::impl::fs_object::move {} {
    MOVE method
} {
    acs_sc::invoke \
        -contract dav \
        -operation move \
        -impl content_revision
}


ad_proc -private fs::impl::fs_object::lock {} {
    LOCK method
} {
    acs_sc::invoke \
        -contract dav \
        -operation lock \
        -impl content_revision
}

ad_proc -private fs::impl::fs_object::unlock {} {
    UNLOCK method
} {
    acs_sc::invoke \
        -contract dav \
        -operation unlock \
        -impl content_revision
}

namespace eval fs::impl::dav_put_type {}

ad_proc -private fs::impl::dav_put_type::get_type {} {

} {
    return "file_storage_object"
}

namespace eval fs::impl::dav_mkcol_type {}

ad_proc -private fs::impl::dav_mkcol_type::get_type {} {

} {
    return "file_storage_object"
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
