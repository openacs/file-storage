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

<fullquery name="fs::simple_p.simple_check">      
<querytext>
select case when count(*) = 0 then 0 else 1 end
from fs_simple_objects
where object_id = :object_id
</querytext>
</fullquery>

</queryset>
