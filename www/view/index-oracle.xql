<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="template_root">      
      <querytext>

      select content_template.get_root_folder from dual

      </querytext>
</fullquery>

<fullquery name="upgraded_item_id">      
      <querytext>

	    select i.item_id
	    from cr_revisions r, cr_items i 
	    where r.item_id = i.item_id 
	    and r.title = :item_url_title 
	    and i.parent_id = (select item_id 
			       from cr_items 
			       where name = :item_url_folder
		 	       and rownum = 1) 
	    and rownum = 1
	    order by revision_id desc

      </querytext>
</fullquery>

 
</queryset>
