<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="folder_create">      
      <querytext>
      
begin
    :1 := content_folder.new (
        name => :name,
        label => :folder_name,
        parent_id => :parent_id,
        creation_user => :user_id,
        creation_ip => :creation_ip
    );
end;
      </querytext>
</fullquery>

 
<fullquery name="register_content">      
      <querytext>
      
begin
    content_folder.register_content_type(:folder_id,'content_revision');
    content_folder.register_content_type(:folder_id,'content_folder');
end;
      </querytext>
</fullquery>

 
<fullquery name="grant_admin_perms">      
      <querytext>
      
begin
    acs_permission.grant_permission (
        object_id => :folder_id,
        grantee_id => :user_id,
        privilege => 'admin'
    );
end;
      </querytext>
</fullquery>

 
</queryset>
