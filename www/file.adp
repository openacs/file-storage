<master>
<property name="title">@title;noquote@</property>
<property name="header">@title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="displayed_object_id">@file_id;noquote@</property>

<h1>@title;noquote@ - #file-storage.properties#</h1>

<div class="list-button-bar-top"><a href="@folder_view_url@" title="#file-storage.back_to_folder_view#">#file-storage.back_to_folder_view#</a></div>
<div class="list-button-bar-top">
	<if @show_all_versions_p@ true>
		<a href="file?file_id=@file_id@&show_all_versions_p=f" class="button" title="#file-storage.lt_show_only_live_versio#">#file-storage.lt_show_only_live_versio#</a>
	</if>
	<else>
		<a href="file?file_id=@file_id@&show_all_versions_p=t" class="button" title="#file-storage.show_all_versions#">#file-storage.show_all_versions#</a>
	</else>
</div>
<if @categories_p@><if @category_links@><p>#file-storage.Categories#: @category_links;noquote@</p></if></if>
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
