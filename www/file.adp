<master>
<property name="title">@title;noquote@</property>
<property name="header">@title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="displayed_object_id">@file_id;noquote@</property>

<p><a href="@folder_view_url@" title="#file-storage.back_to_folder_view#">#file-storage.back_to_folder_view#</a></p>
<p><if @show_all_versions_p@ true>
    <a href="file?file_id=@file_id@&show_all_versions_p=f" class="button" title="#file-storage.lt_show_only_live_versio#">#file-storage.lt_show_only_live_versio#</a>
  </if>
  <else>
    <a href="file?file_id=@file_id@&show_all_versions_p=t" class="button" title="#file-storage.show_all_versions#">#file-storage.show_all_versions#</a>
  </else>
</p>
  <listtemplate name="version"></listtemplate>
<if @gc_comments@ not nil>
 <p>#file-storage.lt_Comments_on_this_file#
 <ul>
 @gc_comments;noquote@
 </ul></p>
 </if>
 <if @gc_link@ not nil>
   <p>@gc_link;noquote@</p>
 </if>
