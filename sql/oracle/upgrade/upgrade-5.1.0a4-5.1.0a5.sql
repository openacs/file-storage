
declare
        impl_id integer;
        v_foo   integer;
begin
        -- the notification type impl
        impl_id := acs_sc_impl.new (
                      impl_contract_name => 'NotificationType',
                      impl_name => 'fs_fs_notif_type',
                      impl_owner_name => 'file_storage'
                   );
	
	v_foo := acs_sc_impl_alias.new (
                    impl_contract_name => 'NotificationType',
                    impl_name => 'fs_fs_notif_type',
                    impl_operation_name => 'GetURL',
                    impl_alias => 'fs::notification::get_url',
                    impl_pl => 'TCL'
                 );

	v_foo := acs_sc_impl_alias.new (
                    impl_contract_name => 'NotificationType',
                    impl_name => 'fs_fs_notif_type',
                    impl_operation_name => 'ProcessReply',
                    impl_alias => 'fs::notification::process_reply',
                    impl_pl => 'TCL'
                 );


        acs_sc_binding.new (
                    contract_name => 'NotificationType',
                    impl_name => 'fs_fs_notif_type'
                 );

        v_foo:= notification_type.new (
                short_name => 'fs_fs_notif',
                sc_impl_id => impl_id,
                pretty_name => 'File-Storage Notification',
                description => 'Notifications for File Storage',
                creation_user => NULL,
                creation_ip => NULL
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
end;
/
show errors
