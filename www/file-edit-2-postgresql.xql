<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="rename_file">      
      <querytext>

    	select file_storage__rename_file (
        	:file_id, -- file_id
        	:title	  -- title
    		);

      </querytext>
</fullquery>

 
<fullquery name="duplicate_check">      
      <querytext>
      
    	select count(*)
    	from   cr_items
    	where  name = :title
    	and    parent_id = content_item__get_parent_folder(:file_id)

      </querytext>
</fullquery>

 
</queryset>
