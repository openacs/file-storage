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

<fullquery name="file_delete">      
      <querytext>

        select content_item__delete(:file_id);

      </querytext>
</fullquery>
 
<fullquery name="file_name">      
      <querytext>
      
    	select title as file_name 
    	from   cr_revisions 
    	where  revision_id = content_item__get_live_revision(:file_id)

      </querytext>
</fullquery>

 
</queryset>
