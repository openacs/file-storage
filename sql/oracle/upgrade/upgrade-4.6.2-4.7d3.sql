-- Upgrade script that creates and registers a content template for the
-- file_storage_object content type.
--
-- @author Ola Hansson <ola@polyxena.net>

set escape on

declare
    template_id integer;
begin

    -- Create the (default) file_storage_object content type template

    template_id := content_template.new( 
      name      => 'file-storage-default',
      text      => '<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>
\@text;noquote@'
    );

    -- Register the template for the file_storage_object content type

    content_type.register_template(
      content_type => 'file_storage_object',
      template_id  => template_id,
      use_context  => 'public',
      is_default   => 't'
    );

end;
/
show errors;

@ ../file-storage-package-create.sql