<?xml version="1.0" ?>

<queryset>

  <fullquery name="file_info">      
    <querytext>
      
      select cr.title
      from   cr_revisions cr, cr_items ci
      where  ci.item_id = :file_id
         and cr.revision_id = ci.live_revision

    </querytext>
  </fullquery>

 
<fullquery name="edit_title">
    <querytext>
        update cr_revisions set title=:title
	where revision_id=(select live_revision from cr_items
                           where item_id=:file_id)
    </querytext>
</fullquery>
</queryset>
