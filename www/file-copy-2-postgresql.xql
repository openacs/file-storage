<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="file_copy">      
      <querytext>

	select content_item__new (
            	:name,		     -- name
            	:parent_id,	     -- parent_id
		null,	             -- item_id (default)
		null,	             -- locale (default)
	        now(),	             -- creation_date (default)
            	:user_id,	     -- creation_user
            	:parent_id,	     -- context_id 
            	:ip_address,	     -- creation_ip
		'file_storage_item', -- item_subtype (needed by site-wide search)
            	:content_type,	     -- content_type
		null,		     -- title (default)
		null,		     -- description
		'text/plain',	     -- mime_type (default)
		null,	             -- nls_language (default)
		null		     -- data (default)
        	);

      </querytext>
</fullquery>

 
<fullquery name="revision_copy">      
      <querytext>

	declare
		v_object_id 	acs_objects.object_id%TYPE;
    	begin

        	select acs_object_id_seq.nextval into v_object_id;

        	insert into acs_objects 
        	(object_id, object_type, context_id, security_inherit_p,
         	 creation_user, creation_ip, last_modified, modifying_user, 
         	 modifying_ip)
        	(select v_object_id, object_type, :new_file_id, security_inherit_p,
         	 	creation_user, creation_ip, last_modified, modifying_user,
         		modifying_ip
         	 from acs_objects 
         	 where object_id = content_item__get_live_revision(:file_id));

        	insert into cr_revisions 
        	(revision_id, title, description, publish_date, mime_type,
         	 nls_language, content, item_id)
        	(select v_object_id, title, description, publish_date, mime_type,
         		nls_language, content, :new_file_id
         	 from cr_revisions
         	 where revision_id = content_item__get_live_revision(:file_id));

         	PERFORM content_item__set_live_revision(v_object_id);

		return v_object_id;


    	end;

      </querytext>
</fullquery>

 
</queryset>


