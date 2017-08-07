<?xml version="1.0"?>
<queryset>

<fullquery name="get_file">      

    <querytext>
	select title, description from cr_revisions,cr_items 
	where cr_items.item_id=:file_id and revision_id=live_revision
    </querytext>

</fullquery>

</queryset>
