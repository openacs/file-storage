<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="template_root">      
      <querytext>

      select content_template__get_root_folder()

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
			       and parent_id = (select item_id
						from cr_items
						where name = :item_url_parent_folder))
	    order by revision_id desc
	    limit 1

      </querytext>
</fullquery>

 
</queryset>
