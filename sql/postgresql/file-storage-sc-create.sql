-- Implement site-wide search using OpenFTS
--
-- file-storage/sql/postgresql/file-storage-sc-create.sql
--
-- @author Jowell Sabino (jowellsabino@netscape.net)
--

--Implement a content provider contract
select acs_sc_impl__new(
           'FtsContentProvider',                -- impl_contract_name
           'file_storage_object',               -- impl_name (the content_type created above)
           'file-storage'                       -- impl_owner_name (package key of File Storage)
	   );

-- Implement an association with function 'datasource' and the concrete implementation 'fs__datasource'
select acs_sc_impl_alias__new(
           'FtsContentProvider',                -- impl_contract_name
           'file_storage_object',               -- impl_name
           'datasource',                        -- impl_operation_name
           'fs__datasource',                    -- impl_alias
           'TCL'                                -- impl_pl
);

-- Implement an association with function 'url' and the concrete implementation 'fs__url'
select acs_sc_impl_alias__new(
           'FtsContentProvider',                -- impl_contract_name
           'file_storage_object',               -- impl_name
           'url',				-- impl_operation_name
           'fs__url',				-- impl_alias
           'TCL'                                -- impl_pl
);



