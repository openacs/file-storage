<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="file_name">      
      <querytext>
      
	begin
    		:1 := content_item.get_title(:file_id);
	end;

      </querytext>
</fullquery>

 
</queryset>
