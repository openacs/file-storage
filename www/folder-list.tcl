set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

if ![empty_string_p $file_id] {
    set children_clause [db_map children_clause]
} else {
    set children_clause ""
}

# A nasty query.  jmp suggested a nicer, but still kludgy, alternative.
# Should base the choice on performance tests.

set sql "
 select lpad('&nbsp;&nbsp;',12 * level,'&nbsp;&nbsp;') as spaces,
     (select f.label from cr_folders f where f.folder_id = i.item_id) as label,
     (select f.folder_id from cr_folders f where f.folder_id = i.item_id) as new_parent
 from   cr_items i
 where  acs_permission.permission_p(i.item_id,:user_id,'write') = 't'
 and    exists (select 1 from cr_folders f where f.folder_id = i.item_id)
 $children_clause
 connect by prior item_id = parent_id
 start with item_id = file_storage.get_root_folder(:package_id)
"
db_multirow folder folder $sql
