-- 

-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2004-05-16
-- @cvs-id $Id$
--

drop view fs_objects;
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
        else coalesce(cr_revisions.title,cr_items.name)
      end as name,
      cr_items.name as file_upload_name,
      cr_revisions.mime_type,
      acs_objects.last_modified,
      cr_extlinks.url,
      cr_items.parent_id,
      cr_items.name as key,
      case
        when cr_items.content_type = 'content_folder' then 0
        else 1
      end as sort_key,
	cr_mime_types.label as pretty_type

    from cr_items left join cr_extlinks on (cr_items.item_id = cr_extlinks.extlink_id)
      
      left join cr_folders on (cr_items.item_id = cr_folders.folder_id)
      left join cr_revisions on (cr_items.live_revision = cr_revisions.revision_id)
      left join cr_mime_types on (cr_revisions.mime_type = cr_mime_types.mime_type)
      join acs_objects on (cr_items.item_id = acs_objects.object_id);

-- dropped old version in d1-d2 upgrade script. 

create or replace function file_storage__new_root_folder (
       --
       -- Creates a new root folder
       --
       -- 
       -- A hackish function to get around the fact that we can not run
       -- code automatically when a new package instance is created.
       --
       integer,         -- apm_packages.package_id%TYPE
       varchar,         -- cr_folders.label%TYPE
       varchar,          -- cr_items.name%TYPE
       varchar
)
returns integer as '    --  fs_root_folders.folder_id%TYPE
declare
        new_root_folder__package_id         alias for $1;
        new_root_folder__folder_name        alias for $2;
	new_root_folder__url	            alias for $3;
        new_root_folder__description        alias for $4;
        v_folder_id                         fs_root_folders.folder_id%TYPE;
begin


        v_folder_id := content_folder__new (
            new_root_folder__url, -- name
            new_root_folder__folder_name, -- label
	    new_root_folder__description, -- description
            null,  -- parent_id (default)
	    new_root_folder__package_id, --context_id
	    null, --folder_id
	    null, --creation_date
	    null, --creation_user
	    null --creation_ip
	);

        insert into fs_root_folders 
        (package_id, folder_id)
        values 
        (new_root_folder__package_id, v_folder_id);

        -- allow child items to be added
        -- JS: Note that we need to set include_subtypes to 
        -- JS: true since we created a new subtype.
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_revision'',   -- content_types
                ''t''                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_folder'',     -- content_types
                ''t''                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_symlink'',    -- content_types
                ''t''                   -- include_subtypes 
                );
        PERFORM content_folder__register_content_type(
                v_folder_id,            -- folder_id
                ''content_extlink'',    -- content_types
                ''t''                   -- include_subtypes 
                );

        return v_folder_id;

end;' language 'plpgsql';
