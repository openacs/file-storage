-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2005-01-05
-- @arch-tag: d0ff33aa-5369-4926-973d-001db0e0c690
-- @cvs-id $Id$
--

-- Add root folders into dav_site_node_folder_map

insert into dav_site_node_folder_map (select sn.node_id, fs.folder_id, 'f' from fs_root_folders fs, site_nodes sn where sn.object_id=fs.package_id and fs.folder_id not in (select folder_id from dav_site_node_folder_map));