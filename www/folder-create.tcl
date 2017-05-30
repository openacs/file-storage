ad_page_contract {
    form to create or edit a new folder

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 7 Nov 2000
    @author Caroline Meeks (caroline@meekshome.com)
    @creation-date 4 Jan 2004
    @cvs-id $Id$
} {
    parent_id:naturalnum,optional,notnull
    folder_id:naturalnum,optional,notnull
} -validate {
    file_id_or_folder_id {
	if { (![info exists folder_id] || $folder_id eq "") && (![info exists parent_id] || $parent_id eq "") } {
	    ad_complain "Input error: Must either have a parent_id or a folder_id"
	}
    }
    valid_folder -requires {parent_id:integer} {
	if {![fs_folder_p $parent_id]} {
	    ad_complain "[_ file-storage.lt_The_specified_parent_]"
	}
    }
} -properties {
    parent_id:onevalue
    folder_id:onevalue
    context:onevalue
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
# check that they have write permission on the parent folder or this folder if its an edit.
if { [info exists parent_id] && $parent_id ne "" } {
    permission::require_permission \
	    -object_id $parent_id \
	    -party_id $user_id \
	    -privilege "write"
}

if {![ad_form_new_p -key folder_id]} {
    #
    # editing an existing folder
    #
    permission::require_permission \
	    -object_id $folder_id \
	    -party_id $user_id \
	    -privilege "write"
    set context [fs_context_bar_list -final "[_ file-storage.Edit_Folder]" $folder_id]
} elseif {[info exists parent_id]} {
    #
    # adding a new folder
    #
    set context [fs_context_bar_list -final "[_ file-storage.Create_New_Folder]" $parent_id]
} else {
    ad_return_complaint 1 "invalid parent_id"
    ad_script_abort
}

ad_form -name "folder-ae" -html { enctype multipart/form-data } -export { parent_id } -form {
    folder_id:key
    {folder_name:text {label \#file-storage.Title\#} {html {size 30}} }
    {description:text(textarea),optional {label \#file-storage.Description\#} {html "rows 5 cols 35"}}
}

set package_id [ad_conn package_id]
if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
    if { [info exists folder_id] && $folder_id ne "" } {
	set categorized_object_id $folder_id
    } elseif { [info exists parent_id] && $parent_id ne "" } {
	set categorized_object_id $parent_id
    } else {
	set categorized_object_id ""
    }
    category::ad_form::add_widgets \
	 -container_object_id $package_id \
	 -categorized_object_id $categorized_object_id \
	 -form_name folder-ae
}

ad_form -extend -name "folder-ae" -edit_request {
    #For now I'm using the bCSM proc. We need to move it to somewhere its more accessible.
    #But I hope we can avoid repeating the code in 2 places.
#    array set folder [bcms::folder::get_folder -folder_id $folder_id]
# use a plain old query until this gets fixed in CR

    db_1row get_folder_info "" -array folder
    
    #Sigh, there seems to be no consitancy as to how name, title, label and pretty_name are used.

    # cr_folders.label is the pretty name
    # name is the url of the folder
    set folder_name $folder(label)
    set description $folder(description)
    set parent_id $folder(parent_id)

} -new_data {

    # strip out spaces from the name
    # use - instead of _ which can get URLencoded
    set name [string tolower [util_text_to_url -text $folder_name]]

    # check folder name does not exist already
    if {[content::item::get_id_by_name \
             -name $name -parent_id $parent_id] ne ""} {
        set folder_link [_ file-storage.folder]
        template::form::set_error folder-ae folder_name [_ file-storage.lt_The_folder_link_you_s]
        break
    }

    db_transaction {
	set folder_id [fs::new_folder \
	    -name $name \
	    -pretty_name $folder_name \
	    -parent_id $parent_id \
	    -creation_user [ad_conn user_id] \
	    -creation_ip [ad_conn peeraddr] \
	    -description $description]
    } on_error {
        ns_log error $errmsg
	ad_return_complaint 1 "[_ acs-subsite.lt_Heres_what_the_databa] $errmsg"
        ad_script_abort
    }

    if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
	category::map_object -remove_old -object_id $folder_id [category::ad_form::get_categories \
								       -container_object_id $package_id \
								       -element_name category_id]
    }

} -edit_data {
    
    db_transaction {
	fs::rename_folder -folder_id $folder_id -name $folder_name
	fs::set_folder_description -folder_id $folder_id -description $description
    }
    if { [parameter::get -parameter CategoriesP -package_id $package_id -default 0] } {
	category::map_object -remove_old -object_id $folder_id [category::ad_form::get_categories \
								       -container_object_id $package_id \
								       -element_name category_id]
    }
    
} -after_submit {   
    ad_returnredirect "?folder_id=$folder_id"
    ad_script_abort
}

ad_return_template


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
