<?xml version="1.0"?>

<queryset>

<fullquery name="file_type">      
      <querytext>

	select mime_type 
	from   cr_revisions 
	where  revision_id = :version_id

      </querytext>
</fullquery>
 
</queryset>
