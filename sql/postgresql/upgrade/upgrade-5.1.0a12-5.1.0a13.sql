--
-- Update for RSS support.
-- aegrumet@alum.mit.edu
--

-- Utility function lifted from one of the notification upgrade scripts...
-- We might want to make this standard.
create or replace function safe_drop_constraint(name, name)
returns integer as '
declare
    p_table_name          alias for $1;
    p_constraint_name     alias for $2;
    v_constraint_p        integer;
begin
    select count(*)
    into   v_constraint_p
    from   pg_constraint con, pg_class c
    where  con.conname = p_constraint_name
    and    c.oid = con.conrelid
    and    c.relname = p_table_name;

    if v_constraint_p > 0 then
        execute ''alter table '' || p_table_name || '' drop constraint '' || p_constraint_name;
    end if;

    return 0;
end;' language 'plpgsql';

-- Now drop the old constraint if defined (it might not be).
select safe_drop_constraint('fs_rss_subscrs', 'fs_rss_subscrs_fk');
drop function safe_drop_constraint(name, name);

-- Add the constraint with cascade.
alter table fs_rss_subscrs add constraint fs_rss_subscrs_fk
                              foreign key (subscr_id)
                              references rss_gen_subscrs (subscr_id)
                              on delete cascade;
