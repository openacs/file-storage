<master>
<property name="title">@title;noquote@</property>
<property name="header">@title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="displayed_object_id">@file_id;noquote@</property>

<p>#file-storage.back_to_folder_view#</p>
<p><if @show_all_versions_p@ true>
    <a href="file?file_id=@file_id@&show_all_versions_p=f" class="button">#file-storage.lt_show_only_live_versio#</a>
  </if>
  <else>
    <a href="file?file_id=@file_id@&show_all_versions_p=t" class="button">#file-storage.show_all_versions#</a>
  </else>
</p>
  <listtemplate name="version"></listtemplate>
