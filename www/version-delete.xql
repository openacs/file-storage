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
      
    	select title 
	from cr_revisions 
	where revision_id = :version_id

      </querytext>
</fullquery>

</queryset>
