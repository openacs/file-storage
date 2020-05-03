ad_include_contract {

    Shows a list of links from a file-storage folder.

    @param base_url URL to prepend to the relative URL from file-storage
                used to deliver content from another index.vuh than
                file-storage/view/
    @param object_list restrict results to object_ids in object_list
    @param show_all_p include subfolders and contents?
    @param admin_p show links to properties page for a file?
    @param return_url URL to add to admin links
    @param permission_check check read permissions for the user on the
    folder only (true) or on every record (false)

    apisano 2019-03-15: this include is currently referenced only by
    folder-admin, which in turn is currently used only by
    dotlrn-ecommerce.
} {
    {base_url:localurl "/view/"}
    {object_list:integer,multiple ""}
    {show_all_p:boolean false}
    {admin_p:boolean false}
    {return_url:localurl "[ad_return_url]"}
    {permission_check:boolean true}
}

set object_list_where ""

set viewing_user_id [ad_conn user_id]
if {!$permission_check} {
    set permission_p 1
    set permission_clause {and acs_permission.permission_p(fs_objects.object_id, :viewing_user_id, 'read')}
} else {
    set permission_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "read"]
    set permission_clause ""
}

set folder_name [lang::util::localize [fs::get_object_name -object_id  $folder_id]]

lassign [fs::get_folder_package_and_root $folder_id]  package_id root_folder_id

set fs_url [site_node::get_url_from_object_id -object_id $package_id]
if {$root_folder_id ne $folder_id && "/view/" eq $base_url} {
    set folder_path [content::item::get_path -item_id $folder_id -root_folder_id $root_folder_id]
} else {
    set folder_path ""
}

if {[llength $object_list] > 0} {
    set object_list_where " and fs_objects.object_id in ([ns_dbquotelist $object_list])"
}

db_multirow -extend {
    edit_url icon last_modified_pretty content_size_pretty properties_link
    properties_url download_url target_tag
} contents select_folder_contents {} {
    set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]

    set last_modified_pretty [lc_time_fmt $last_modified_ansi "%x %X"]
    #    if {$description ne ""} {
    #        set description " - $description"
    #    }

    if {$type eq "folder"} {
        set content_size_pretty [lc_numeric $content_size]
        append content_size_pretty " [_ file-storage.items]"
        set pretty_type "Folder"
    } else {
        set content_size_pretty [lc_content_size_pretty -size $content_size]
    }

    set name [lang::util::localize $name]

    if {![info exists download_base_url] } {
        set download_base_url ""
    }
    switch -- $type {
        folder {
            set properties_link ""
            set properties_url ""
            set icon ""
            set file_url ""
            set download_url ""
        }
        url {
            set properties_link "properties"
            set properties_url [export_vars -base ${fs_url}simple {object_id return_url}]
            set icon "/resources/acs-subsite/url-button.gif"
            set file_url ${url}
            set download_url $file_url
        }
        default {

            set properties_link [_ file-storage.properties]
            set properties_url [export_vars -base ${fs_url}file {{file_id $object_id} return_url}]
            set icon "/resources/file-storage/file.gif"
            set file_url "${base_url}${file_url}"
            set download_url [export_vars -base ${fs_url}download {{file_id $object_id}}]
        }
    }


    # We need to encode the hashes in any i18n message keys (.LRN plays this trick on some of its folders).
    # If we don't, the hashes will cause the path to be chopped off (by ns_conn url) at the leftmost hash.
    regsub -all {\#} $file_url {%23} file_url
}

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
