<?xml version="1.0"?>
<queryset>

<fullquery name="extlink_data">      
      <querytext>
         select name, url, description, folder_id
         from fs_urls_full
         where url_id= :object_id
      </querytext>
</fullquery>
 
</queryset>
