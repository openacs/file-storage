-- Move old fs_simple_objects URLs to the content repository, where they
-- belong.

declare
  new_url_id     cr_extlinks.extlink_id%TYPE;
begin

    for fs_url in (select * from fs_urls_full)
    loop

      if content_folder.is_registered(fs_url.folder_id, 'content_extlink') = 'f' then
        content_folder.register_content_type(fs_url.folder_id, 'content_extlink');
      end if;

      new_url_id := content_extlink.new (
                      url => fs_url.url,
                      label => fs_url.name,
                      description => fs_url.description,
                      parent_id => fs_url.folder_id,
                      extlink_id => null,
                      creation_date => fs_url.creation_date,
                      creation_user => fs_url.creation_user,
                      creation_ip => fs_url.creation_ip
                    );  

      update acs_objects
      set last_modified = fs_url.last_modified,
        modifying_user = fs_url.modifying_user,
        modifying_ip = fs_url.modifying_ip
      where object_id = fs_url.object_id;

      update acs_permissions
      set object_id = new_url_id
      where object_id = fs_url.object_id;

      acs_object.delete(fs_url.object_id);

    end loop;

end;
/
show errors;

drop table fs_urls;
drop table fs_simple_objects;

create or replace view fs_urls_full
as
    select cr_extlinks.extlink_id as url_id,
           cr_extlinks.url,
           cr_items.parent_id as folder_id,
           cr_extlinks.label as name,
           cr_extlinks.description,
           acs_objects.*
    from cr_extlinks,
         cr_items,
         acs_objects
    where cr_extlinks.extlink_id = cr_items.item_id
    and cr_items.item_id = acs_objects.object_id;

create or replace view fs_objects
as
    select cr_items.item_id as object_id,
      cr_items.live_revision,
      case
        when cr_items.content_type = 'content_folder' then 'folder'
        when cr_items.content_type = 'content_extlink' then 'url'
        else cr_revisions.mime_type
      end as type,
      case
        when cr_items.content_type = 'content_folder'
        then (select count(*)
              from cr_items ci
              where ci.content_type <> 'content_folder'
              connect by prior ci.item_id = ci.parent_id
              start with ci.item_id = cr_folders.folder_id)
        else 0
      end as content_size,
      case
        when cr_items.content_type = 'content_folder' then cr_folders.label
        when cr_items.content_type = 'content_extlink' then cr_extlinks.label
        else cr_items.name
      end as name,
      cr_revisions.title as file_upload_name,
      acs_objects.last_modified,
      cr_extlinks.url,
      cr_items.parent_id,
      cr_items.name as key,
      case
        when cr_items.content_type = 'content_folder' then 0
        else 1
      end as sort_key
    from cr_items, cr_extlinks, cr_folders, cr_revisions, acs_objects
    where cr_items.item_id = cr_extlinks.extlink_id(+)
      and cr_items.item_id = cr_folders.folder_id(+)
      and cr_items.item_id = acs_objects.object_id
      and cr_items.live_revision = cr_revisions.revision_id(+);
