-- Move old fs_simple_objects URLs to the content repository, where they
-- belong.

create or replace function inline_0() returns integer as '
declare
  fs_url         record;
  new_url_id     cr_extlinks.extlink_id%TYPE;
begin

    for fs_url in select * from fs_urls_full
    loop

      if not content_folder__is_registered(fs_url.folder_id, ''content_extlink'', ''t'') then
        perform content_folder__register_content_type(fs_url.folder_id, ''content_extlink'', ''t'');
      end if;

      new_url_id := content_extlink__new (
                      null,
                      fs_url.url,
                      fs_url.name,
                      fs_url.description,
                      fs_url.folder_id,
                      null,
                      fs_url.creation_date,
                      fs_url.creation_user,
                      fs_url.creation_ip
                    );  

      update acs_objects
      set last_modified = fs_url.last_modified,
        modifying_user = fs_url.modifying_user,
        modifying_ip = fs_url.modifying_ip
      where object_id = fs_url.object_id;

      update acs_permissions
      set object_id = new_url_id
      where object_id = fs_url.object_id;

      perform acs_object__delete(fs_url.object_id);

    end loop;

  return 0;

end' language 'plpgsql';

begin;
  select inline_0();
  drop function inline_0();
  drop view fs_objects;
  drop view fs_urls_full;
  drop table fs_urls;
  drop table fs_simple_objects;
end;

create view fs_urls_full
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

create view fs_objects
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
              from cr_items ci2
              where ci2.content_type <> 'content_folder'
                and ci2.tree_sortkey between cr_items.tree_sortkey and tree_right(cr_items.tree_sortkey))
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
    from cr_items left join cr_extlinks on (cr_items.item_id = cr_extlinks.extlink_id)
      left join cr_folders on (cr_items.item_id = cr_folders.folder_id)
      left join cr_revisions on (cr_items.live_revision = cr_revisions.revision_id)
      join acs_objects on (cr_items.item_id = acs_objects.object_id);
