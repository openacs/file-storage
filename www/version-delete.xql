<?xml version="1.0"?>
<queryset>

<fullquery name="item_select">      
      <querytext>
      
	select item_id
	from   cr_revisions
	where  revision_id = :version_id

      </querytext>
</fullquery>

<fullquery name="version_name">      
      <querytext>
      
    	select i.name as title, r.title as version_name 
	from cr_items i, cr_revisions r
	where i.item_id = r.item_id
	and r.revision_id = :version_id

      </querytext>
</fullquery>

</queryset>
