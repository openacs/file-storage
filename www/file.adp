<master>
<property name="doc(title)">@title;literal@</property>
<property name="header">@title;literal@</property>
<property name="context">@context;literal@</property>
<property name="displayed_object_id">@file_id;literal@</property>

<h1>@title;noquote@ - #file-storage.properties#</h1>

<div class="list-button-bar-top">
  <a href="@folder_view_url@" class="button" title="#file-storage.back_to_folder_view#">#file-storage.back_to_folder_view#</a>
  <if @show_all_versions_p;literal@ true>
	<a href="@show_versions_url@" class="button" title="#file-storage.lt_show_only_live_versio#">#file-storage.lt_show_only_live_versio#</a>
  </if>
  <else>
	<a href="@show_versions_url@" class="button" title="#file-storage.show_all_versions#">#file-storage.show_all_versions#</a>
  </else>
</div>
<if @categories_p;literal@ true><if @category_links;literal@ ne ""><p>#file-storage.Categories#: @category_links;noquote@</p></if></if>
  <listtemplate name="version"></listtemplate>
<if @gc_comments@ not nil>
 <p>#file-storage.lt_Comments_on_this_file#</p>
 <ul>
 @gc_comments;noquote@
 </ul>
</if>
 <if @gc_link@ not nil>
   <p>@gc_link;noquote@</p>
 </if>
