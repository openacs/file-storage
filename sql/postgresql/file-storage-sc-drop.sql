-- Drop site-wide search using OpenFTS
--
-- packages/file-storage/sql/postgresql/file-storage-sc-drop.sql
--
-- @author Jowell Sabino (jowellsabino@netscape.net)
--

-- Drop association with function 'datasource' and their concrete implementation 'fs__datasource'
select acs_sc_impl_alias__delete(
           'FtsContentProvider',                -- impl_contract_name
           'file_storage_object',                 -- impl_name
           'datasource'                         -- impl_operation_name
	   );

-- Drop association with function 'url' and their concrete implementation 'fs__url'
select acs_sc_impl_alias__delete(
           'FtsContentProvider',		-- impl_contract_name
           'file_storage_object',               -- impl_name
           'url'				-- impl_operation_name
	   );

-- Drop the search contract implementation
select acs_sc_impl__delete(
           'FtsContentProvider',                -- impl_contract_name
           'file_storage_object'                -- impl_name (the content_type created above)
	   );





         
