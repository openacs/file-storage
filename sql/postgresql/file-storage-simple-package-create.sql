
--
-- File Storage NonVersioned (simple) Objects
--
-- This is to get away from the CR pain when dealing with file-storage of
-- "other" objects
--
-- @author Ben Adida (ben@openforce)
-- @creation-date 01 April 2002
-- @cvs-id $Id$
--

select define_function_args('fs_simple_object__new','object_id,object_type,fs_simple_object,folder_id,name,description,creation_date,creation_user,creation_ip,context_id');

create function fs_simple_object__new(integer,varchar,integer,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
DECLARE
        p_object_id             alias for $1;
        p_object_type           alias for $2;
        p_folder_id             alias for $3;
        p_name                  alias for $4;
        p_description           alias for $5;
        p_creation_date         alias for $6;
        p_creation_user         alias for $7;
        p_creation_ip           alias for $8;
        p_context_id            alias for $9;
        v_object_id             integer;
BEGIN
        v_object_id:= acs_object__new (
              p_object_id,
              p_object_type,
              p_creation_date,
              p_creation_user,
              p_creation_ip,
              p_context_id
        );

        insert into fs_simple_objects
        (object_id, folder_id, name, description) values
        (v_object_id, p_folder_id, p_name, p_description);

        PERFORM acs_object__update_last_modified(p_folder_id);

        return v_object_id;

END;
' language 'plpgsql';

select define_function_args('fs_simple_object__delete','object_id');

create function fs_simple_object__delete(integer)
returns integer as '
DECLARE
        p_object_id             alias for $1;
BEGIN
        PERFORM acs_object__delete(p_object_id);

        return 0;
END;
' language 'plpgsql';

select define_function_args('fs_simple_object__name', 'object_id');

create function fs_simple_object__name(integer)
returns integer as '
declare
    p_object_id                     alias for $1;
begin
    return name
    from fs_simple_objects
    where object_id = p_object_id;
end;
' language 'plpgsql';

select define_function_args('fs_url__new','url_id,object_type;fs_url,url,folder_id,name,description,creation_date,creation_user,creation_ip,context_id');

select define_function_args('fs_url__delete','url_id');

select define_function_args('fs_url__copy','url_id;target_object_id');

create function fs_url__new(integer,varchar,varchar,integer,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
DECLARE
        p_url_id                alias for $1;
        p_object_type           alias for $2;
        p_url                   alias for $3;
        p_folder_id             alias for $4;
        p_name                  alias for $5;
        p_description           alias for $6;
        p_creation_date         alias for $7;
        p_creation_user         alias for $8;
        p_creation_ip           alias for $9;
        p_context_id            alias for $10;
        v_url_id                integer;
BEGIN
        v_url_id:= fs_simple_object__new (
            p_url_id,
            p_object_type,
            p_folder_id,
            p_name,
            p_description,
            p_creation_date,
            p_creation_user,
            p_creation_ip,
            p_context_id
        );

        insert into fs_urls
        (url_id, url) values
        (v_url_id, p_url);

        return v_url_id;
END;
' language 'plpgsql';


create function fs_url__delete(integer)
returns integer as '
DECLARE
        p_url_id                alias for $1;
BEGIN
        delete from fs_urls where url_id= p_url_id;

        PERFORM fs_simple_object__delete(p_url_id);

        return 0;
END;
' language 'plpgsql';


create function fs_url__copy(integer,integer)
returns integer as '
DECLARE
        p_url_id                alias for $1;
        p_target_folder_id      alias for $2;
        v_new_url_id            integer;
        v_url                   varchar;
        v_name                  varchar;
        v_description           varchar;
        v_creation_user         integer;
        v_creation_ip           varchar;
BEGIN
        select url
        into v_url
        from fs_urls
        where url_id = p_url_id;

        select name
        into v_name
        from fs_simple_objects
        where object_id = p_url_id;

        select description
        into v_description
        from fs_simple_objects
        where object_id = p_url_id;

        select creation_user
        into v_creation_user
        from acs_objects
        where object_id = p_url_id;

        select creation_ip
        into v_creation_ip
        from acs_objects
        where object_id = p_url_id;

        v_new_url_id:= fs_url__new (
            NULL,
            ''fs_url'',
            v_url,
            p_target_folder_id,
            v_name,
            v_description,
            NULL,
            v_creation_user,
            v_creation_ip,
            p_target_folder_id
        );

        return v_new_url_id;
END;
' language 'plpgsql';
