<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="file_copy">      
      <querytext>
      
    	begin
        	:1 := content_item.new (
            		parent_id => :parent_id,
            		context_id => :parent_id,
            		name => :name,
            		content_type => :content_type,
            		creation_user => :user_id,
            		creation_ip => :ip_address,
			item_subtype => 'file_storage_item' -- needed by site-wide search
        		);
    	end;

      </querytext>
</fullquery>

 
<fullquery name="revision_copy">      
      <querytext>
      
    	begin
        	select acs_object_id_seq.nextval into :1 from dual;

        	insert into acs_objects 
        	(object_id, object_type, context_id, security_inherit_p,
         	 creation_user, creation_ip, last_modified, modifying_user, 
         	 modifying_ip)
        	(select :1, object_type, :new_file_id, security_inherit_p,
         		creation_user, creation_ip, last_modified, modifying_user,
         		modifying_ip
         	 from acs_objects 
         	 where object_id = content_item.get_live_revision(:file_id));

        	insert into cr_revisions 
        	(revision_id, title, description, publish_date, mime_type,
         	 nls_language, content, item_id)
        	(select :1, title, description, publish_date, mime_type,
         		nls_language, content, :new_file_id
         	 from cr_revisions
         	 where revision_id = content_item.get_live_revision(:file_id));

         	content_item.set_live_revision(:1);

    	end;

      </querytext>
</fullquery>

 
</queryset>
