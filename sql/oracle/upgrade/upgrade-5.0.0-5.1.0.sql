-- 

-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2004-02-14
-- @cvs-id $Id$
--

declare

	cursor fs_item_cur is

	select r.item_id, r.revision_id, r.title, i.name, i.live_revision
            from cr_items i, cr_revisions r
	    where i.item_id=r.item_id
	    and i.live_revision=r.revision_id
	    and i.content_type='file_storage_object';
	
begin
	for item_row in fs_item_cur

	loop
	   fetch 
	   update cr_items set name=v_item_row.name
	        where item_id=v_item_row.item_id;

	   update cr_revisions set title=v_item_row.title
		where revision_id=v_item_row.revision_id;
	
	end loop;

end;
/
show errors



@@ ../file-storage-package-create.sql
