
--
-- File Storage NonVersioned (Simple) Objects
--
-- This is to get away from the CR pain when dealing with file-storage of
-- "other" objects
--
-- @author Ben Adida (ben@openforce)
-- @creation-date 01 April 2002
-- @cvs-id $Id$
--


-- Non-versioned objects
create table fs_simple_objects (
       object_id                     integer
                                     constraint fs_simp_obj_id_fk
                                     references acs_objects(object_id)
                                     constraint fs_simple_objects_pk
                                     primary key,
       folder_id                     integer
                                     constraint fs_simp_folder_id_fk
                                     references cr_folders,
       name                          varchar(250) not null,
       description                   varchar(4000)
);

create index fs_so_folder_id_idx on fs_simple_objects (folder_id);

create table fs_urls (
       url_id                        integer
                                     constraint fs_url_url_id_fk
                                     references fs_simple_objects(object_id)
                                     constraint fs_urls_pk
                                     primary key,
       url                           varchar(250) not null
);

begin
    -- stuff for non-versioned file-storage objects
    acs_object_type.create_type (
        supertype => 'acs_object',
        object_type => 'fs_simple_object',
        pretty_name => 'File Storage Simple Object',
        pretty_plural => 'File Storage Simple Objects',
        table_name => 'fs_simple_objects',
        id_column => 'object_id'
    );

    -- links
    acs_object_type.create_type (
        supertype => 'fs_simple_object',
        object_type => 'fs_url',
        pretty_name => 'File Storage URL',
        pretty_plural => 'File Storage URLs',
        table_name => 'fs_urls',
        id_column => 'url_id'
    );
end;
/
show errors;
