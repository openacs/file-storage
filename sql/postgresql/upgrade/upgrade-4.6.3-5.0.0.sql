-- Upgrade script that creates and registers a content template for the
-- file_storage_object content type.
--
-- @author Ola Hansson <ola@polyxena.net>

create or replace function inline_0 ()
returns integer as $$
declare
    template_id integer;
begin

    -- Create the (default) file_storage_object content type template

    template_id := content_template__new( 
      'file-storage-default', -- name
      '<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>
@text;noquote@',               -- text
      true                      -- is_live
    );

    -- Register the template for the file_storage_object content type

    perform content_type__register_template(
      'file_storage_object', -- content_type
      template_id,             -- template_id
      'public',              -- use_context
      't'                    -- is_default
    );

    return null;
END;
$$ LANGUAGE plpgsql;

select inline_0();
drop function inline_0();



-- added
select define_function_args('file_storage__new_version','filename,description,mime_type,item_id,creation_user,creation_ip');

--
-- procedure file_storage__new_version/6
--
CREATE OR REPLACE FUNCTION file_storage__new_version(
   new_version__filename varchar,
   new_version__description varchar,
   new_version__mime_type varchar,
   new_version__item_id integer,
   new_version__creation_user integer,
   new_version__creation_ip varchar

) RETURNS integer AS $$
-- cr_revisions.revision_id
DECLARE
        v_revision_id                   cr_revisions.revision_id%TYPE;
        v_folder_id                     cr_items.parent_id%TYPE;
BEGIN
        -- Create a revision
        v_revision_id := content_revision__new (
                          new_version__filename,        -- title
                          new_version__description,     -- description
                          now(),                        -- publish_date
                          new_version__mime_type,       -- mime_type
                          null,                         -- nls_language
                          null,                         -- data (default)
                          new_version__item_id,         -- item_id
                          null,                         -- revision_id
                          now(),                        -- creation_date
                          new_version__creation_user,   -- creation_user
                          new_version__creation_ip      -- creation_ip
                          );

        -- Make live the newly created revision
        perform content_item__set_live_revision(v_revision_id);

        select cr_items.parent_id
        into v_folder_id
        from cr_items
        where cr_items.item_id = new_version__item_id;

        perform acs_object__update_last_modified(v_folder_id,new_version__creation_user,new_version__creation_ip);
	perform acs_object__update_last_modified(new_version__item_id,new_version__creation_user,new_version__creation_ip);

        return v_revision_id;

END;
$$ LANGUAGE plpgsql;
