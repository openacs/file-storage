<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">

<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2004-05-10 -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

 <fullquery name="get_to_be_deleted">    
   <querytext>
	select fs.object_id as fs_object_id, fs.name, fs.type, fs.parent_id,
      	acs_permission.permission_p(fs.object_id, :user_id, 'write') as delete_p
      	from fs_objects fs
      	where fs.object_id in ('$object_id_list')

    </querytext>
  </fullquery>

  
</queryset>

