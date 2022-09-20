ad_library {

    Procedures for DAV service contract implementations

    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2003-11-09
    @cvs-id $Id$

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
