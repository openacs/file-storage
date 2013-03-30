
-- added
select define_function_args('file_storage__rename_file','file_id,name');

--
-- procedure file_storage__rename_file/2
--
CREATE OR REPLACE FUNCTION file_storage__rename_file(
   rename_file__file_id integer,
   rename_file__name varchar

) RETURNS integer AS $$
DECLARE

BEGIN

        return content_item__edit_name(
               rename_file__file_id,  -- item_id
               rename_file__name     -- name
               );

END;
$$ LANGUAGE plpgsql;

