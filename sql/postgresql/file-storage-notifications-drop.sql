
--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(
) RETURNS integer AS $$
DECLARE
   row 				record;
BEGIN
    for row in select type_id
                from notification_types
                where short_name in ('fs_fs_notif')
    loop
        perform notification_type__delete(row.type_id);
    end loop;

    return null;
END;
$$ LANGUAGE plpgsql;

select inline_0();
drop function inline_0();


--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(
) RETURNS integer AS $$
DECLARE
        impl_id integer;
        v_foo   integer;
BEGIN
        -- the notification type impl
        impl_id := acs_sc_impl__get_id (
                      'NotificationType',		-- impl_contract_name
                      'fs_fs_notif_type'	-- impl_name
        );

        perform acs_sc_binding__delete (
                    'NotificationType',
                    'fs_fs_notif_type'
        );

        v_foo := acs_sc_impl_alias__delete (
                    'NotificationType',		-- impl_contract_name	
                    'fs_fs_notif_type',		-- impl_name
                    'GetURL'				-- impl_operation_name
        );

        v_foo := acs_sc_impl_alias__delete (
                    'NotificationType',		-- impl_contract_name	
                    'fs_fs_notif_type',	-- impl_name
                    'ProcessReply'			-- impl_operation_name
        );

        perform acs_sc_impl__delete(
                    'NotificationType',                -- impl_contract_name
                    'fs_fs_notif_type'                 -- impl_name
        );

	select into v_foo type_id 
	  from notification_types
	 where sc_impl_id = impl_id
	  and short_name = 'fs_fs_notif';

	perform notification_type__delete (v_foo);

	delete from notification_types_intervals
	 where type_id = v_foo 
	   and interval_id in ( 
		select interval_id
		  from notification_intervals 
		 where name in ('instant','hourly','daily')
	);

	delete from notification_types_del_methods
	 where type_id = v_foo
	   and delivery_method_id in (
		select delivery_method_id
		  from notification_delivery_methods 
		 where short_name in ('email')
	);

	return (0);
END;
$$ LANGUAGE plpgsql;

select inline_0();
drop function inline_0();
