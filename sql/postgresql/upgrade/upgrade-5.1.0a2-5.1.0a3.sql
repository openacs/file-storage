create or replace function file_storage__rename_file (
       --
       -- Rename a file and all
       -- Wrapper to content_item__edit_name
       --
       integer,         -- cr_items.item_id%TYPE,
       varchar          -- cr_items.name%TYPE
) returns integer as '
declare
        rename_file__file_id    alias for $1;
        rename_file__name      alias for $2;

begin

        return content_item__edit_name(
               rename_file__file_id,  -- item_id
               rename_file__name     -- name
               );

end;' language 'plpgsql';

