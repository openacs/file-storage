<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="blockers">      
      <querytext>
      
	select count(*) 
	from   cr_revisions
	where  item_id = :file_id
	and    acs_permission__permission_p(revision_id,:user_id,'delete') = 'f'

      </querytext>
</fullquery>

<fullquery name="delete_file">      
      <querytext>

        select file_storage__delete_file(:file_id);

      </querytext>
</fullquery>
 
</queryset>
