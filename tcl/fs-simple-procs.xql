<?xml version="1.0"?>
<queryset>

<fullquery name="fs::url_edit.update_simple">      
<querytext>
update fs_simple_objects set
name= :name,
description= :description
where object_id= :url_id
</querytext>
</fullquery>

<fullquery name="fs::url_edit.update_url">      
<querytext>
update fs_urls set
url= :url
where url_id= :url_id
</querytext>
</fullquery>

<fullquery name="fs::simple_object_move.update_folder">      
<querytext>
update fs_simple_objects set
folder_id= :folder_id
where url_id= :url_id
</querytext>
</fullquery>

</queryset>
