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

 
<fullquery name="rename_file">      
      <querytext>
      
	begin
    		file_storage.rename_file (
        		file_id => :file_id,
        		title => :title
    			);
	end;

      </querytext>
</fullquery>

 
<fullquery name="duplicate_check">      
      <querytext>
      
    	select count(*)
    	from   cr_items
    	where  name = :title
    	and    parent_id = content_item.get_parent_folder(:file_id)

      </querytext>
</fullquery>


</queryset>
