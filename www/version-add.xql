<?xml version="1.0"?>
<queryset>

<fullquery name="file_name">      
      <querytext>
      
	select title as name
	from   cr_revisions
	where  revision_id = (select live_revision
                      	      from   cr_items
                      	      where  item_id = :file_id)

      </querytext>
</fullquery>

 
</queryset>
