<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="version_delete">      
      <querytext>
      
    begin
        if :version_id = content_item.get_live_revision(:item_id) then
            content_revision.delete (:version_id);
            content_item.set_live_revision(content_item.get_latest_revision(:item_id));
        else
            content_revision.delete (:version_id);
        end if;
    end;

      </querytext>
</fullquery>

 
</queryset>
