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

<fullquery name="delete_file">      
      <querytext>

	begin
        	file_storage.delete_file(:file_id);
	end;

      </querytext>
</fullquery>
 
 
</queryset>
