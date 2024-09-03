<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">

<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2004-05-10 -->
<!-- @cvs-id $Id$ -->

<queryset>
  <fullquery name="count_root_folders">
    <querytext>
      select count(folder_id)
      from fs_root_folders
      where folder_id in ([ns_dbquotelist $object_id])
    </querytext>
  </fullquery>
  
</queryset>