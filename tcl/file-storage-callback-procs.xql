<?xml version="1.0"?>
<queryset>

<fullquery name="callback::datamanager::move_folder::impl::datamanager.get_working_package">
<querytext>
    select package_id 
    from dotlrn_community_applets 
    where applet_id=(select applet_id from dotlrn_applets where applet_key='dotlrn_fs') and community_id=:selected_community;
</querytext>
</fullquery>

<fullquery name="callback::datamanager::move_folder::impl::datamanager.update_cr_items">
<querytext>
    update cr_items
	set parent_id=:root_folder_id
    where item_id=:object_id
</querytext>
</fullquery>


<fullquery name="callback::datamanager::move_folder::impl::datamanager.update_acs_objects">
<querytext>
    update acs_objects
	set context_id =:root_folder_id
    where object_id=:object_id
</querytext>
</fullquery>

<fullquery name="callback::datamanager::delete_folder::impl::datamanager.del_update_cr_items">
<querytext>
    update cr_items
	set parent_id=:trash_id
    where item_id=:object_id
</querytext>
</fullquery>


<fullquery name="callback::datamanager::delete_folder::impl::datamanager.del_update_acs_objects">
<querytext>
    update acs_objects
	set context_id =:trash_id
    where object_id=:object_id
</querytext>
</fullquery>


</queryset>
