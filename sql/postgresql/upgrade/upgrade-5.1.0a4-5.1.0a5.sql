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
        impl_id := acs_sc_impl__new (
                      'NotificationType',
                      'fs_fs_notif_type',
                      'file_storage'
                   );
	
	v_foo := acs_sc_impl_alias__new (
                    'NotificationType',			-- impl_contract_name
                    'fs_fs_notif_type',			-- impl_name
                    'GetURL',					-- impl_operation_name
		    'fs::notification::get_url',					-- impl_alias
                    'TCL'					-- impl_pl
                 );

	v_foo := acs_sc_impl_alias__new (
                    'NotificationType',
                    'fs_fs_notif_type',
                    'ProcessReply',
                    ' fs::notification::process_reply',
                    'TCL'
        );	

        PERFORM acs_sc_binding__new (
                    'NotificationType',
                    'fs_fs_notif_type'
                 );

        v_foo:= notification_type__new (
		NULL,
		impl_id,
		'fs_fs_notif',
      	        'File-Storage Notification',
                'Notifications for File Storage',
		now(),
                NULL,
                NULL,
		NULL
                );

        -- enable the various intervals and delivery methods
        insert into notification_types_intervals
        (type_id, interval_id)
        select v_foo, interval_id
        from notification_intervals where name in ('instant','hourly','daily');

        insert into notification_types_del_methods
        (type_id, delivery_method_id)
        select v_foo, delivery_method_id
        from notification_delivery_methods where short_name in ('email');
	
	return (0);

END;

$$ LANGUAGE plpgsql;

select inline_0();
drop function inline_0();
