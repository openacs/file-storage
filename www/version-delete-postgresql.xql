<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="version_delete">      
      <querytext>
	
	begin

        	if :version_id = content_item__get_live_revision(:item_id)
		then
            		PERFORM content_revision__delete(:version_id);
            		PERFORM content_item__set_live_revision(content_item__get_latest_revision(:item_id));
        	else
            		PERFORM content_revision__delete(:version_id);
        	end if;

		return 0;
	end;

      </querytext>
</fullquery>

<fullquery name="delete_item">      
      <querytext>

	select content_item__delete(:item_id);

      </querytext>
</fullquery>
 
</queryset>

