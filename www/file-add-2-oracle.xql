<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="item_add">      
      <querytext>
      
	begin
    		:1 := content_item.new (
        		name => :filename,
        		parent_id => :folder_id,
        		context_id => :folder_id,
        		creation_user => :user_id,
        		creation_ip => :creation_ip
   			);
	end;

      </querytext>
</fullquery>

 
<fullquery name="revision_add">      
      <querytext>
      
	begin
    		:1 := content_revision.new (
        		title => :title,
        		description => :description,
        		mime_type => :mime_type,
        		item_id => :item_id,
        		creation_user => :user_id,
        		creation_ip => :creation_ip
    			);

	end;

      </querytext>
</fullquery>

 
<fullquery name="content_add">      
      <querytext>
      
	update cr_revisions
	set    content = empty_blob()
	where  revision_id = :revision_id
	returning content into :1

      </querytext>
</fullquery>

 
<fullquery name="make_live">      
      <querytext>
      
begin
    content_item.set_live_revision(:revision_id);
end;
      </querytext>
</fullquery>

 
</queryset>
