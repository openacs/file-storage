ad_page_contract {
    page to add a new nonversioned object to the system

    @author Ben Adida (ben@openforce.net)    
    @author arjun (arjun@openforce.net)
    @creation-date 01 April 2002
    @cvs-id $Id$
} {
    folder_id:naturalnum,notnull
    {type "fs_url"}
    {title ""}
    {lock_title_p:boolean 0}
} -validate {
    valid_folder -requires {folder_id:integer} {
	if {![fs_folder_p $folder_id]} {
	    ad_complain "[_ file-storage.lt_The_specified_parent_]"
	}
    }
} -properties {
    folder_id:onevalue
    context:onevalue
}

# check for write permission on the folder

permission::require_permission -object_id $folder_id -privilege write

# set templating datasources

set pretty_name "URL"
if {$pretty_name eq ""} {
    return -code error "[_ file-storage.No_such_type]"
}

set context [fs_context_bar_list -final [_ file-storage.Add_pretty_name [list pretty_name $pretty_name]] $folder_id]

# Should probably generate the item_id and version_id now for
# double-click protection

# if title isn't passed in ignore lock_title_p
if {$title eq ""} {
    set lock_title_p 0
}

# Message lookup uses variable pretty_name
set page_title [_ file-storage.simple_add_page_title]


ad_form -export {folder_id type}

if {$lock_title_p} {
    ad_form -extend -form {
        {title_display:text(inform) {label \#file-storage.Title\#} }
        {title:text(hidden) {value $title}}
    }
} else {
    ad_form -extend -form {
        {title:text {label \#file-storage.Title\#} {html {size 30}} }
    }
}

set submit_label [_ file-storage.Create]

ad_form -extend -form {
    {url:text(text) {label \#file-storage.URL\#} {value "http://"}}
    {description:text(textarea),optional {html {rows 5 cols 50}} {label \#file-storage.Description\#}}
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
    category::ad_form::add_widgets \
	 -container_object_id $package_id \
	 -categorized_object_id $folder_id \
	 -form_name simple-add
}

ad_form -extend -form {
    {submit:text(submit) {label $submit_label}}
} -on_request {
} -on_submit {
    set item_id [content::extlink::new -url $url -label $title -description $description -parent_id $folder_id]

    # Analogous as for files (see file-add-2) we know the user has write permission to this folder, 
    # but they may not have admin privileges.
    # They should always be able to admin their own url (item) by default, so they can delete it, control
    # who can read it, etc.
    
    if { [string is false [permission::permission_p -party_id $user_id -object_id $folder_id -privilege admin]] } {
	permission::grant -party_id $user_id -object_id $item_id -privilege admin
    }

    if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
	category::map_object -remove_old -object_id $item_id [category::ad_form::get_categories \
								       -container_object_id $package_id \
								       -element_name category_id]
    }


    fs::do_notifications -folder_id $folder_id -filename $url -item_id $item_id -action "new_url"

} -after_submit {

    ad_returnredirect "?folder_id=$folder_id"

}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
