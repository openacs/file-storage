-- Don't use a fake table name, acs_objects supports types that don't have
-- a type specific table
update acs_object_types set
    table_name = NULL,
    id_column = NULL
where
    object_type = 'file_storage_object';

begin
content_type.refresh_view('file_storage_object');
content_type.refresh_trigger('file_storage_object');
end;
/

alter table 
    fs_root_folders 
drop constraint 
    fs_root_folder_folder_id_fk;

alter table 
    fs_root_folders 
add constraint 
    fs_root_folder_folder_id_fk 
    foreign key (folder_id) 
    references cr_folders 
    on delete cascade;
