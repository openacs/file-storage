
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
                                     constraint fs_simp_obj_id_pk
                                     primary key,
       folder_id                     integer
                                     constraint fs_simp_folder_id_fk
                                     references cr_folders(folder_id),
       name                          varchar(250) not null,
       description                   varchar(4000)
);


create table fs_urls (
       url_id                        integer
                                     constraint fs_url_url_id_fk
                                     references fs_simple_objects(object_id)
                                     constraint fs_url_url_id_pk
                                     primary key,
       url                           varchar(250) not null
);

-- stuff for non-versioned file-storage objects
select acs_object_type__create_type (
        'fs_simple_object',
        'File Storage Simple Object',
        'File Storage Simple Objects',
        'acs_object',
        'fs_simple_objects',
        'object_id',
        NULL,
        'f',
        NULL,
        NULL
);

-- links
select acs_object_type__create_type (
        'fs_url',
        'File Storage URL',
        'File Storage URLs',
        'fs_simple_object',
        'fs_urls',
        'url_id',
        NULL,
        'f',
        NULL,
        NULL
);
