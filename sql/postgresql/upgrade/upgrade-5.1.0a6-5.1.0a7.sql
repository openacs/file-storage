--set serveroutput on size 200000

create or replace function tmp_fs_name_duplicate (
        varchar
) returns integer
as '
declare
  v_name  alias for $1; --cr_items.name%TYPE
  v_count integer;
  v_insert_pos integer;
begin
  v_insert_pos := instr(v_name,''.'',-1)-1;
  if v_insert_pos = -1 then
    return v_name || ''.'' || v_count;
  else
    return substr(v_name,1,v_insert_pos) || ''.'' || v_count || substr(v_name,v_insert_pos+1);
  end if;
end;' language 'plpgsql';

--show errors

-- This script assumes it will be run once on all files and not broken
-- up into chunks.  The order by clause plays a critical role in the
-- script logics attempt to avoid name collisions.

create or replace function inline_0 () returns integer as '
declare

        v_count integer;
        v_prev_parent_id integer;
        v_prev_title cr_items.name%TYPE;
        v_new_name cr_items.name%TYPE;
        v_item_row RECORD;
begin
        v_count := 1;
        v_prev_parent_id := 0;
        v_prev_title := '''';

        for v_item_row in select
            r.item_id, r.revision_id, r.title, i.name,
            i.live_revision, i.parent_id
            from cr_items i, cr_revisions r
	    where i.item_id=r.item_id
	    and i.live_revision=r.revision_id
	    and i.content_type=''file_storage_object''
        order by parent_id, title, revision_id
	loop

	   update cr_revisions set title=v_item_row.name
		where revision_id=v_item_row.revision_id;

           if v_item_row.parent_id = v_prev_parent_id
             and v_item_row.title = v_prev_title then

             --Name collision: change file.ext to file.n.ext

             v_count := v_count + 1;
             v_new_name := select tmp_fs_name_duplicate(v_item_row.title,v_count);
             update cr_items set name = v_new_name
	        where item_id=v_item_row.item_id;

             raise notice ''%'',v_new_name;

           else

             update cr_items set name = v_item_row.title
	        where item_id=v_item_row.item_id;

             v_count := 1;
	     v_prev_parent_id := v_item_row.parent_id;
             v_prev_title := v_item_row.title;

           end if;

	end loop;
return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0();

drop function tmp_fs_name_duplicate(varchar);
