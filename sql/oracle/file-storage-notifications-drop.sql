
declare
begin
    for row in (select type_id
                from notification_types
                where short_name in (''fs_fs_notif''))
    loop
        notification_type.delete(row.type_id);
    end loop;
end;
