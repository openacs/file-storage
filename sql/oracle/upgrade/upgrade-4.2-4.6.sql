-- file-storage upgrade script
-- @author Vinod Kurup (vinod@kurup.com)
-- @creation-date 2002-10-27

-- reload the packages and views
-- load the new fs-simple stuff

@ ../file-storage-package-create.sql

@ ../file-storage-simple-create.sql
@ ../file-storage-simple-package-create.sql

@ ../file-storage-views-create.sql
