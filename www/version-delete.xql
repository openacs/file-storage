<?xml version="1.0"?>
<queryset>

<fullquery name="item_select">      
      <querytext>
      
	select item_id
	from   cr_revisions
	where  revision_id = :version_id

      </querytext>
</fullquery>

<fullquery name="deleted_last_revision">      
      <querytext>
        
	select (case when live_revision = null
                     then 1
                     else 0
                end) 
        from cr_items
        where item_id = :item_id

      </querytext>
</fullquery>

<fullquery name="parent_folder">      
      <querytext>

	select parent_id from cr_items where item_id = :item_id

      </querytext>
</fullquery>
 
<fullquery name="version_name">      
      <querytext>
      
    	select title 
	from cr_revisions 
	where revision_id = :version_id

      </querytext>
</fullquery>

</queryset>
