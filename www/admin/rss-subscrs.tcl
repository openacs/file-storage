ad_page_contract {

    List existing RSS requests for this folder and offer a link to create a
    new one.

} {
    folder_id:notnull,naturalnum
    rebuild_subscr_id:optional,naturalnum
}

set folder_name [fs_get_folder_name $folder_id]

if { [info exists rebuild_subscr_id] } {
    #Extra security check
    db_1row select_rebuild_folder {}
    permission::require_permission -object_id $rebuild_folder_id -privilege admin

    #Looks okay, regen the feed.
    rss_gen_report $rebuild_subscr_id
}

template::list::create \
    -name subscrs \
    -multirow subscrs \
    -row_pretty_plural {feeds} \
    -elements {
	short_name {
	    label {Short name}
	}
	xmlurl {
	    html {align center}
	    label {XML URL}
	    display_template {<a href="../rss/@subscrs.subscr_id@/rss.xml">XML</a>}
	}
	actions {
	    label {Actions}
	    display_template {<a href="rss-subscr-ae?subscr_id=@subscrs.subscr_id@&folder_id=@subscrs.folder_id@">edit</a> | <a href="rss-subscrs?rebuild_subscr_id=@subscrs.subscr_id@&folder_id=@subscrs.folder_id@">rebuild</a> | <a href="rss-subscr-del?subscr_id=@subscrs.subscr_id@">delete</a>}
	}
    }

db_multirow subscrs select_subscrs {}

set root_folder_id [fs_get_root_folder]
set context [fs_context_bar_list -root_folder_id $root_folder_id $folder_id]