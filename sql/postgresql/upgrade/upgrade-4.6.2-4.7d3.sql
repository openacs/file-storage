-- Upgrade script that creates and registers a content template for the
-- file_storage_object content type.
--
-- @author Ola Hansson <ola@polyxena.net>

create or replace function inline_0 ()
returns integer as'
declare
    template_id integer;
begin

    -- Create the (default) file_storage_object content type template

    template_id := content_template__new( 
      ''file-storage-default'', -- name
      ''<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>
@text;noquote@'',               -- text
      true                      -- is_live
    );

    -- Register the template for the file_storage_object content type

    perform content_type__register_template(
      ''file_storage_object'', -- content_type
      template_id,             -- template_id
      ''public'',              -- use_context
      ''t''                    -- is_default
    );

    return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0();
