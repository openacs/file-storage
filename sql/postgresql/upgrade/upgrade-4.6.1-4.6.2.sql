-- Move old fs_simple_objects URLs to the content repository, where they
-- belong.



--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(

) RETURNS integer AS $$
DECLARE
  root           record;
  folder         record;
  fs_url         record;
  new_url_id     cr_extlinks.extlink_id%TYPE;
BEGIN

    for root in select tree_sortkey
                from fs_root_folders, cr_items
                where fs_root_folders.folder_id = cr_items.item_id
    loop

      for folder in select folder_id
                    from cr_folders, cr_items
                    where cr_items.tree_sortkey between root.tree_sortkey and tree_right(root.tree_sortkey)
                      and cr_folders.folder_id = cr_items.item_id
      loop
        if not content_folder__is_registered(folder.folder_id, 'content_symlink', 't') then
          perform content_folder__register_content_type(folder.folder_id, 'content_symlink', 't');
        end if;
        if not content_folder__is_registered(folder.folder_id, 'content_extlink', 't') then
          perform content_folder__register_content_type(folder.folder_id, 'content_extlink', 't');
        end if;
      end loop;

    end loop;

    for fs_url in select * from fs_urls_full
    loop

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

end
$$ LANGUAGE plpgsql;

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
        else cr_revisions.content_length
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

-- JS: BEFORE DELETE TRIGGER to clean up CR entries (except root folder)
drop function fs_package_items_delete_trig ();


--
-- procedure fs_package_items_delete_trig/0
--
CREATE OR REPLACE FUNCTION fs_package_items_delete_trig(

) RETURNS trigger AS $$
DECLARE

        v_rec   record;
BEGIN

        for v_rec in
        
                -- We want to delete all cr_items entries, starting from the leaves all
                --  the way up the root folder (old.folder_id).
                select c1.item_id, c1.content_type
                from cr_items c1, cr_items c2
                where c2.item_id = old.folder_id
                  and c1.tree_sortkey between c2.tree_sortkey and tree_right(c2.tree_sortkey)
                  and c1.item_id <> old.folder_id
                order by c1.tree_sortkey desc
        loop

                -- DRB: Why can't we just use object delete here?


                -- We delete the item. On delete cascade should take care
                -- of deletion of revisions.
                if v_rec.content_type = 'file_storage_object'
                then
                    raise notice 'Deleting item_id = %',v_rec.item_id;
                    PERFORM content_item__delete(v_rec.item_id);
                end if;

                -- Instead of doing an if-else, we make sure we are deleting a folder.
                if v_rec.content_type = 'content_folder'
                then
                    raise notice 'Deleting folder_id = %',v_rec.item_id;
                    PERFORM content_folder__delete(v_rec.item_id);
                end if;

                -- Instead of doing an if-else, we make sure we are deleting a folder.
                if v_rec.content_type = 'content_symlink'
                then
                    raise notice 'Deleting symlink_id = %',v_rec.item_id;
                    PERFORM content_symlink__delete(v_rec.item_id);
                end if;

                -- Instead of doing an if-else, we make sure we are deleting a folder.
                if v_rec.content_type = 'content_extlink'
                then
                    raise notice 'Deleting folder_id = %',v_rec.item_id;
                    PERFORM content_extlink__delete(v_rec.item_id);
                end if;

        end loop;

        -- We need to return something for the trigger to be activated
        return old;

END;
$$ LANGUAGE plpgsql;

drop trigger fs_package_items_delete_trig on fs_root_folders;
create trigger fs_package_items_delete_trig before delete
on fs_root_folders for each row 
execute procedure fs_package_items_delete_trig ();


