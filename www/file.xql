<?xml version="1.0"?>
<queryset>

<fullquery name="get_folder">      
      <querytext>
	select content_item.get_parent_folder(:file_id)
	from dual
      </querytext>
</fullquery>
 
</queryset>
