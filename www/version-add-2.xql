<?xml version="1.0"?>
<queryset>

<fullquery name="parent_folder">      
      <querytext>
	
	select parent_id as parent_folder
        from cr_items where item_id =  (select item_id from cr_revisions 
        where cr_revisions.revision_id = :version_id)
    
      </querytext>
</fullquery>
 
</queryset>
