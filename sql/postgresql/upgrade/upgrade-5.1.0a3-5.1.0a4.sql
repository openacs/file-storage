
create or replace function file_storage__move_file (
       --
       -- Move a file (ans all its versions) to a different folder.
       -- Wrapper for content_item__move
       -- 
       integer,         -- cr_folders.folder_id%TYPE,
       integer,         -- cr_folders.folder_id%TYPE
       integer,         -- ceration_user
       varchar          -- creation_ip
) returns integer as '  -- 0 for success 
declare
        move_file__file_id              alias for $1;
        move_file__target_folder_id     alias for $2;
        move_file__creation_user        alias for $3;
        move_file__creation_ip          alias for $4;
begin

        perform content_item__move(
               move_file__file_id,              -- item_id
               move_file__target_folder_id      -- target_folder_id
               );

        perform acs_object__update_last_modified(move_file__target_folder_id,move_file__creation_user,move_file__creation_ip);

        return 0;
end;' language 'plpgsql';
