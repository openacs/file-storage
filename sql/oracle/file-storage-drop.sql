--
-- packages/file-storage/sql/oracle/file-storage-drop.sql
--
-- @author Kevin Scaldeferri (kevin@arsdigita.com)
-- @creation-date 6 Now 2000
-- @cvs-id $Id$
--
-- drop script for file-storage
--

--
-- content repository is set up to cascade, so we should just have to 
-- delete the root folders
--
-- JS: The above is wrong.  You cannot, for example, delete a folder with contents on it so
-- JS: trying to delete the root folder will raise an exception.  Also, acs_object.delete 
-- JS: is the wrong way to delete the items in CR. To delete a folder, for example, we must
-- JS: call content_folder.delete, which in turn calls  acs_object.delete only through
-- JS: content_item.delete and only after cleaning up stuff).  So if the package is deleted but 
-- JS: there are still items in it, this drop script will fail.  Perhaps it should, since it makes 
-- JS: sense to delete the package only when the are no more stuff in it (perhaps moved elsewhere). 
-- JS: Thus, an empty file storage is the only way this drop script will succeed.  But then again, 
-- JS: the package should not barf if indeed the admin wants to nuke the package and 
-- JS: everything in it! (This is why deleting a package has a warning, I guess.)
-- JS:
-- JS: To delete properly, note: how did entries in fs_root_folders come about? Through APM!
-- JS: So we instead delete the *package instances*, and the triggers that we imposed on fs_root_folders
-- JS: will take care of cleaning up whatever items are in CR that are related to the package.
declare
    cursor c_root_folders
    is
    select package_id
    from   fs_root_folders;
begin
    for v_root_folder in c_root_folders loop
        -- acs_object.delete(v_root_folder.folder_id);
        apm_package.delete(v_root_folder.package_id);
    end loop;
end;
/
show errors

drop trigger fs_package_items_delete_trig;
drop trigger fs_root_folder_delete_trig;

drop table fs_root_folders;
drop package file_storage;

