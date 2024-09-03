<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">

<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2004-05-09 -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="copy_item">
    <querytext>
	begin	      	
	:1 := file_storage.copy_file(
           :object_id,
           :folder_id,
	   :user_id,
           :peer_addr,
	   :name,
	   :title);
	end;
    </querytext>
  </fullquery>

  <fullquery name="copy_folder">
    <querytext>
        begin 
         :1 = content_folder.copy (
           :object_id,
           :folder_id,
	   :user_id,
           :peer_addr,
	   :name,
	   :title);
        end;
    </querytext>
  </fullquery>

</queryset>
