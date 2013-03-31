


-- added
select define_function_args('file_storage__move_file','file_id,target_folder_id,creation_user,creation_ip');

--
-- procedure file_storage__move_file/4
--
CREATE OR REPLACE FUNCTION file_storage__move_file(
   move_file__file_id integer,
   move_file__target_folder_id integer,
   move_file__creation_user integer,
   move_file__creation_ip varchar

) RETURNS integer AS $$
DECLARE
BEGIN

        perform content_item__move(
               move_file__file_id,              -- item_id
               move_file__target_folder_id      -- target_folder_id
               );

        perform acs_object__update_last_modified(move_file__target_folder_id,move_file__creation_user,move_file__creation_ip);

        return 0;
END;
$$ LANGUAGE plpgsql;
