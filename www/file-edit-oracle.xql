<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="file_info">      
      <querytext>
      
	select title
	from   cr_revisions, cr_items
	where  cr_items.item_id = :file_id
	and revision_id=live_revision

      </querytext>
</fullquery>

 
</queryset>
