create or replace function file_storage__copy_file(
       --
       -- Copy a file, but only copy the live_revision
       --
       integer,         -- cr_items.item_id%TYPE,
       integer,         -- cr_items.parent_id%TYPE,
       integer,         -- acs_objects.creation_user%TYPE,
       varchar          -- acs_objects.creation_ip%TYPE
) returns integer as '  -- cr_revisions.revision_id%TYPE
declare
        copy_file__file_id           alias for $1;
        copy_file__target_folder_id  alias for $2;
        copy_file__creation_user     alias for $3;
        copy_file__creation_ip       alias for $4;
        v_name                      cr_items.name%TYPE;
        v_live_revision              cr_items.live_revision%TYPE;
        v_filename                   cr_revisions.title%TYPE;
        v_description                cr_revisions.description%TYPE;
        v_mime_type                  cr_revisions.mime_type%TYPE;
        v_content_length             cr_revisions.content_length%TYPE;
        v_lob_id                     cr_revisions.lob%TYPE;
        v_new_lob_id                 cr_revisions.lob%TYPE;
        v_file_path                  cr_revisions.content%TYPE;
        v_new_file_id                cr_items.item_id%TYPE;
        v_new_version_id                     cr_revisions.revision_id%TYPE;
        v_indb_p                     boolean;
        v_isurl                      boolean;
        v_content_type               cr_items.content_type%TYPE;
        v_package_id                 apm_packages.package_id%TYPE;
begin

        v_isurl:= false;
        select content_type into v_content_type from cr_items where item_id = copy_file__file_id;
        if v_content_type = ''content_extlink''
        then
          v_isurl:= true;
        end if;

        -- We copy only the title from the file being copied, and attributes of the live revision
        if v_isurl = false
        then
          select i.name,i.live_revision,r.title,r.description,r.mime_type,r.content_length,
               (case when i.storage_type = ''lob''
                     then true
                     else false
                end)
               into v_name,v_live_revision,v_filename,v_description,v_mime_type,v_content_length,v_indb_p
          from cr_items i, cr_revisions r
          where r.item_id = i.item_id
          and   r.revision_id = i.live_revision
          and   i.item_id = copy_file__file_id;

          select package_id into v_package_id from acs_objects where object_id = copy_file__file_id;

          v_new_file_id := file_storage__new_file(
                             v_name,                     -- name
                             copy_file__target_folder_id, -- folder_id
                             copy_file__creation_user,    -- creation_user
                             copy_file__creation_ip,      -- creation_ip
                             v_indb_p,                    -- indb_p
                             v_package_id                 -- package_id
                             );

          v_new_version_id := file_storage__new_version (
                             v_filename,                  -- title
                             v_description,               -- description
                             v_mime_type,                 -- mime_type
                             v_new_file_id,               -- item_id
                             copy_file__creation_user,    -- creation_user
                             copy_file__creation_ip       -- creation_ip
                             );

          if v_indb_p
          then

                -- Lob to copy from
                select lob into v_lob_id
                from cr_revisions
                where revision_id = v_live_revision;

                -- New lob id
                v_new_lob_id := empty_lob();

                -- copy the blob
                perform lob_copy(v_lob_id,v_new_lob_id);

                -- Update the lob id on the new version
                update cr_revisions
                set lob = v_new_lob_id,
                    content_length = v_content_length
                where revision_id = v_new_version_id;

          else
               -- For now, we simply copy the file name
                select content into v_file_path
                from cr_revisions
                where revision_id = v_live_revision;

                -- Update the file path
                update cr_revisions
                set content = v_file_path,
                    content_length = v_content_length
                where revision_id = v_new_version_id;

          end if;
          perform acs_object__update_last_modified(copy_file__target_folder_id,copy_file__creation_user,copy_file__creation_ip);
          return v_new_version_id;
        else
          perform content_extlink__copy (copy_file__file_id, copy_file__target_folder_id, copy_file__creation_user,copy_file__creation_ip,v_name);
          return 0;
        end if;

end;' language 'plpgsql';

