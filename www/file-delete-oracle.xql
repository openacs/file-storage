<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="blockers">      
      <querytext>
      
	select count(*) 
	from   cr_revisions
	where  item_id = :file_id
	and    acs_permission.permission_p(revision_id,:user_id,'delete') = 'f'

      </querytext>
</fullquery>

<fullquery name="file_delete">      
      <querytext>

	begin
        	content_item.delete(:file_id);
	end;

      </querytext>
</fullquery>
 
<fullquery name="file_name">      
      <querytext>
      
    	select title as file_name 
    	from   cr_revisions 
    	where  revision_id = content_item.get_live_revision(:file_id)

      </querytext>
</fullquery>

 
</queryset>
