-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2005-01-05
-- @cvs-id $Id$
--

-- Add root folders into dav_site_node_folder_map

insert into dav_site_node_folder_map (select sn.node_id, fs.folder_id, 'f' from fs_root_folders fs, site_nodes sn where sn.object_id=fs.package_id and fs.folder_id not in (select folder_id from dav_site_node_folder_map));
