set serveroutput on size 200000

create or replace function tmp_fs_name_duplicate (
  v_name in cr_items.name%TYPE,
  v_count in integer
) return cr_items.name%TYPE
as
  v_insert_pos integer;
begin
  v_insert_pos := instr(v_name,'.',-1)-1;
  if v_insert_pos = -1 then
    return v_name || '.' || v_count;
  else
    return substr(v_name,1,v_insert_pos) || '.' || v_count || substr(v_name,v_insert_pos+1);
  end if;
end;
/
show errors

-- This script assumes it will be run once on all files and not broken
-- up into chunks.  The order by clause plays a critical role in the
-- script logic's attempt to avoid name collisions.
declare

	cursor fs_item_cur is

	select r.item_id, r.revision_id, r.title, i.name, i.live_revision, i.parent_id
            from cr_items i, cr_revisions r
	    where i.item_id=r.item_id
	    and i.live_revision=r.revision_id
	    and i.content_type='file_storage_object'
        order by parent_id, title, revision_id;
	
        v_count integer;
        v_prev_parent_id integer;
        v_prev_title cr_items.name%TYPE;
begin
        v_count := 1;
        v_prev_parent_id := 0;
        v_prev_title := '';

	for v_item_row in fs_item_cur
	loop

	   update cr_revisions set title=v_item_row.name
		where revision_id=v_item_row.revision_id;

           if v_item_row.parent_id = v_prev_parent_id
             and v_item_row.title = v_prev_title then

             --Name collision: change file.ext to file.n.ext

             v_count := v_count + 1;
  
             update cr_items set name = tmp_fs_name_duplicate(v_item_row.title,v_count)
	        where item_id=v_item_row.item_id;

             dbms_output.put_line(tmp_fs_name_duplicate(v_item_row.title,v_count));

           else

             update cr_items set name = v_item_row.title
	        where item_id=v_item_row.item_id;

             v_count := 1;
	     v_prev_parent_id := v_item_row.parent_id;
             v_prev_title := v_item_row.title;

           end if;

	end loop;

end;
/
show errors

--warning: dropping the function results in a commit
drop function tmp_fs_name_duplicate;
